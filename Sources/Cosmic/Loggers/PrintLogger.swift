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

    internal var errorStream: LogOutputStream = StandardErrorStream()
    
    
    public required init() { }

    func onReceive(_ messages: [String], logLevel: LogLevel) {
        messages.forEach { printLine($0) }
    }
    
    fileprivate func printLine(_ line: String) {
        let message = "\(prefix)\(line)\(suffix)"
        
        if logLevel == .error {
            print(message, to: &errorStream)
        } else {
            print(message, to: &stream)
        }
    }
    
}
