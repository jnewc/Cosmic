//
//  Logger.swift
//  cosmic
//
//  Created by Jack Newcombe on 27/03/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation


public struct LogMetadata {
    
    let file: StaticString
    
    let line: UInt
    
    let function: StaticString
    
    public init(file: StaticString = #file, line: UInt = #line, function: StaticString = #function) {
        self.file = file
        self.line = line
        self.function = function
    }
    
    // MARK: Computed properties
    
    var filename: String {
        return "\(file)".components(separatedBy: "/").last ?? "\(file)"
    }
}


/// Logger describes the internal implementation of a Logger object.
///
/// Implementors consume log output, performing transformations on the
/// received messages as needed, and forwarding them to other loggers
/// and reporting services.
///
public protocol Logger: class {
    
    init()
    
    // MARK: Logging properties
    
    /// Indicates the current level of logging.
    ///
    /// The log level of a Logger indicates:
    ///  - The class of logs that should be logged
    ///  - The classes of augmentation that should be applied to logs
    var logLevel: LogLevel { get set }
    
    
    /// A list of formatters to apply to logs
    ///
    /// Formatters transform logs from one string-based representation to another. Each
    /// formatter will be applied to every message, so any filtering should be done
    /// within the formatter itself.
    var formatters: [LogFormatter] { get set }
    
    func log(_ message: String, logLevel: LogLevel, metadata: LogMetadata)
    
}

public extension Logger {
        
    /// Returns true if this logger is currently being filtered.
    ///
    /// See LogReporter for more details.
    private var isFiltered: Bool {
        return LogFilters.global.filters.reduce(false) { $0 || $1.isFiltered(logger: self) }
    }
    
    /// Returns true if the log level is equal to or more constraining
    /// than the argument, and the logger is not being filtered
    ///
    /// - Parameter expected: The log level to test
    /// - Returns: A boolean value indicating whether the log level is enabled
    private func enabled(_ expected: LogLevel) -> Bool {
        return (expected.rawValue >= logLevel.rawValue) && !self.isFiltered
    }

    
    // MARK: debug
    
    /// Logs a series of debug messages
    ///
    /// Debug log messages should be aimed at developers and can contain
    /// domain-specific and diagnostic information.
    ///
    /// - Parameter messages: The messages to log
    public func debug(_ message: String, file: StaticString = #file, line: UInt = #line, function: StaticString = #function) {
        guard enabled(.debug) else { return }
        let metadata = LogMetadata(file: file, line: line, function: function)
        log(format(message, metadata), logLevel: .debug, metadata: metadata)
    }
    
    // MARK: info
    
    /// Logs a series of info messages
    ///
    /// Info log messages should contain high-level information about
    /// application state such as indicating a service starting or 
    /// stopping. 
    ///
    /// Info logs should describe all high-level interactions.
    ///
    /// - Parameter messages: The info messages to log
    public func info(_ message: String, file: StaticString = #file, line: UInt = #line, function: StaticString = #function) {
        guard enabled(.info) else { return }
        let metadata = LogMetadata(file: file, line: line, function: function)
        log(format(message, metadata), logLevel: .info, metadata: metadata)
    }
    
    // MARK: warn
    
    /// Logs a series of warning messages
    ///
    /// Warning log messages should indicate any non-fatal issues that
    /// occur such as the absence of configuration or validation errors
    ///
    /// - Parameter messages: The warning messages to log
    public func warn(_ message: String, file: StaticString = #file, line: UInt = #line, function: StaticString = #function) {
        guard enabled(.warn) else { return }
        let metadata = LogMetadata(file: file, line: line, function: function)
        log(format(message, metadata), logLevel: .warn, metadata: metadata)
    }
    
    // MARK: error
    
    /// Logs a series of error messages
    ///
    /// Error log messages should contain information about any fatal
    /// errors, i.e. errors that halt the execution of the application
    /// whether by runtime exception or blocking further interaction.
    ///
    /// Error logs should generally indicate that a programming error
    /// has occurred (for example, by reaching illegal if/else branches)
    ///
    /// - Parameter messages: The error messages to log
    public func error(_ message: String, file: StaticString = #file, line: UInt = #line, function: StaticString = #function) {
        guard enabled(.error) else { return }
        let metadata = LogMetadata(file: file, line: line, function: function)
        log(format(message, metadata), logLevel: .error, metadata: metadata)
    }
    
    internal func format(_ message: String, _ metadata: LogMetadata) -> String {
        return formatters.reduce(message, { $1.format(message: $0, metadata: metadata) })
    }
}
