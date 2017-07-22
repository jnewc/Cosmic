//
//  LogCache.swift
//  Cosmic
//
//  Created by Jack Newcombe on 30/05/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

struct LogCacheEntry {
    
    let logLevel: LogLevel
    
    let message: String
    
    let metadata: LogMetadata

    let created: Date = Date()
    
}


class LogCache {
    
    fileprivate var entries: [LogCacheEntry] = []
    
    init() { }
    
    func addEntry(with message: String, logLevel: LogLevel, metadata: LogMetadata) {
        let entry = LogCacheEntry(logLevel: logLevel, message: message, metadata: metadata)
        entries.append(entry)
    }
    
    func entriesFor(logLevel: LogLevel) -> [LogCacheEntry] {
        return entries.filter { $0.logLevel == logLevel }
    }
    
}
