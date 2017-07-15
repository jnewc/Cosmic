//
//  LogFilter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 14/07/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

/// This cache contains all filters to be applied to loggers
internal var FilterCache: [LogFilter] = []


/// LogFilter
protocol LogFilter {
    
    func isFiltered<T: Logger>(logger: T) -> Bool
}


/// A class that holds global log filters
class LogFilters {
    
    public static func addFilter(filter: LogFilter) {
        FilterCache.append(filter)
    }
    
    public static func clearFilters() {
        FilterCache.removeAll()
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

