//
//  LogFilter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 14/07/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

/// LogFilter
public protocol LogFilter {
    
    func isFiltered<T: Logger>(logger: T) -> Bool
}


/// A class that holds global log filters
public final class LogFilters {
    
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
public class ClassBasedLogFilter: LogFilter {
    
    private var included: [String: LogLevel]
    
    private var excluded: [String: LogLevel]
    
    init(included: [String: LogLevel] = [:], excluded: [String: LogLevel] = [:]) {
        self.included = included
        self.excluded = excluded
    }
    
    public func include<T>(type: T.Type, logLevel: LogLevel) where T: Logger {
        self.included[String(describing: type)] = logLevel
    }
    
    public func exclude<T>(type: T.Type, logLevel: LogLevel) where T: Logger {
        self.excluded[String(describing: type)] = logLevel
    }
    
    public func isFiltered<T>(logger: T) -> Bool where T : Logger {
        
        if included.count > 0 {
            if let level = included[String(describing: T.self)]?.rawValue {
                return logger.logLevel.rawValue < level
            } else {
                return true
            }
        }
        
        if excluded.count > 0, let level = excluded[String(describing: T.self)]?.rawValue {
            return logger.logLevel.rawValue <= level
        }
        
        return false
    }
    
}

