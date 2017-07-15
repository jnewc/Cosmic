//
//  LogCache.swift
//  Cosmic
//
//  Created by Jack Newcombe on 30/05/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

struct LogCacheEntry {
    
    let created: Date = Date()
    
    let logLevel: LogLevel
    
    let message: String
    
    init(logLevel: LogLevel, message: String) {
        self.logLevel = logLevel
        self.message = message
    }
    
}


class LogCache {
    
    fileprivate var entries: [LogCacheEntry] = []
    
    init() { }
    
    func addEntry(with message: String, logLevel: LogLevel) {
        let entry = LogCacheEntry(logLevel: logLevel, message: message)
        entries.append(entry)
    }
    
    func entriesFor(logLevel: LogLevel) -> [LogCacheEntry] {
        return entries.filter { $0.logLevel == logLevel }
    }
    
}
