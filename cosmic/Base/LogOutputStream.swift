//
//  LogOutputStream.swift
//  Cosmic
//
//  Created by Jack Newcombe on 14/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

internal class LogOutputStream: TextOutputStream {
    
    func write(_ string: String) {
        fatalError("This method must be reimplemented in a subclass")
    }
    
}

internal class StandardOutputStream: LogOutputStream {
    
    let fileHandle = FileHandle.standardOutput
    
    override func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            fileHandle.write(data)
        }
    }
    
}

internal class StandardErrorStream: LogOutputStream {
    
    override func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
    
}
