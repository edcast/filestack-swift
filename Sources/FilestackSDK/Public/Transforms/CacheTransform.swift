//
//  CacheTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 15/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/// Takes the file or files that are passed into it and compresses them into a zip file.
public class CacheTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `CacheTransform` object.
    public init() {
        super.init(name: "cache")
    }
}

// MARK: - Public Functions

public extension CacheTransform {
    /// Adds the `false` option.
    ///
    /// Set cache to false to ensure that you always receive a newly converted file.
    /// This setting is only recommended for testing purposes because every time a URL using cache=false loads,
    /// it will count against your conversion quota.
    @discardableResult
    func turnOff() -> Self {
        removeAllOptions()
        return appending(key: "false", value: nil)
    }

    /// Adds the `expiry` option.
    ///
    /// - Parameter value: Set the length in seconds to cache the file for. Valid range: 1...31536000
    @discardableResult
    func expiry(_ value: Int) -> Self {
        return appending(key: "expiry", value: value)
    }

    /// Adds the `expiry` option.
    ///
    /// Set the maximum length (1 year) to cache the file for.
    @discardableResult
    func maxExpiry() -> Self {
        return appending(key: "expiry", value: "max")
    }
}
