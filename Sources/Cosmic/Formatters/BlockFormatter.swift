//
//  BlockFormatter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 11/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

typealias BlockFormatterCompletion = (String, LogMetadata) -> (String)

class BlockFormatter: LogFormatter {
    
    let completion: BlockFormatterCompletion
    
    init(completion: @escaping BlockFormatterCompletion) {
        self.completion = completion
    }
    
    func format(message: String, metadata: LogMetadata) -> String {
        return completion(message, metadata)
    }
    
}
