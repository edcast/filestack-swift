//
//  Security.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Represents a security object.
///
/// See [Security Overview](https://www.filestack.com/docs/security) for more information about security.
@objc(FSSecurity)
public class Security: NSObject {
    // MARK: - Properties

    /// An encoded policy.
    public let encodedPolicy: String

    /// A computed signature.
    public let signature: String

    // MARK: - Lifecycle

    /// A convenience initializer that takes a `Policy` and an `appSecret` as parameters.
    ///
    /// - SeeAlso: `Policy`
    ///
    /// - Parameter policy: A configured `Policy` object.
    /// - Parameter appSecret: A secret taken from the developer portal.
    @objc public convenience init(policy: Policy, appSecret: String) throws {
        let policyJSON: Data = try policy.toJSON()
        let encodedPolicy: String = policyJSON.base64EncodedString()
        let signature = encodedPolicy.hmac(algorithm: .sha256, key: appSecret)

        self.init(encodedPolicy: encodedPolicy, signature: signature)
    }

    /// The designated initializer.
    ///
    /// - SeeAlso: `init(policy:appSecret)`.
    ///
    /// - Parameter encodedPolicy: An encoded policy.
    /// - Parameter signature: A computed signature.
    @objc public init(encodedPolicy: String, signature: String) {
        self.encodedPolicy = encodedPolicy
        self.signature = signature
    }
}

// MARK: - CustomStringConvertible Conformance

extension Security {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
