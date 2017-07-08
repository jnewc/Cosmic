//
//  Extensions.swift
//  Cosmic
//
//  Created by Jack Newcombe on 29/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

extension JSONSerialization {
    
    
    /// Convenience method for generating a JSON string from a Foundation object
    ///
    /// - Parameters:
    ///   - obj: The JSON object to convert to a JSON string
    ///   - opt: JSON serialization options
    /// - Returns: A JSON string, or nil if the object can not be converted to JSON
    /// - Throws: A JSON serialization error
    open class func string(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions = []) throws -> String? {
        let data = try self.data(withJSONObject: obj, options: opt)
        return String(data: data, encoding: .utf8)
    }
    
}
