//
//  UploadService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation
import os.log

final class UploadService: NetworkingService {
    static let sessionManager = SessionManager.filestackDefault
    static let baseURL = Constants.uploadURL

    static func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                       url: URL,
                       queue: DispatchQueue? = .main,
                       completionHandler: @escaping (NetworkJSONResponse) -> Void) {
        sessionManager.upload(multipartFormData: multipartFormData, to: url) { result in
            switch result {
            case let .success(request, _, _):
                request.responseJSON(queue: queue) { response in
                    completionHandler(NetworkJSONResponse(with: response))
                }
            case let .failure(error):
                completionHandler(NetworkJSONResponse(with: error))
            }
        }
    }

    static func upload(data: Data,
                       to url: URLConvertible,
                       method: HTTPMethod,
                       headers: HTTPHeaders? = nil) -> UploadRequest? {
        if let dataURL = temporaryURL(using: data) {
            defer { try? FileManager.default.removeItem(at: dataURL) }
            return sessionManager.upload(dataURL, to: url, method: method, headers: headers)
        }

        return nil
    }
}

extension UploadService {
    static func temporaryURL(using data: Data) -> URL? {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let dataURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString)

        do {
            try data.write(to: dataURL)
            return dataURL
        } catch {
            os_log("Unable to create temporary data file at %@", log: .uploads, type: .fault, dataURL.description)
            return nil
        }
    }
}
