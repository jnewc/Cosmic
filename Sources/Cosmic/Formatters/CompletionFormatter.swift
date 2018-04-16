//
//  BlockFormatter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 11/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public typealias LambdaFormatterCompletion = (String, LogMetadata) -> (String)

public class LambdaFormatter: LogFormatter {
    
    let completion: LambdaFormatterCompletion
    
    public init(completion: @escaping LambdaFormatterCompletion) {
        self.completion = completion
    }
    
    public func format(message: String, metadata: LogMetadata) -> String {
        return completion(message, metadata)
    }
    
}

public typealias λFormatter = LambdaFormatter
