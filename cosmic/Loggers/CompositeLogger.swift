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

    func onReceive(_ messages: [String], logLevel: LogLevel) {
        loggers.forEach { logger in
            messages.forEach {
                switch logLevel {
                case .debug:
                    logger.debug($0)
                    break
                case .info:
                    logger.log($0)
                    break
                case .warn:
                    logger.warn($0)
                    break
                case .error:
                    logger.error($0)
                    break
                case .none: break
                }
            }
        }
    }
    
}
