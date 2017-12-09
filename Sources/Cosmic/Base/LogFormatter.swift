//
//  LogFormatter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 19/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public protocol LogFormatter {
    
    func format(message: String, metadata: LogMetadata) -> String
    
}

// MARK: BasicLogFormatter


/// A basic formatter that optionally adds a prefix and/or suffix
/// to a log message
open class BasicLogFormatter: LogFormatter {
    
    internal var prefix: String = ""
    
    internal var suffix: String = ""
    
    public init() { }
    
    public init(prefix: String, suffix: String = "") {
        self.prefix = prefix
        self.suffix = suffix
    }
    
    func prefix(for metadata: LogMetadata) -> String {
        return "[\(metadata.filename) → \(metadata.function):\(metadata.line)] "
    }
    
    public func format(message: String, metadata: LogMetadata) -> String {
        return "\(prefix(for: metadata))\(prefix)\(message)\(suffix)"
    }
}

// MARK: DateLogFormatter

/// Prepends a date to a log message
open class DateLogFormatter: BasicLogFormatter {

    let dateFormatter = DateFormatter()
    
    override public func format(message: String, metadata: LogMetadata) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        self.prefix = date
        return super.format(message: " \(message)", metadata: metadata)
    }
    
}

// MARK: BatchFormatter

public protocol BatchFormatter: LogFormatter {
    
    func format (batch: [(String, LogMetadata)]) -> String
    
}

// MARK: NewLineBatchFormatter

public class NewLineBatchFormatter: BatchFormatter {
    
    public func format(message: String, metadata: LogMetadata) -> String {
        return message
    }
    
    public func format(batch: [(String, LogMetadata)]) -> String {
        return batch.map({ format(message: $0.0, metadata: $0.1) }).joined(separator: "\n")
    }
    
}
