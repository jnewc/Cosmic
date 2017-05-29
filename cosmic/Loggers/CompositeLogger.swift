//
//  CompositeLogger.swift
//  cosmic
//
//  Created by Jack Newcombe on 27/03/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

open class CompositeLogger: LogReceiver {
    
    public var loggers: [Logger] = []
    
    public var formatters: [LogFormatter] = []
    
    public var logLevel: LogLevel = .info
    
    public required init() { }
    
    public init(loggers: Logger...) {
        self.loggers.append(contentsOf: loggers)
    }

    public func onDebug(_ messages: [String]) {
        loggers.forEach { logger in messages.forEach { logger.debug($0) } }
    }

    public func onLog(_ messages: [String]) {
        loggers.forEach { logger in messages.forEach { logger.log($0) } }
    }
    
    public func onWarn(_ messages: [String]) {
        loggers.forEach { logger in messages.forEach { logger.warn($0) } }
    }

    public func onError(_ messages: [String]) {
        loggers.forEach { logger in messages.forEach { logger.error($0) } }
    }

    
}
