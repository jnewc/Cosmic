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
    
    internal var cache: LogCache = LogCache()

    public required init() { }

    internal func onReceive(_ messages: [String], logLevel: LogLevel) {
        self.cache.addEntry(with: messages, logLevel: logLevel)
    }
    
    
}
