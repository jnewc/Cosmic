//
//  PrintLogger.swift
//  cosmic
//
//  Created by Jack Newcombe on 27/03/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public class PrintLogger: LogReceiver {
    
    public var logLevel: LogLevel = .info

    public var formatters: [LogFormatter] = []

    public var prefix: String = ""
    
    public var suffix: String = ""
    
    internal var stream: LogOutputStream = StandardOutputStream()
    
    
    public required init() { }

    internal func onDebug(_ messages: [String]) {
        messages.forEach { printLine($0) }
    }
    
    internal func onLog(_ messages: [String]) {
        messages.forEach { printLine($0) }
    }
    
    internal func onWarn(_ messages: [String]) {
        messages.forEach { printLine($0) }
    }
    
    internal func onError(_ messages: [String]) {
        messages.forEach { printLine($0) }
    }
    
    fileprivate func printLine(_ line: String) {
        let message = "\(prefix)\(line)\(suffix)"
        
        print(message, to: &stream)
    }
    
}
