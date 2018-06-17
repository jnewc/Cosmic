//
//  MemoryLogger.swift
//  cosmic
//
//  Created by Jack Newcombe on 27/03/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation


public class MemoryLogger: Logger {

  
    typealias LogMessage = (logLevel: LogLevel, message: String)

    public var logLevel: LogLevel = .info
    
    public var formatters: [LogFormatter] = []
    
    public internal(set) var cache: LogCache = LogCache()

    public required init() { }

    public func log(_ message: String, logLevel: LogLevel, metadata: LogMetadata) {
        self.cache.addEntry(with: message, logLevel: logLevel, metadata: metadata)
    }
    
}
