//
//  JSONFormatter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 19/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

typealias JSONFormatterConverterCompletion = (String) -> [String: String]

protocol JSONFormatterConverter {
    
    /// <#Description#>
    var converter: JSONFormatterConverterCompletion { get }
    
    func toJSON(message: String) -> Data?
    
}


/// Converts a string-based textual message into string-based JSON
class JSONFormatter: LogFormatter, JSONFormatterConverter  {
    
    let converter: JSONFormatterConverterCompletion
    
    init(converter: @escaping JSONFormatterConverterCompletion) {
        self.converter = converter
    }
    
    func toJSON(message: String) -> Data? {
        let dict = self.converter(message)
        return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
    
    func format(message: String) -> String {
        guard let data = toJSON(message: message) else { return message }
        return String(data: data, encoding: .utf8) ?? message
    }
    
    
}
