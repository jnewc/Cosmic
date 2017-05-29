//: Playground - noun: a place where people can play

import UIKit
import cosmic

var str = "Hello, playground"

class LikesToLog: LogReporter {
    
    init() {
    }
    
    func logSomething() {
        self.logger.log("Log some stuff")
        
        self.logger.warn("Warn message")
        
    }
    
}

let likesToLog: LikesToLog = LikesToLog()

likesToLog.logSomething()