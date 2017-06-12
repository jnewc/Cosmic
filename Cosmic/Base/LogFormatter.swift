//
//  LogFormatter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 19/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public protocol LogFormatter {
    
    func format(message: String) -> String
    
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
    
    public func format(message: String) -> String {
        return "\(prefix)\(message)\(suffix)"
    }
}

// MARK: DateLogFormatter

/// Prepends a date to a log message
open class DateLogFormatter: BasicLogFormatter {

    let dateFormatter = DateFormatter()
    
    override public func format(message: String) -> String {
        let date = dateFormatter.string(from: Date())
        self.prefix = date
        return super.format(message: " \(message)")
    }
    
}

// MARK: BatchFormatter

public protocol BatchFormatter: LogFormatter {
    
    func format (batch: [String]) -> String
    
}

// MARK: NewLineBatchFormatter

public class NewLineBatchFormatter: BatchFormatter {
    
    public func format(message: String) -> String {
        return message
    }
    
    public func format(batch: [String]) -> String {
        return batch.joined(separator: "\n")
    }
    
}
