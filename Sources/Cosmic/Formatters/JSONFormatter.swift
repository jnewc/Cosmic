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

    func toJSON(message: String, metadata: LogMetadata) -> String?

}


/// Converts a string-based textual message into string-based JSON
class JSONFormatter: LogFormatter, JSONFormatterConverter  {

    let converter: JSONFormatterConverterCompletion

    var options: JSONSerialization.WritingOptions = {
      if #available(macOS 10.13, *) {
        return [ .sortedKeys ]
      }
      return []
    }()
    init(converter: @escaping JSONFormatterConverterCompletion) {
        self.converter = converter
    }

    func toJSON(message: String, metadata: LogMetadata) -> String? {
        let dict = self.converter(message)
        return JSONSerialization.string(withJSONObject: dict, options: options)
    }

    func format(message: String, logLevel: LogLevel, metadata: LogMetadata) -> String {
        guard let string = toJSON(message: message, metadata: metadata) else { return message }
        return string
    }


}

// MARK: NewLineBatchFormatter

public class JSONBatchFormatter: BatchFormatter {

    private let jsonFormatter: JSONFormatter

    init(converter: @escaping JSONFormatterConverterCompletion) {
        jsonFormatter = JSONFormatter(converter: converter)
    }

    public func format(message: String, logLevel: LogLevel, metadata: LogMetadata) -> String {
        return jsonFormatter.format(message: message, logLevel: logLevel, metadata: metadata)
    }

    public func format(batch: [(String, LogLevel, LogMetadata)]) -> String {
        return batch.map({ format(message: $0.0, logLevel: $0.1, metadata: $0.2) }).joined(separator: "\n")
    }

}
