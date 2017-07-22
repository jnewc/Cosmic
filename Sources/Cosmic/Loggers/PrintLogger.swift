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

    public var prefix: String = ""
    
    public var suffix: String = ""
    
    internal var stream: LogOutputStream = StandardOutputStream()

    internal var errorStream: LogOutputStream = StandardErrorStream()
    
    
    public required init() { }

    public func log(_ message: String, logLevel: LogLevel, metadata: LogMetadata) {
        printLine(message)
    }
    
    fileprivate func printLine(_ line: String) {
        let message = "\(prefix)\(line)\(suffix)"
        
        if logLevel == .error {
            print(message, to: &errorStream)
        } else {
            print(message, to: &stream)
        }
    }
    
}
