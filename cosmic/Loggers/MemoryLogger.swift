//
//  MemoryLogger.swift
//  cosmic
//
//  Created by Jack Newcombe on 27/03/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation


public class MemoryLogger: LogReceiver {
  
    typealias LogMessage = (logLevel: LogLevel, message: String)

    public var logLevel: LogLevel = .info
    
    public var formatters: [LogFormatter] = []
    
    internal var messages: [LogMessage] = []

    public required init() { }

    internal func onDebug(_ messages: [String]) {
        let logs: [LogMessage] = messages.map { (.debug, $0) }
        self.messages.append(contentsOf: logs)
    }
    
    internal func onLog(_ messages: [String]) {
        let logs: [LogMessage] = messages.map { (.info, $0) }
        self.messages.append(contentsOf: logs)
    }
    
    internal func onWarn(_ messages: [String]) {
        let logs: [LogMessage] = messages.map { (.warn, $0) }
        self.messages.append(contentsOf: logs)
    }
    
    internal func onError(_ messages: [String]) {
        let logs: [LogMessage] = messages.map { (.error, $0) }
        self.messages.append(contentsOf: logs)
    }
   
    
    
}
