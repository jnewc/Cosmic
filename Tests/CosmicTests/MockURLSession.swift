//
//  MockURLSession.swift
//  Cosmic
//
//  Created by Jack Newcombe on 24/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation

typealias CompletionHandler = (URLRequest?) -> Void

public final class URLSessionMock : URLSession {
    
    var request: URLRequest?
 
    public var dataTaskMock: URLSessionDataTaskMock?
    
    var completionHandler: CompletionHandler?

    
    public override init() {
    }
    
    public override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        self.dataTaskMock = URLSessionDataTaskMock(request: request, completion: self.completionHandler)
        return self.dataTaskMock!
    }
    
    public override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.request = request
        self.dataTaskMock = URLSessionDataTaskMock(request: request, completion: self.completionHandler)
        return self.dataTaskMock!
    }
    
    public final class URLSessionDataTaskMock : URLSessionDataTask {

        let request: URLRequest
        
        var completionHandler: CompletionHandler?
        
        init(request: URLRequest, completion: CompletionHandler?) {
            self.request = request
            self.completionHandler = completion
        }
        
        override public func resume() {
            completionHandler?(request)
        }
    }
}
