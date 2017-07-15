//
//  JSONFormatter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 19/04/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

typealias JSONClosure<T> = () -> T

typealias JSONFormatterDictionary = [String: Any]

typealias JSONFormatterConverterCompletion = (String) -> JSONFormatterDictionary

protocol JSONFormatterConverter {
    
    /// <#Description#>
    var converter: JSONFormatterConverterCompletion { get }
    
    func toJSON(message: String) -> String?
    
}


/// Converts a string-based textual message into string-based JSON
class JSONFormatter: LogFormatter, JSONFormatterConverter  {
    
    let converter: JSONFormatterConverterCompletion
    
    var options: JSONSerialization.WritingOptions = []
    
    init(converter: @escaping JSONFormatterConverterCompletion) {
        self.converter = converter
    }
    
    func toJSON(message: String) -> String? {
        let dict = self.converter(message)
        return JSONSerialization.string(withJSONObject: dict, options: options)
    }
    
    func format(message: String) -> String {
        guard let string = toJSON(message: message) else { return message }
        return string
    }
    
    
}

// MARK: NewLineBatchFormatter

public class JSONBatchFormatter: BatchFormatter {
    
    private let jsonFormatter: JSONFormatter
    
    init(converter: @escaping JSONFormatterConverterCompletion) {
        jsonFormatter = JSONFormatter(converter: converter)
    }
    
    public func format(message: String) -> String {
        return jsonFormatter.format(message: message)
    }
    
    public func format(batch: [String]) -> String {
        return batch.map({ format(message: $0) }).joined(separator: "\n")
    }
    
}
