//
//  LogCache.swift
//  Cosmic
//
//  Created by Jack Newcombe on 30/05/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public struct LogCacheEntry {
    
    public let logLevel: LogLevel
    
    public let message: String
    
    public let metadata: LogMetadata

    public let created: Date = Date()
    
}


public class LogCache {
    
    public private(set) var entries: [LogCacheEntry] = []
    
    init() { }
    
    func addEntry(with message: String, logLevel: LogLevel, metadata: LogMetadata) {
        let entry = LogCacheEntry(logLevel: logLevel, message: message, metadata: metadata)
        entries.append(entry)
    }
    
    public func entriesFor(logLevel: LogLevel) -> [LogCacheEntry] {
        return entries.filter { $0.logLevel == logLevel }
    }
    
}
