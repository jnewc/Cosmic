//
//  Extensions.swift
//  Cosmic
//
//  Created by Jack Newcombe on 05/02/2019.
//  Copyright © 2019 Jack Newcombe. All rights reserved.
//

import XCTest
import Foundation

extension XCTestCase {
    
    var isRunningInXcode: Bool {
        return ProcessInfo.processInfo.environment.keys.contains("SIMULATOR_UDID")
    }
    
}
