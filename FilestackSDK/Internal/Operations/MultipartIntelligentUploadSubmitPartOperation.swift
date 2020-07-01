//
//  MultipartIntelligentUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 26/09/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class MultipartIntelligentUploadSubmitPartOperation: BaseOperation, MultipartUploadSubmitPartProtocol {
    // MARK: - Internal Properties

    let part: Int
    var responseEtag: String?
    var response: DefaultDataResponse?
    var didFail: Bool = false

    private(set) lazy var progress: Progress = {
        let progress = MirroredProgress()

        progress.totalUnitCount = Int64(partSize)

        return progress
    }()

    // MARK: - Private Properties

    private var retriesLeft = Defaults.maxRetries
    private var chunkSize: Int = 0
    private var beforeCommitCheckPointOperation: BlockOperation?

    private let offset: UInt64
    private let partSize: Int

    private let chunkUploadOperationUnderlyingQueue = DispatchQueue(label: "com.filestack.chunk-upload-operation-queue",
                                                                    qos: .utility,
                                                                    attributes: .concurrent)

    private(set) lazy var chunkUploadOperationQueue: OperationQueue = {
        let queue = OperationQueue()

        queue.underlyingQueue = chunkUploadOperationUnderlyingQueue
        queue.maxConcurrentOperationCount = descriptor.options.chunkUploadConcurrency

        return queue
    }()

    private let descriptor: UploadDescriptor

    // MARK: - Lifecycle

    required init(offset: UInt64, part: Int, partSize: Int, descriptor: UploadDescriptor) {
        self.offset = offset
        self.part = part
        self.partSize = partSize
        self.descriptor = descriptor

        super.init()

        state = .ready
    }
}

// MARK: - Operation Overrides

extension MultipartIntelligentUploadSubmitPartOperation {
    override func main() {
        upload()
    }

    override func cancel() {
        super.cancel()
        didFail = true
        chunkUploadOperationQueue.cancelAllOperations()
    }
}

// MARK: - Private Functions

private extension MultipartIntelligentUploadSubmitPartOperation {
    func upload() {
        chunkSize = Defaults.resumableMobileChunkSize

        beforeCommitCheckPointOperation = BlockOperation()
        beforeCommitCheckPointOperation?.completionBlock = { self.doCommit() }

        var chunkOffset: UInt64 = 0

        while chunkOffset < UInt64(partSize) {
            if isCancelled || isFinished {
                chunkUploadOperationQueue.cancelAllOperations()
                break
            }

            // Guard against EOF
            guard let chunkOperation = addChunkOperation(chunkOffset: chunkOffset, chunkSize: chunkSize) else { break }

            let actualChunkSize = chunkOperation.progress.totalUnitCount

            progress.addChild(chunkOperation.progress, withPendingUnitCount: Int64(actualChunkSize))
            chunkOffset += UInt64(actualChunkSize)
        }

        if let beforeCommitCheckPointOperation = beforeCommitCheckPointOperation {
            chunkUploadOperationQueue.addOperation(beforeCommitCheckPointOperation)
        }
    }

    func doCommit() {
        // Try to commit operation with retries.
        while !didFail, retriesLeft > 0 {
            let commitOperation = MultipartUploadCommitOperation(descriptor: descriptor, part: part)

            chunkUploadOperationQueue.addOperation(commitOperation)
            chunkUploadOperationQueue.waitUntilAllOperationsAreFinished()

            let jsonResponse = commitOperation.response
            let isNetworkError = jsonResponse?.response == nil && jsonResponse?.error != nil

            // Check for any error response.
            if jsonResponse?.response?.statusCode != 200 || isNetworkError, retriesLeft > 0 {
                let delay = isNetworkError ? 0 : pow(2, Double(Defaults.maxRetries - retriesLeft))
                // Retrying in `delay` seconds
                Thread.sleep(forTimeInterval: delay)
            } else {
                break
            }

            retriesLeft -= 1
        }

        if retriesLeft == 0 {
            didFail = true
        }

        state = .finished
        beforeCommitCheckPointOperation = nil
    }

    func addChunkOperation(chunkOffset: UInt64, chunkSize: Int) -> MultipartUploadSubmitChunkOperation? {
        descriptor.reader.seek(position: offset + chunkOffset)

        let dataChunk = descriptor.reader.read(amount: chunkSize)

        guard !dataChunk.isEmpty else { return nil }

        let operation = MultipartUploadSubmitChunkOperation(data: dataChunk,
                                                            offset: chunkOffset,
                                                            part: part,
                                                            descriptor: descriptor)

        weak var weakOperation = operation

        let checkpointOperation = BlockOperation {
            guard let operation = weakOperation else { return }
            guard operation.isCancelled == false else { return }

            if operation.receivedResponse?.error != nil {
                // Network error
                guard self.retriesLeft > 0 else {
                    self.failOperation()
                    return
                }

                self.retriesLeft -= 1

                guard self.addChunkOperation(chunkOffset: operation.offset, chunkSize: self.chunkSize) != nil else { return }
            } else if let response = operation.receivedResponse?.response {
                switch response.statusCode {
                case 200:
                    // NO-OP
                    break
                default:
                    // Server error
                    guard chunkSize > Defaults.minimumPartChunkSize else {
                        self.failOperation()
                        return
                    }

                    // Enqueue 2 chunks corresponding to the 2 halves of the failed chunk.
                    let newPartChunkSize = chunkSize / 2
                    self.chunkSize = newPartChunkSize
                    var partOffset = operation.offset

                    for _ in 1 ... 2 {
                        guard self.addChunkOperation(chunkOffset: partOffset,
                                                     chunkSize: newPartChunkSize) != nil else { break }

                        partOffset += UInt64(newPartChunkSize)
                    }
                }
            }
        }

        checkpointOperation.addDependency(operation)
        chunkUploadOperationQueue.addOperation(operation)
        chunkUploadOperationQueue.addOperation(checkpointOperation)

        beforeCommitCheckPointOperation?.addDependency(operation)
        beforeCommitCheckPointOperation?.addDependency(checkpointOperation)

        return operation
    }

    func failOperation() {
        didFail = true
        state = .finished
        chunkUploadOperationQueue.cancelAllOperations()
    }
}

// MARK: - Defaults

private extension MultipartIntelligentUploadSubmitPartOperation {
    struct Defaults {
        static let resumableMobileChunkSize = 1 * Int(pow(Double(1024), Double(2)))
        static let resumableDesktopChunkSize = 8 * Int(pow(Double(1024), Double(2)))
        static let minimumPartChunkSize = 32768
        static let maxRetries: Int = 5
    }
}
