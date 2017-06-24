//
//  RegularExpressionAsserts.swift
//  Cosmic
//
//  Created by Jack Newcombe on 24/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import XCTest

extension NSRange: Equatable {
    public static func ==(lhs: _NSRange, rhs: _NSRange) -> Bool {
        return lhs.location == rhs.location && lhs.length == rhs.length
    }
}

func XCTAssertMatches(input: String, pattern: String) {
    
    let re = try! NSRegularExpression(pattern: pattern, options: [])
    let  range = NSRange(location: 0, length: input.characters.count)
    let matches = re.matches(in: input, options: [], range: range)
    
    // Asserts that the pattern matches the entire range
    XCTAssert(matches.count > 0 && matches.first!.range == range)
}
