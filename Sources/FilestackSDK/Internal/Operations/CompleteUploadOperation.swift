//
//  CompleteUploadOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/25/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

class CompleteUploadOperation: BaseOperation<JSONResponse> {
    // MARK: - Private Properties

    private let partsAndEtags: [Int: String]
    private let descriptor: UploadDescriptor
    private var retrier: TaskRetrier<JSONResponse>?

    // MARK: - Lifecycle

    required init(partsAndEtags: [Int: String], descriptor: UploadDescriptor) {
        self.partsAndEtags = partsAndEtags
        self.descriptor = descriptor

        super.init()
    }

    // MARK: - BaseOperation Overrides

    override func finish(with result: BaseOperation<JSONResponse>.Result) {
        retrier = nil

        super.finish(with: result)
    }
}

// MARK: - Overrides

extension CompleteUploadOperation {
    override func main() {
        upload()
    }

    override func cancel() {
        super.cancel()

        retrier?.cancel()
    }
}

// MARK: - Private Functions

private extension CompleteUploadOperation {
    func upload() {
        let uploadURL = URL(string: "multipart/complete", relativeTo: Constants.uploadURL)!
        let headers = ["Content-Type": "application/json"]

        retrier = .init(attempts: Defaults.maxRetries, label: uploadURL.relativePath) { (semaphore) -> JSONResponse? in
            var jsonResponse: JSONResponse?

            guard let payload = self.payload() else { return nil }

            UploadService.shared.upload(data: payload, to: uploadURL, method: "POST", headers: headers) { (data, response, error) in
                jsonResponse = JSONResponse(response: response, data: data, error: error)
                semaphore.signal()
            }

            semaphore.wait()

            guard jsonResponse?.response?.statusCode == 200 else { return nil }

            return jsonResponse
        }

        if let response = retrier?.run() {
            finish(with: .success(response))
        } else {
            finish(with: .failure(.custom("Failed to complete /multipart/complete operation.")))
        }
    }

    func payload() -> Data? {
        var payload: [String: Any] = [
            "apikey": descriptor.config.apiKey,
            "uri": descriptor.uri,
            "region": descriptor.region,
            "upload_id": descriptor.uploadID,
            "filename": descriptor.filename,
            "mimetype": descriptor.mimeType,
            "size": descriptor.filesize,
            "store": descriptor.options.storeOptions.asDictionary()
        ]

        if let security = descriptor.config.security {
            payload["policy"] = security.encodedPolicy
            payload["signature"] = security.signature
        }

        if descriptor.useIntelligentIngestion {
            payload["fii"] = true
        } else {
            payload["parts"] = partsAndEtags.map { ["part_number": $0.key, "etag": $0.value] }
        }

        if !descriptor.options.uploadTags.isEmpty {
            payload["upload_tags"] = descriptor.options.uploadTags
        }

        return try? JSONSerialization.data(withJSONObject: payload)
    }
}

// MARK: - Defaults

private extension CompleteUploadOperation {
    struct Defaults {
        static let maxRetries = 5
    }
}
