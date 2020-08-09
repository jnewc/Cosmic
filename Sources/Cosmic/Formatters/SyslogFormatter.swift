//
//  SyslogFormatter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 29/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

/// Formatter for generating syslog messages conforming to the
/// RFC 5424 standard.
class SyslogFormatter: LogFormatter {
    
    
    /// The Syslog version value. At time of writing
    /// '1' is the only acceptable value.
    let SyslogVersion: String = "1"
    
    /// The Syslog facility value (mail system)
    /// See: https://tools.ietf.org/html/rfc5424#section-6.2.1
    let SyslogFacility = 16
    
    /// The syslog sendername value
    let SyslogSenderName: String = "Cosmic"
    
    /// The Syslog sender value. This should be configured to
    /// a name describing the calling application or service
    var sender: String = Bundle.main.bundleIdentifier ?? "Unknown"

    func syslogHeader(_ logLevel: LogLevel) -> String {
        return "<\(SyslogFacility + logLevel.syslogSeverity)>\(SyslogVersion)"
    }

    func format(message: String, logLevel: LogLevel, metadata: LogMetadata) -> String {
        let timestamp = Date().iso8601
        return "\(syslogHeader(logLevel)) \(timestamp) \(SyslogSenderName) \(sender) - - - \(message)"
    }
    
}

