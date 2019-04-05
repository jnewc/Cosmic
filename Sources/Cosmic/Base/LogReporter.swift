//
//  LogReporter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 27/03/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation


/// This cache contains loggers for every registered identifier
fileprivate var LoggerCache: [String: Logger] = [:]

public protocol LogReporter {
    
    associatedtype DefaultLoggerType: Logger
    
}

public extension LogReporter {

    func createLogger<T: Logger>(with type: T.Type) -> T {
        
        if !LoggerCache.keys.contains(className) {
            LoggerCache[className] = T.init()
        }
        
        return LoggerCache[className] as! T
        
    }
    
    var logger: DefaultLoggerType {
        return self.createLogger(with: DefaultLoggerType.self)
    }
    
    
    var className: String  {
        return String(describing: type(of: self))
    }
    
}


public protocol DefaultLogReporter: LogReporter {
    
    associatedtype DefaultLoggerType = PrintLogger
    
}
