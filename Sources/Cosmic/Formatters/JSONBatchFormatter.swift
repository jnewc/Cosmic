//
//  JSONBatchFormatter.swift
//  Cosmic
//
//  Created by Jack Newcombe on 11/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

public class JSONBatchFormatter: BatchFormatter {
    
    public func format(batch: [String]) -> String{
        
        var message = "[\n\t"
        
        message += batch.joined(separator: ", \n\t")
        
        return message
    }

    
    public func format(message: String) -> String {
        return message
    }

    
}
