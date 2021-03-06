//
//  PDFInfoTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 6/18/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Gets information about a PDF document.
///
/// For more information see https://www.filestack.com/docs/api/processing/#pdf-info
public class PDFInfoTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `PDFInfoTransform` object.
    public init() {
        super.init(name: "pdfinfo")
    }
}

// MARK: - Public Functions

public extension PDFInfoTransform {
    /// Adds the `colorinfo` option.
    @discardableResult
    func colorInfo() -> Self {
        return appending(key: "colorinfo", value: true)
    }
}
