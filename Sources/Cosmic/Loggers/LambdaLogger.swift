//
//  LambdaLogger.swift
//  Cosmic
//
//  Created by Jack Newcombe on 16/04/2018.
//  Copyright © 2018 Jack Newcombe. All rights reserved.
//

import Foundation

public typealias LambdaLoggerCompletion = (_ message: String, _ level: LogLevel, _ metadata: LogMetadata) -> ()

public class LambdaLogger: Logger {
    
    typealias LogMessage = (logLevel: LogLevel, message: String)
    
    public var logLevel: LogLevel = .info
    
    public var formatters: [LogFormatter] = []
    
    public var completion: LambdaLoggerCompletion?
    
    public init(completion: @escaping LambdaLoggerCompletion) {
        self.completion = completion
    }
    
    public required init() { }
    
    public func log(_ message: String, logLevel: LogLevel, metadata: LogMetadata) {
        completion?(message, logLevel, metadata)
    }
    
}

public typealias λLogger = LambdaLogger
