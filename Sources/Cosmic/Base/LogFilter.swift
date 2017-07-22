//
//  LogFilter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 14/07/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

/// LogFilter
protocol LogFilter {
    
    func isFiltered<T: Logger>(logger: T) -> Bool
}


/// A class that holds global log filters
class LogFilters {
    
    public static let global = LogFilters()
    
    var filters: [LogFilter] = []
    
    private init() { }
    
    public func addFilter(filter: LogFilter) {
        filters.append(filter)
    }
    
    public func clearFilters() {
        filters.removeAll()
    }
    
}


/// Filters logs based on their class
class ClassBasedLogFilter: LogFilter {
    
    var included: [Logger.Type] = []
    
    var excluded: [Logger.Type] = []
    
    func isFiltered<T>(logger: T) -> Bool where T : Logger {
        
        if included.count > 0 {
            return !included.contains { $0 == T.self }
        }
        
        if excluded.count > 0 {
            return excluded.contains { $0 == T.self }
        }
        
        return false
    }
    
}

