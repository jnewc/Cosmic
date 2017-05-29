//
//  Formatters.swift
//  Cosmic
//
//  Created by Jack Newcombe on 17/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation


/// Formatter for generating syslog messages conforming to the
/// RFC 5424 standard.
class SyslogFormatter: LogFormatter {
    
    
    /// The Syslog version value. At time of writing
    /// '1' is the only acceptable value.
    let SyslogVersion: String = "1"
    
    /// The Syslog priority value
    /// See: https://tools.ietf.org/html/rfc5424#section-6.2.1
    let SyslogPriority: String = "22"
    
    /// The syslog sendername value
    let SyslogSenderName: String = "Cosmic"
    
    var SyslogHeader: String { return "<\(SyslogPriority)>\(SyslogVersion)" }
    
    /// The Syslog sender value. This should be configured to
    /// a name describing the calling application or service
    var sender: String = Bundle.main.bundleIdentifier ?? "Unknown"
    
    func format(message: String) -> String {
        let timestamp = Date().iso8601
        return "\(SyslogHeader) \(timestamp) \(SyslogSenderName) \(sender) - - - \(message)"
    }
    
}

// MARK: DateFormatter and Date extensions

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

extension Date {
    var iso8601: String {
        return DateFormatter.iso8601.string(from: self)
    }
}
