//
//  BlockFormatter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 11/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public typealias LambdaFormatterCompletion = (String, LogLevel, LogMetadata) -> (String)

public class LambdaFormatter: LogFormatter {
    
    let completion: LambdaFormatterCompletion
    
    public init(completion: @escaping LambdaFormatterCompletion) {
        self.completion = completion
    }
    
    public func format(message: String, logLevel: LogLevel, metadata: LogMetadata) -> String {
        return completion(message, logLevel, metadata)
    }
    
}

public typealias λFormatter = LambdaFormatter
