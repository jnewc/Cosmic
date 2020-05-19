//
//  PrintLogger.swift
//  cosmic
//
//  Created by Jack Newcombe on 27/03/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public class PrintLogger: Logger {
    
    public var logLevel: LogLevel = .info

    public var formatters: [LogFormatter] = []

    /// An optional prefix for each message logged.
    /// Defaults to an empty string.
    public var prefix: String = ""
    
    /// An optional suffix for each message logged.
    /// Defaults to an empty string.
    public var suffix: String = ""
        
    /// The terminator for each line printed
    /// This is used as the `terminator` argument for the `print` function.
    public var terminator: String = "\n"
    
    internal var stream: LogOutputStream = StandardOutputStream()

    internal var errorStream: LogOutputStream = StandardErrorStream()
    
    public required init() { }

    public func log(_ message: String, logLevel: LogLevel, metadata: LogMetadata) {
        printLine(message)
    }
    
    fileprivate func printLine(_ line: String) {
        let message = "\(prefix)\(line)\(suffix)"
        
        if logLevel == .error {
            print(message, terminator: terminator, to: &errorStream)
        } else {
            print(message, terminator: terminator, to: &stream)
        }
    }
    
}
