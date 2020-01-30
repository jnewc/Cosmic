//
//  CompositeLogger.swift
//  cosmic
//
//  Created by Jack Newcombe on 27/03/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

open class CompositeLogger: Logger {
    
    public var loggers: [Logger] = []
    
    public var formatters: [LogFormatter] = []
    
    public var logLevel: LogLevel = .info {
        didSet {
            loggers.forEach { $0.logLevel = logLevel }
        }
    }
    
    public required init() { }
    
    public init(loggers: Logger...) {
        self.loggers.append(contentsOf: loggers)
    }

    public func log(_ message: String, logLevel: LogLevel, metadata: LogMetadata) {
        loggers.forEach { logger in
            let formattedMessage = formatters.reduce(message) { message, formatter in
                return formatter.format(message: message, logLevel: logLevel, metadata: metadata)
            }
            logger.log(formattedMessage, logLevel: logLevel, metadata: metadata)
        }
    }
    
}
