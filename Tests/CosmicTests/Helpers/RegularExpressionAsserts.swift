//
//  RegularExpressionAsserts.swift
//  Cosmic
//
//  Created by Jack Newcombe on 24/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest

func XCTAssertMatches(input: String, pattern: String) {
    
    let re = try! NSRegularExpression(pattern: pattern, options: [])
    let  range = NSRange(location: 0, length: input.count)
    let matches = re.matches(in: input, options: [], range: range)
    
    // Asserts that the pattern matches the entire range
    XCTAssert(matches.count > 0 && matches.first!.range == range)
}
