//
//  DemoServer.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation


public func demoServer(_ publicDir: String) -> HttpServer {
    
    print(publicDir)
    
    let server = HttpServer()
    
    server["/public/:path"] = shareFilesFromDirectory(publicDir)

    server["/files/:path"] = directoryBrowser("/")

    server["/"] = scopes {
        html {
            body {
                ul(server.routes) { service in
                    li {
                        a { href = service; inner = service }
                    }
                }
            }
        }
    }
    
    server["/magic"] = { .ok(.html("You asked for " + $0.path)) }
    
    server["/test/:param1/:param2"] = { r in
        scopes {
            html {
                body {
                    h3 { inner = "Address: \(r.address)" }
                    h3 { inner = "Url: \(r.path)" }
                    h3 { inner = "Method: \(r.method)" }
                    
                    h3 { inner = "Query:" }
                    
                    table(r.queryParams) { param in
                        tr {
                            td { inner = param.0 }
                            td { inner = param.1 }
                        }
                    }
                    
                    h3 { inner = "Headers:" }
                    
                    table(r.headers) { header in
                        tr {
                            td { inner = header.0 }
                            td { inner = header.1 }
                        }
                    }
                    
                    h3 { inner = "Route params:" }
                    
                    table(r.params) { param in
                        tr {
                            td { inner = param.0 }
                            td { inner = param.1 }
                        }
                    }
                }
            }
        }(r)
    }
    
    server.GET["/upload"] = scopes {
        html {
            body {
                form {
                    method = "POST"
                    action = "/upload"
                    enctype = "multipart/form-data"
                    
                    input { name = "my_file1"; type = "file" }
                    input { name = "my_file2"; type = "file" }
                    input { name = "my_file3"; type = "file" }
                    
                    button {
                        type = "submit"
                        inner = "Upload"
                    }
                }
            }
        }
    }
    
    server.POST["/upload"] = { r in
        var response = ""
        for multipart in r.parseMultiPartFormData() {
            response += "Name: \(multipart.name) File name: \(multipart.fileName) Size: \(multipart.body.count)<br>"
        }
        return HttpResponse.ok(.html(response))
    }
    
    server.GET["/login"] = scopes {
        html {
            head {
                script { src = "http://cdn.staticfile.org/jquery/2.1.4/jquery.min.js" }
                stylesheet { href = "http://cdn.staticfile.org/twitter-bootstrap/3.3.0/css/bootstrap.min.css" }
            }
            body {
                h3 { inner = "Sign In" }
                
                form {
                    method = "POST"
                    action = "/login"
                    
                    fieldset {
                        input { placeholder = "E-mail"; name = "email"; type = "email"; autofocus = "" }
                        input { placeholder = "Password"; name = "password"; type = "password"; autofocus = "" }
                        a {
                            href = "/login"
                            button {
                                type = "submit"
                                inner = "Login"
                            }
                        }
                    }
                    
                }
                javascript {
                    src = "http://cdn.staticfile.org/twitter-bootstrap/3.3.0/js/bootstrap.min.js"
                }
            }
        }
    }
    
    server.POST["/login"] = { r in
        let formFields = r.parseUrlencodedForm()
        return HttpResponse.ok(.html(formFields.map({ "\($0.0) = \($0.1)" }).joined(separator: "<br>")))
    }
    
    server["/demo"] = scopes {
        html {
            body {
                center {
                    h2 { inner = "Hello Swift" }
                    img { src = "https://devimages.apple.com.edgekey.net/swift/images/swift-hero_2x.png" }
                }
            }
        }
    }
    
    server["/raw"] = { r in
        return HttpResponse.raw(200, "OK", ["XXX-Custom-Header": "value"], { try $0.write([UInt8]("test".utf8)) })
    }
    
    server["/redirect"] = { r in
        return .movedPermanently("http://www.google.com")
    }

    server["/long"] = { r in
        var longResponse = ""
        for k in 0..<1000 { longResponse += "(\(k)),->" }
        return .ok(.html(longResponse))
    }
    
    server["/wildcard/*/test/*/:param"] = { r in
        return .ok(.html(r.path))
    }
    
    server["/stream"] = { r in
        return HttpResponse.raw(200, "OK", nil, { w in
            for i in 0...100 {
                try w.write([UInt8]("[chunk \(i)]".utf8))
            }
        })
    }
    
    server["/websocket-echo"] = websocket({ (session, text) in
        session.writeText(text)
        }, { (session, binary) in
        session.writeBinary(binary)
    })
    
    server.notFoundHandler = { r in
        return .movedPermanently("https://github.com/404")
    }
    
    server.middleware.append { r in
        print("Middleware: \(r.address) -> \(r.method) -> \(r.path)")
        return nil
    }
    
    return server
}
    
//
//  Errno.swift
//  Swifter
//
//  Copyright © 2016 Damian Kołakowski. All rights reserved.
//

import Foundation

public class Errno {
    
    public class func description() -> String {
        return String(cString: UnsafePointer(strerror(errno)))
    }
}
//
//  HttpHandlers+Files.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation

public func shareFile(_ path: String) -> ((HttpRequest) -> HttpResponse) {
    return { r in
        if let file = try? path.openForReading() {
            return .raw(200, "OK", [:], { writer in
                try? writer.write(file)
                file.close()
            })
        }
        return .notFound
    }
}

public func shareFilesFromDirectory(_ directoryPath: String, defaults: [String] = ["index.html", "default.html"]) -> ((HttpRequest) -> HttpResponse) {
    return { r in
        guard let fileRelativePath = r.params.first else {
            return .notFound
        }
        if fileRelativePath.value.isEmpty {
            for path in defaults {
                if let file = try? (directoryPath + String.pathSeparator + path).openForReading() {
                    return .raw(200, "OK", [:], { writer in
                        try? writer.write(file)
                        file.close()
                    })
                }
            }
        }
        if let file = try? (directoryPath + String.pathSeparator + fileRelativePath.value).openForReading() {
            return .raw(200, "OK", [:], { writer in
                try? writer.write(file)
                file.close()
            })
        }
        return .notFound
    }
}

public func directoryBrowser(_ dir: String) -> ((HttpRequest) -> HttpResponse) {
    return { r in
        guard let (_, value) = r.params.first else {
            return HttpResponse.notFound
        }
        let filePath = dir + String.pathSeparator + value
        do {
            guard try filePath.exists() else {
                return .notFound
            }
            if try filePath.directory() {
                let files = try filePath.files()
                return scopes {
                    html {
                        body {
                            table(files) { file in
                                tr {
                                    td {
                                        a {
                                            href = r.path + "/" + file
                                            inner = file
                                        }
                                    }
                                }
                            }
                        }
                    }
                    }(r)
            } else {
                guard let file = try? filePath.openForReading() else {
                    return .notFound
                }
                return .raw(200, "OK", [:], { writer in
                    try? writer.write(file)
                    file.close()
                })
            }
        } catch {
            return HttpResponse.internalServerError
        }
    }
}
//
//  HttpParser.swift
//  Swifter
// 
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation

enum HttpParserError: Error {
    case InvalidStatusLine(String)
}

public class HttpParser {
    
    public init() { }
    
    public func readHttpRequest(_ socket: Socket) throws -> HttpRequest {
        let statusLine = try socket.readLine()
        let statusLineTokens = statusLine.components(separatedBy: " ")
        if statusLineTokens.count < 3 {
            throw HttpParserError.InvalidStatusLine(statusLine)
        }
        let request = HttpRequest()
        request.method = statusLineTokens[0]
        request.path = statusLineTokens[1]
        request.queryParams = extractQueryParams(request.path)
        request.headers = try readHeaders(socket)
        if let contentLength = request.headers["content-length"], let contentLengthValue = Int(contentLength) {
            request.body = try readBody(socket, size: contentLengthValue)
        }
        return request
    }
    
    private func extractQueryParams(_ url: String) -> [(String, String)] {
        guard let questionMark = url.characters.index(of: "?") else {
            return []
        }
        let queryStart = url.characters.index(after: questionMark)
        guard url.endIndex > queryStart else {
            return []
        }
        let query = String(url.characters[queryStart..<url.endIndex])
        return query.components(separatedBy: "&")
            .reduce([(String, String)]()) { (c, s) -> [(String, String)] in
                guard let nameEndIndex = s.characters.index(of: "=") else {
                    return c
                }
                guard let name = String(s.characters[s.startIndex..<nameEndIndex]).removingPercentEncoding else {
                    return c
                }
                let valueStartIndex = s.index(nameEndIndex, offsetBy: 1)
                guard valueStartIndex < s.endIndex else {
                    return c + [(name, "")]
                }
                guard let value = String(s.characters[valueStartIndex..<s.endIndex]).removingPercentEncoding else {
                    return c + [(name, "")]
                }
                return c + [(name, value)]
        }
        
        
//        let tokens = url.components(separatedBy: "?")
//        guard let query = tokens.last, tokens.count >= 2 else {
//            return []
//        }
//        return query.components(separatedBy: "&").reduce([(String, String)]()) { (c, s) -> [(String, String)] in
//            let tokens = s.components(separatedBy: "=")
//            let name = tokens.first?.removingPercentEncoding
//            let value = tokens.count > 1 ? (tokens.last?.removingPercentEncoding ?? "") : ""
//            if let nameFound = name {
//                return c + [(nameFound, value)]
//            }
//            return c
//        }
    }
    
    private func readBody(_ socket: Socket, size: Int) throws -> [UInt8] {
        var body = [UInt8]()
        for _ in 0..<size { body.append(try socket.read()) }
        return body
    }
    
    private func readHeaders(_ socket: Socket) throws -> [String: String] {
        var headers = [String: String]()
        while case let headerLine = try socket.readLine() , !headerLine.isEmpty {
            let headerTokens = headerLine.components(separatedBy: ":")
            if let name = headerTokens.first, let value = headerTokens.last {
                headers[name.lowercased()] = value.trimmingCharacters(in: .whitespaces)
            }
        }
        return headers
    }
    
    func supportsKeepAlive(_ headers: [String: String]) -> Bool {
        if let value = headers["connection"] {
            return "keep-alive" == value.trimmingCharacters(in: .whitespaces)
        }
        return false
    }
}
//
//  HttpRequest.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation

public class HttpRequest {
    
    public var path: String = ""
    public var queryParams: [(String, String)] = []
    public var method: String = ""
    public var headers: [String: String] = [:]
    public var body: [UInt8] = []
    public var address: String? = ""
    public var params: [String: String] = [:]
    
    public init() {}
    
    public func hasTokenForHeader(_ headerName: String, token: String) -> Bool {
        guard let headerValue = headers[headerName] else {
            return false
        }
        return headerValue.components(separatedBy: ",").filter({ $0.trimmingCharacters(in: .whitespaces).lowercased() == token }).count > 0
    }
    
    public func parseUrlencodedForm() -> [(String, String)] {
        guard let contentTypeHeader = headers["content-type"] else {
            return []
        }
        let contentTypeHeaderTokens = contentTypeHeader.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        guard let contentType = contentTypeHeaderTokens.first, contentType == "application/x-www-form-urlencoded" else {
            return []
        }
        guard let utf8String = String(bytes: body, encoding: .utf8) else {
            // Consider to throw an exception here (examine the encoding from headers).
            return []
        }
        return utf8String.components(separatedBy: "&").map { param -> (String, String) in
            let tokens = param.components(separatedBy: "=")
            if let name = tokens.first?.removingPercentEncoding, let value = tokens.last?.removingPercentEncoding, tokens.count == 2 {
                return (name.replacingOccurrences(of: "+", with: " "),
                        value.replacingOccurrences(of: "+", with: " "))
            }
            return ("","")
        }
    }
    
    public struct MultiPart {
        
        public let headers: [String: String]
        public let body: [UInt8]
        
        public var name: String? {
            return valueFor("content-disposition", parameter: "name")?.unquote()
        }
        
        public var fileName: String? {
            return valueFor("content-disposition", parameter: "filename")?.unquote()
        }
        
        private func valueFor(_ headerName: String, parameter: String) -> String? {
            return headers.reduce([String]()) { (combined, header: (key: String, value: String)) -> [String] in
                guard header.key == headerName else {
                    return combined
                }
                let headerValueParams = header.value.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
                return headerValueParams.reduce(combined, { (results, token) -> [String] in
                    let parameterTokens = token.components(separatedBy: "=")
                    if parameterTokens.first == parameter, let value = parameterTokens.last {
                        return results + [value]
                    }
                    return results
                })
                }.first
        }
    }
    
    public func parseMultiPartFormData() -> [MultiPart] {
        guard let contentTypeHeader = headers["content-type"] else {
            return []
        }
        let contentTypeHeaderTokens = contentTypeHeader.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        guard let contentType = contentTypeHeaderTokens.first, contentType == "multipart/form-data" else {
            return []
        }
        var boundary: String? = nil
        contentTypeHeaderTokens.forEach({
            let tokens = $0.components(separatedBy: "=")
            if let key = tokens.first, key == "boundary" && tokens.count == 2 {
                boundary = tokens.last
            }
        })
        if let boundary = boundary, boundary.utf8.count > 0 {
            return parseMultiPartFormData(body, boundary: "--\(boundary)")
        }
        return []
    }
    
    private func parseMultiPartFormData(_ data: [UInt8], boundary: String) -> [MultiPart] {
        var generator = data.makeIterator()
        var result = [MultiPart]()
        while let part = nextMultiPart(&generator, boundary: boundary, isFirst: result.isEmpty) {
            result.append(part)
        }
        return result
    }
    
    private func nextMultiPart(_ generator: inout IndexingIterator<[UInt8]>, boundary: String, isFirst: Bool) -> MultiPart? {
        if isFirst {
            guard nextUTF8MultiPartLine(&generator) == boundary else {
                return nil
            }
        } else {
            let /* ignore */ _ = nextUTF8MultiPartLine(&generator)
        }
        var headers = [String: String]()
        while let line = nextUTF8MultiPartLine(&generator), !line.isEmpty {
            let tokens = line.components(separatedBy: ":")
            if let name = tokens.first, let value = tokens.last, tokens.count == 2 {
                headers[name.lowercased()] = value.trimmingCharacters(in: .whitespaces)
            }
        }
        guard let body = nextMultiPartBody(&generator, boundary: boundary) else {
            return nil
        }
        return MultiPart(headers: headers, body: body)
    }
    
    private func nextUTF8MultiPartLine(_ generator: inout IndexingIterator<[UInt8]>) -> String? {
        var temp = [UInt8]()
        while let value = generator.next() {
            if value > HttpRequest.CR {
                temp.append(value)
            }
            if value == HttpRequest.NL {
                break
            }
        }
        return String(bytes: temp, encoding: String.Encoding.utf8)
    }
    
    static let CR = UInt8(13)
    static let NL = UInt8(10)
    
    private func nextMultiPartBody(_ generator: inout IndexingIterator<[UInt8]>, boundary: String) -> [UInt8]? {
        var body = [UInt8]()
        let boundaryArray = [UInt8](boundary.utf8)
        var matchOffset = 0;
        while let x = generator.next() {
            matchOffset = ( x == boundaryArray[matchOffset] ? matchOffset + 1 : 0 )
            body.append(x)
            if matchOffset == boundaryArray.count {
                body.removeSubrange(CountableRange<Int>(body.count-matchOffset ..< body.count))
                if body.last == HttpRequest.NL {
                    body.removeLast()
                    if body.last == HttpRequest.CR {
                        body.removeLast()
                    }
                }
                return body
            }
        }
        return nil
    }
}
//
//  HttpResponse.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation

public enum SerializationError: Error {
    case invalidObject
    case notSupported
}

public protocol HttpResponseBodyWriter {
    func write(_ file: String.File) throws
    func write(_ data: [UInt8]) throws
    func write(_ data: ArraySlice<UInt8>) throws
    func write(_ data: NSData) throws
    func write(_ data: Data) throws
}

public enum HttpResponseBody {
    
    case json(AnyObject)
    case html(String)
    case text(String)
    case custom(Any, (Any) throws -> String)
    
    func content() -> (Int, ((HttpResponseBodyWriter) throws -> Void)?) {
        do {
            switch self {
            case .json(let object):
                #if os(Linux)
                    let data = [UInt8]("Not ready for Linux.".utf8)
                    return (data.count, {
                        try $0.write(data)
                    })
                #else
                    guard JSONSerialization.isValidJSONObject(object) else {
                        throw SerializationError.invalidObject
                    }
                    let data = try JSONSerialization.data(withJSONObject: object)
                    return (data.count, {
                        try $0.write(data)
                    })
                #endif
            case .text(let body):
                let data = [UInt8](body.utf8)
                return (data.count, {
                    try $0.write(data)
                })
            case .html(let body):
                let serialised = "<html><meta charset=\"UTF-8\"><body>\(body)</body></html>"
                let data = [UInt8](serialised.utf8)
                return (data.count, {
                    try $0.write(data)
                })
            case .custom(let object, let closure):
                let serialised = try closure(object)
                let data = [UInt8](serialised.utf8)
                return (data.count, {
                    try $0.write(data)
                })
            }
        } catch {
            let data = [UInt8]("Serialisation error: \(error)".utf8)
            return (data.count, {
                try $0.write(data)
            })
        }
    }
}

public enum HttpResponse {
    
    case switchProtocols([String: String], (Socket) -> Void)
    case ok(HttpResponseBody), created, accepted
    case movedPermanently(String)
    case badRequest(HttpResponseBody?), unauthorized, forbidden, notFound
    case internalServerError
    case raw(Int, String, [String:String]?, ((HttpResponseBodyWriter) throws -> Void)? )

    func statusCode() -> Int {
        switch self {
        case .switchProtocols(_, _)   : return 101
        case .ok(_)                   : return 200
        case .created                 : return 201
        case .accepted                : return 202
        case .movedPermanently        : return 301
        case .badRequest(_)           : return 400
        case .unauthorized            : return 401
        case .forbidden               : return 403
        case .notFound                : return 404
        case .internalServerError     : return 500
        case .raw(let code, _ , _, _) : return code
        }
    }
    
    func reasonPhrase() -> String {
        switch self {
        case .switchProtocols(_, _)    : return "Switching Protocols"
        case .ok(_)                    : return "OK"
        case .created                  : return "Created"
        case .accepted                 : return "Accepted"
        case .movedPermanently         : return "Moved Permanently"
        case .badRequest(_)            : return "Bad Request"
        case .unauthorized             : return "Unauthorized"
        case .forbidden                : return "Forbidden"
        case .notFound                 : return "Not Found"
        case .internalServerError      : return "Internal Server Error"
        case .raw(_, let phrase, _, _) : return phrase
        }
    }
    
    func headers() -> [String: String] {
        var headers = ["Server" : "Swifter \(HttpServer.VERSION)"]
        switch self {
        case .switchProtocols(let switchHeaders, _):
            for (key, value) in switchHeaders {
                headers[key] = value
            }
        case .ok(let body):
            switch body {
            case .json(_)   : headers["Content-Type"] = "application/json"
            case .html(_)   : headers["Content-Type"] = "text/html"
            default:break
            }
        case .movedPermanently(let location):
            headers["Location"] = location
        case .raw(_, _, let rawHeaders, _):
            if let rawHeaders = rawHeaders {
                for (k, v) in rawHeaders {
                    headers.updateValue(v, forKey: k)
                }
            }
        default:break
        }
        return headers
    }
    
    func content() -> (length: Int, write: ((HttpResponseBodyWriter) throws -> Void)?) {
        switch self {
        case .ok(let body)             : return body.content()
        case .badRequest(let body)     : return body?.content() ?? (-1, nil)
        case .raw(_, _, _, let writer) : return (-1, writer)
        default                        : return (-1, nil)
        }
    }
    
    func socketSession() -> ((Socket) -> Void)?  {
        switch self {
        case .switchProtocols(_, let handler) : return handler
        default: return nil
        }
    }
}

/**
    Makes it possible to compare handler responses with '==', but
	ignores any associated values. This should generally be what
	you want. E.g.:
	
    let resp = handler(updatedRequest)
        if resp == .NotFound {
        print("Client requested not found: \(request.url)")
    }
*/

func ==(inLeft: HttpResponse, inRight: HttpResponse) -> Bool {
    return inLeft.statusCode() == inRight.statusCode()
}

//
//  HttpRouter.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation


open class HttpRouter {
    
    public init() {
    }
    
    private class Node {
        var nodes = [String: Node]()
        var handler: ((HttpRequest) -> HttpResponse)? = nil
    }
    
    private var rootNode = Node()

    public func routes() -> [String] {
        var routes = [String]()
        for (_, child) in rootNode.nodes {
            routes.append(contentsOf: routesForNode(child));
        }
        return routes
    }
    
    private func routesForNode(_ node: Node, prefix: String = "") -> [String] {
        var result = [String]()
        if let _ = node.handler {
            result.append(prefix)
        }
        for (key, child) in node.nodes {
            result.append(contentsOf: routesForNode(child, prefix: prefix + "/" + key));
        }
        return result
    }
    
    public func register(_ method: String?, path: String, handler: ((HttpRequest) -> HttpResponse)?) {
        var pathSegments = stripQuery(path).split("/")
        if let method = method {
            pathSegments.insert(method, at: 0)
        } else {
            pathSegments.insert("*", at: 0)
        }
        var pathSegmentsGenerator = pathSegments.makeIterator()
        inflate(&rootNode, generator: &pathSegmentsGenerator).handler = handler
    }
    
    public func route(_ method: String?, path: String) -> ([String: String], (HttpRequest) -> HttpResponse)? {
        if let method = method {
            let pathSegments = (method + "/" + stripQuery(path)).split("/")
            var pathSegmentsGenerator = pathSegments.makeIterator()
            var params = [String:String]()
            if let handler = findHandler(&rootNode, params: &params, generator: &pathSegmentsGenerator) {
                return (params, handler)
            }
        }
        let pathSegments = ("*/" + stripQuery(path)).split("/")
        var pathSegmentsGenerator = pathSegments.makeIterator()
        var params = [String:String]()
        if let handler = findHandler(&rootNode, params: &params, generator: &pathSegmentsGenerator) {
            return (params, handler)
        }
        return nil
    }
    
    private func inflate(_ node: inout Node, generator: inout IndexingIterator<[String]>) -> Node {
        if let pathSegment = generator.next() {
            if let _ = node.nodes[pathSegment] {
                return inflate(&node.nodes[pathSegment]!, generator: &generator)
            }
            var nextNode = Node()
            node.nodes[pathSegment] = nextNode
            return inflate(&nextNode, generator: &generator)
        }
        return node
    }
    
    private func findHandler(_ node: inout Node, params: inout [String: String], generator: inout IndexingIterator<[String]>) -> ((HttpRequest) -> HttpResponse)? {
        guard let pathToken = generator.next() else {
            // if it's the last element of the requested URL, check if there is a pattern with variable tail.
            if let variableNode = node.nodes.filter({ $0.0.characters.first == ":" }).first {
                if variableNode.value.nodes.isEmpty {
                    params[variableNode.0] = ""
                    return variableNode.value.handler
                }
            }
            return node.handler
        }
        let variableNodes = node.nodes.filter { $0.0.characters.first == ":" }
        if let variableNode = variableNodes.first {
            if variableNode.1.nodes.count == 0 {
                // if it's the last element of the pattern and it's a variable, stop the search and
                // append a tail as a value for the variable.
                let tail = generator.joined(separator: "/")
                if tail.characters.count > 0 {
                    params[variableNode.0] = pathToken + "/" + tail
                } else {
                    params[variableNode.0] = pathToken
                }
                return variableNode.1.handler
            }
            params[variableNode.0] = pathToken
            return findHandler(&node.nodes[variableNode.0]!, params: &params, generator: &generator)
        }
        if var node = node.nodes[pathToken] {
            return findHandler(&node, params: &params, generator: &generator)
        }
        if var node = node.nodes["*"] {
            return findHandler(&node, params: &params, generator: &generator)
        }
        if let startStarNode = node.nodes["**"] {
            let startStarNodeKeys = startStarNode.nodes.keys
            while let pathToken = generator.next() {
                if startStarNodeKeys.contains(pathToken) {
                    return findHandler(&startStarNode.nodes[pathToken]!, params: &params, generator: &generator)
                }
            }
        }
        return nil
    }
    
    private func stripQuery(_ path: String) -> String {
        if let path = path.components(separatedBy: "?").first {
            return path
        }
        return path
    }
}

extension String {
    
    public func split(_ separator: Character) -> [String] {
        return self.characters.split { $0 == separator }.map(String.init)
    }
    
}
//
//  HttpServer.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation

public class HttpServer: HttpServerIO {
    
    public static let VERSION = "1.3.3"
    
    private let router = HttpRouter()
    
    public override init() {
        self.DELETE = MethodRoute(method: "DELETE", router: router)
        self.UPDATE = MethodRoute(method: "UPDATE", router: router)
        self.HEAD   = MethodRoute(method: "HEAD", router: router)
        self.POST   = MethodRoute(method: "POST", router: router)
        self.GET    = MethodRoute(method: "GET", router: router)
        self.PUT    = MethodRoute(method: "PUT", router: router)
        
        self.delete = MethodRoute(method: "DELETE", router: router)
        self.update = MethodRoute(method: "UPDATE", router: router)
        self.head   = MethodRoute(method: "HEAD", router: router)
        self.post   = MethodRoute(method: "POST", router: router)
        self.get    = MethodRoute(method: "GET", router: router)
        self.put    = MethodRoute(method: "PUT", router: router)
    }
    
    public var DELETE, UPDATE, HEAD, POST, GET, PUT : MethodRoute
    public var delete, update, head, post, get, put : MethodRoute
    
    public subscript(path: String) -> ((HttpRequest) -> HttpResponse)? {
        set {
            router.register(nil, path: path, handler: newValue)
        }
        get { return nil }
    }
    
    public var routes: [String] {
        return router.routes();
    }
    
    public var notFoundHandler: ((HttpRequest) -> HttpResponse)?
    
    public var middleware = Array<(HttpRequest) -> HttpResponse?>()

    override public func dispatch(_ request: HttpRequest) -> ([String:String], (HttpRequest) -> HttpResponse) {
        for layer in middleware {
            if let response = layer(request) {
                return ([:], { _ in response })
            }
        }
        if let result = router.route(request.method, path: request.path) {
            return result
        }
        if let notFoundHandler = self.notFoundHandler {
            return ([:], notFoundHandler)
        }
        return super.dispatch(request)
    }
    
    public struct MethodRoute {
        public let method: String
        public let router: HttpRouter
        public subscript(path: String) -> ((HttpRequest) -> HttpResponse)? {
            set {
                router.register(method, path: path, handler: newValue)
            }
            get { return nil }
        }
    }
}
//
//  HttpServer.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation
import Dispatch

public protocol HttpServerIODelegate: class {
    func socketConnectionReceived(_ socket: Socket)
}

public class HttpServerIO {

    public weak var delegate : HttpServerIODelegate?

    private var socket = Socket(socketFileDescriptor: -1)
    private var sockets = Set<Socket>()

    public enum HttpServerIOState: Int32 {
        case starting
        case running
        case stopping
        case stopped
    }

    private var stateValue: Int32 = HttpServerIOState.stopped.rawValue

    public private(set) var state: HttpServerIOState {
        get {
            return HttpServerIOState(rawValue: stateValue)!
        }
        set(state) {
            #if !os(Linux)
            OSAtomicCompareAndSwapInt(self.state.rawValue, state.rawValue, &stateValue)
            #else
            //TODO - hehe :)
            self.stateValue = state.rawValue
            #endif
        }
    }

    public var operating: Bool { get { return self.state == .running } }

    /// String representation of the IPv4 address to receive requests from.
    /// It's only used when the server is started with `forceIPv4` option set to true.
    /// Otherwise, `listenAddressIPv6` will be used.
    public var listenAddressIPv4: String?

    /// String representation of the IPv6 address to receive requests from.
    /// It's only used when the server is started with `forceIPv4` option set to false.
    /// Otherwise, `listenAddressIPv4` will be used.
    public var listenAddressIPv6: String?

    private let queue = DispatchQueue(label: "swifter.httpserverio.clientsockets")

    public func port() throws -> Int {
        return Int(try socket.port())
    }

    public func isIPv4() throws -> Bool {
        return try socket.isIPv4()
    }

    deinit {
        stop()
    }

    @available(macOS 10.10, *)
    public func start(_ port: in_port_t = 8080, forceIPv4: Bool = false, priority: DispatchQoS.QoSClass = DispatchQoS.QoSClass.background) throws {
        guard !self.operating else { return }
        stop()
        self.state = .starting
        let address = forceIPv4 ? listenAddressIPv4 : listenAddressIPv6
        self.socket = try Socket.tcpSocketForListen(port, forceIPv4, SOMAXCONN, address)
        DispatchQueue.global(qos: priority).async { [weak self] in
            guard let strongSelf = self else { return }
            guard strongSelf.operating else { return }
            while let socket = try? strongSelf.socket.acceptClientSocket() {
                DispatchQueue.global(qos: priority).async { [weak self] in
                    guard let strongSelf = self else { return }
                    guard strongSelf.operating else { return }
                    strongSelf.queue.async {
                        strongSelf.sockets.insert(socket)
                    }
                    strongSelf.handleConnection(socket)
                    strongSelf.queue.async {
                        strongSelf.sockets.remove(socket)
                    }
                }
            }
            strongSelf.stop()
        }
        self.state = .running
    }

    public func stop() {
        guard self.operating else { return }
        self.state = .stopping
        // Shutdown connected peers because they can live in 'keep-alive' or 'websocket' loops.
        for socket in self.sockets {
            socket.close()
        }
        self.queue.sync {
            self.sockets.removeAll(keepingCapacity: true)
        }
        socket.close()
        self.state = .stopped
    }

    public func dispatch(_ request: HttpRequest) -> ([String: String], (HttpRequest) -> HttpResponse) {
        return ([:], { _ in HttpResponse.notFound })
    }

    private func handleConnection(_ socket: Socket) {
        let parser = HttpParser()
        while self.operating, let request = try? parser.readHttpRequest(socket) {
            let request = request
            request.address = try? socket.peername()
            let (params, handler) = self.dispatch(request)
            request.params = params
            let response = handler(request)
            var keepConnection = parser.supportsKeepAlive(request.headers)
            do {
                if self.operating {
                    keepConnection = try self.respond(socket, response: response, keepAlive: keepConnection)
                }
            } catch {
                print("Failed to send response: \(error)")
                break
            }
            if let session = response.socketSession() {
                delegate?.socketConnectionReceived(socket)
                session(socket)
                break
            }
            if !keepConnection { break }
        }
        socket.close()
    }

    private struct InnerWriteContext: HttpResponseBodyWriter {
        
        let socket: Socket

        func write(_ file: String.File) throws {
            try socket.writeFile(file)
        }

        func write(_ data: [UInt8]) throws {
            try write(ArraySlice(data))
        }

        func write(_ data: ArraySlice<UInt8>) throws {
            try socket.writeUInt8(data)
        }

        func write(_ data: NSData) throws {
            try socket.writeData(data)
        }

        func write(_ data: Data) throws {
            try socket.writeData(data)
        }
    }

    private func respond(_ socket: Socket, response: HttpResponse, keepAlive: Bool) throws -> Bool {
        guard self.operating else { return false }

        try socket.writeUTF8("HTTP/1.1 \(response.statusCode()) \(response.reasonPhrase())\r\n")

        let content = response.content()

        if content.length >= 0 {
            try socket.writeUTF8("Content-Length: \(content.length)\r\n")
        }

        if keepAlive && content.length != -1 {
            try socket.writeUTF8("Connection: keep-alive\r\n")
        }

        for (name, value) in response.headers() {
            try socket.writeUTF8("\(name): \(value)\r\n")
        }

        try socket.writeUTF8("\r\n")

        if let writeClosure = content.write {
            let context = InnerWriteContext(socket: socket)
            try writeClosure(context)
        }

        return keepAlive && content.length != -1;
    }
}
//
//  Process
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation

public class Process {
    
    public static var pid: Int {
        return Int(getpid())
    }
    
    public static var tid: UInt64 {
        #if os(Linux)
            return UInt64(pthread_self())
        #else
            var tid: __uint64_t = 0
            pthread_threadid_np(nil, &tid);
            return UInt64(tid)
        #endif
    }
    
    private static var signalsWatchers = Array<(Int32) -> Void>()
    private static var signalsObserved = false
    
    public static func watchSignals(_ callback: @escaping (Int32) -> Void) {
        if !signalsObserved {
            [SIGTERM, SIGHUP, SIGSTOP, SIGINT].forEach { item in
                signal(item) {
                    signum in Process.signalsWatchers.forEach { $0(signum) }
                }
            }
            signalsObserved = true
        }
        signalsWatchers.append(callback)
    }
}
//
//  HttpHandlers+Scopes.swift
//  Swifter
//
//  Copyright © 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation

public func scopes(_ scope: @escaping Closure) -> ((HttpRequest) -> HttpResponse) {
    return { r in
        ScopesBuffer[Process.tid] = ""
        scope()
        return .raw(200, "OK", ["Content-Type": "text/html"], {
            try? $0.write([UInt8](("<!DOCTYPE html>"  + (ScopesBuffer[Process.tid] ?? "")).utf8))
        })
    }
}

public typealias Closure = (Void) -> Void

public var idd: String? = nil
public var dir: String? = nil
public var rel: String? = nil
public var rev: String? = nil
public var alt: String? = nil
public var forr: String? = nil
public var src: String? = nil
public var type: String? = nil
public var href: String? = nil
public var text: String? = nil
public var abbr: String? = nil
public var size: String? = nil
public var face: String? = nil
public var char: String? = nil
public var cite: String? = nil
public var span: String? = nil
public var data: String? = nil
public var axis: String? = nil
public var Name: String? = nil
public var name: String? = nil
public var code: String? = nil
public var link: String? = nil
public var lang: String? = nil
public var cols: String? = nil
public var rows: String? = nil
public var ismap: String? = nil
public var shape: String? = nil
public var style: String? = nil
public var alink: String? = nil
public var width: String? = nil
public var rules: String? = nil
public var align: String? = nil
public var frame: String? = nil
public var vlink: String? = nil
public var deferr: String? = nil
public var color: String? = nil
public var media: String? = nil
public var title: String? = nil
public var scope: String? = nil
public var classs: String? = nil
public var value: String? = nil
public var clear: String? = nil
public var start: String? = nil
public var label: String? = nil
public var action: String? = nil
public var height: String? = nil
public var method: String? = nil
public var acceptt: String? = nil
public var object: String? = nil
public var scheme: String? = nil
public var coords: String? = nil
public var usemap: String? = nil
public var onblur: String? = nil
public var nohref: String? = nil
public var nowrap: String? = nil
public var hspace: String? = nil
public var border: String? = nil
public var valign: String? = nil
public var vspace: String? = nil
public var onload: String? = nil
public var target: String? = nil
public var prompt: String? = nil
public var onfocus: String? = nil
public var enctype: String? = nil
public var onclick: String? = nil
public var onkeyup: String? = nil
public var profile: String? = nil
public var version: String? = nil
public var onreset: String? = nil
public var charset: String? = nil
public var standby: String? = nil
public var colspan: String? = nil
public var charoff: String? = nil
public var classid: String? = nil
public var compact: String? = nil
public var declare: String? = nil
public var rowspan: String? = nil
public var checked: String? = nil
public var archive: String? = nil
public var bgcolor: String? = nil
public var content: String? = nil
public var noshade: String? = nil
public var summary: String? = nil
public var headers: String? = nil
public var onselect: String? = nil
public var readonly: String? = nil
public var tabindex: String? = nil
public var onchange: String? = nil
public var noresize: String? = nil
public var disabled: String? = nil
public var longdesc: String? = nil
public var codebase: String? = nil
public var language: String? = nil
public var datetime: String? = nil
public var selected: String? = nil
public var hreflang: String? = nil
public var onsubmit: String? = nil
public var multiple: String? = nil
public var onunload: String? = nil
public var codetype: String? = nil
public var scrolling: String? = nil
public var onkeydown: String? = nil
public var maxlength: String? = nil
public var valuetype: String? = nil
public var accesskey: String? = nil
public var onmouseup: String? = nil
public var autofocus: String? = nil
public var onkeypress: String? = nil
public var ondblclick: String? = nil
public var onmouseout: String? = nil
public var httpEquiv: String? = nil
public var background: String? = nil
public var onmousemove: String? = nil
public var onmouseover: String? = nil
public var cellpadding: String? = nil
public var onmousedown: String? = nil
public var frameborder: String? = nil
public var marginwidth: String? = nil
public var cellspacing: String? = nil
public var placeholder: String? = nil
public var marginheight: String? = nil
public var acceptCharset: String? = nil

public var inner: String? = nil

public func a(_ c: Closure) { element("a", c) }
public func b(_ c: Closure) { element("b", c) }
public func i(_ c: Closure) { element("i", c) }
public func p(_ c: Closure) { element("p", c) }
public func q(_ c: Closure) { element("q", c) }
public func s(_ c: Closure) { element("s", c) }
public func u(_ c: Closure) { element("u", c) }

public func br(_ c: Closure) { element("br", c) }
public func dd(_ c: Closure) { element("dd", c) }
public func dl(_ c: Closure) { element("dl", c) }
public func dt(_ c: Closure) { element("dt", c) }
public func em(_ c: Closure) { element("em", c) }
public func hr(_ c: Closure) { element("hr", c) }
public func li(_ c: Closure) { element("li", c) }
public func ol(_ c: Closure) { element("ol", c) }
public func rp(_ c: Closure) { element("rp", c) }
public func rt(_ c: Closure) { element("rt", c) }
public func td(_ c: Closure) { element("td", c) }
public func th(_ c: Closure) { element("th", c) }
public func tr(_ c: Closure) { element("tr", c) }
public func tt(_ c: Closure) { element("tt", c) }
public func ul(_ c: Closure) { element("ul", c) }

public func ul<T: Sequence>(_ collection: T, _ c: @escaping (T.Iterator.Element) -> Void) {
    element("ul", {
        for item in collection {
            c(item)
        }
    })
}

public func h1(_ c: Closure) { element("h1", c) }
public func h2(_ c: Closure) { element("h2", c) }
public func h3(_ c: Closure) { element("h3", c) }
public func h4(_ c: Closure) { element("h4", c) }
public func h5(_ c: Closure) { element("h5", c) }
public func h6(_ c: Closure) { element("h6", c) }

public func bdi(_ c: Closure) { element("bdi", c) }
public func bdo(_ c: Closure) { element("bdo", c) }
public func big(_ c: Closure) { element("big", c) }
public func col(_ c: Closure) { element("col", c) }
public func del(_ c: Closure) { element("del", c) }
public func dfn(_ c: Closure) { element("dfn", c) }
public func dir(_ c: Closure) { element("dir", c) }
public func div(_ c: Closure) { element("div", c) }
public func img(_ c: Closure) { element("img", c) }
public func ins(_ c: Closure) { element("ins", c) }
public func kbd(_ c: Closure) { element("kbd", c) }
public func map(_ c: Closure) { element("map", c) }
public func nav(_ c: Closure) { element("nav", c) }
public func pre(_ c: Closure) { element("pre", c) }
public func rtc(_ c: Closure) { element("rtc", c) }
public func sub(_ c: Closure) { element("sub", c) }
public func sup(_ c: Closure) { element("sup", c) }

public func varr(_ c: Closure) { element("var", c) }
public func wbr(_ c: Closure) { element("wbr", c) }
public func xmp(_ c: Closure) { element("xmp", c) }

public func abbr(_ c: Closure) { element("abbr", c) }
public func area(_ c: Closure) { element("area", c) }
public func base(_ c: Closure) { element("base", c) }
public func body(_ c: Closure) { element("body", c) }
public func cite(_ c: Closure) { element("cite", c) }
public func code(_ c: Closure) { element("code", c) }
public func data(_ c: Closure) { element("data", c) }
public func font(_ c: Closure) { element("font", c) }
public func form(_ c: Closure) { element("form", c) }
public func head(_ c: Closure) { element("head", c) }
public func html(_ c: Closure) { element("html", c) }
public func link(_ c: Closure) { element("link", c) }
public func main(_ c: Closure) { element("main", c) }
public func mark(_ c: Closure) { element("mark", c) }
public func menu(_ c: Closure) { element("menu", c) }
public func meta(_ c: Closure) { element("meta", c) }
public func nobr(_ c: Closure) { element("nobr", c) }
public func ruby(_ c: Closure) { element("ruby", c) }
public func samp(_ c: Closure) { element("samp", c) }
public func span(_ c: Closure) { element("span", c) }
public func time(_ c: Closure) { element("time", c) }

public func aside(_ c: Closure) { element("aside", c) }
public func audio(_ c: Closure) { element("audio", c) }
public func blink(_ c: Closure) { element("blink", c) }
public func embed(_ c: Closure) { element("embed", c) }
public func frame(_ c: Closure) { element("frame", c) }
public func image(_ c: Closure) { element("image", c) }
public func input(_ c: Closure) { element("input", c) }
public func label(_ c: Closure) { element("label", c) }
public func meter(_ c: Closure) { element("meter", c) }
public func param(_ c: Closure) { element("param", c) }
public func small(_ c: Closure) { element("small", c) }
public func style(_ c: Closure) { element("style", c) }
public func table(_ c: Closure) { element("table", c) }

public func table<T: Sequence>(_ collection: T, c: @escaping (T.Iterator.Element) -> Void) {
    element("table", {
        for item in collection {
            c(item)
        }
    })
}

public func tbody(_ c: Closure) { element("tbody", c) }

public func tbody<T: Sequence>(_ collection: T, c: @escaping (T.Iterator.Element) -> Void) {
    element("tbody", {
        for item in collection {
            c(item)
        }
    })
}

public func tfoot(_ c: Closure) { element("tfoot", c) }
public func thead(_ c: Closure) { element("thead", c) }
public func title(_ c: Closure) { element("title", c) }
public func track(_ c: Closure) { element("track", c) }
public func video(_ c: Closure) { element("video", c) }

public func applet(_ c: Closure) { element("applet", c) }
public func button(_ c: Closure) { element("button", c) }
public func canvas(_ c: Closure) { element("canvas", c) }
public func center(_ c: Closure) { element("center", c) }
public func dialog(_ c: Closure) { element("dialog", c) }
public func figure(_ c: Closure) { element("figure", c) }
public func footer(_ c: Closure) { element("footer", c) }
public func header(_ c: Closure) { element("header", c) }
public func hgroup(_ c: Closure) { element("hgroup", c) }
public func iframe(_ c: Closure) { element("iframe", c) }
public func keygen(_ c: Closure) { element("keygen", c) }
public func legend(_ c: Closure) { element("legend", c) }
public func object(_ c: Closure) { element("object", c) }
public func option(_ c: Closure) { element("option", c) }
public func output(_ c: Closure) { element("output", c) }
public func script(_ c: Closure) { element("script", c) }
public func select(_ c: Closure) { element("select", c) }
public func shadow(_ c: Closure) { element("shadow", c) }
public func source(_ c: Closure) { element("source", c) }
public func spacer(_ c: Closure) { element("spacer", c) }
public func strike(_ c: Closure) { element("strike", c) }
public func strong(_ c: Closure) { element("strong", c) }

public func acronym(_ c: Closure) { element("acronym", c) }
public func address(_ c: Closure) { element("address", c) }
public func article(_ c: Closure) { element("article", c) }
public func bgsound(_ c: Closure) { element("bgsound", c) }
public func caption(_ c: Closure) { element("caption", c) }
public func command(_ c: Closure) { element("command", c) }
public func content(_ c: Closure) { element("content", c) }
public func details(_ c: Closure) { element("details", c) }
public func elementt(_ c: Closure) { element("element", c) }
public func isindex(_ c: Closure) { element("isindex", c) }
public func listing(_ c: Closure) { element("listing", c) }
public func marquee(_ c: Closure) { element("marquee", c) }
public func noembed(_ c: Closure) { element("noembed", c) }
public func picture(_ c: Closure) { element("picture", c) }
public func section(_ c: Closure) { element("section", c) }
public func summary(_ c: Closure) { element("summary", c) }

public func basefont(_ c: Closure) { element("basefont", c) }
public func colgroup(_ c: Closure) { element("colgroup", c) }
public func datalist(_ c: Closure) { element("datalist", c) }
public func fieldset(_ c: Closure) { element("fieldset", c) }
public func frameset(_ c: Closure) { element("frameset", c) }
public func menuitem(_ c: Closure) { element("menuitem", c) }
public func multicol(_ c: Closure) { element("multicol", c) }
public func noframes(_ c: Closure) { element("noframes", c) }
public func noscript(_ c: Closure) { element("noscript", c) }
public func optgroup(_ c: Closure) { element("optgroup", c) }
public func progress(_ c: Closure) { element("progress", c) }
public func template(_ c: Closure) { element("template", c) }
public func textarea(_ c: Closure) { element("textarea", c) }

public func plaintext(_ c: Closure) { element("plaintext", c) }
public func javascript(_ c: Closure) { element("script", ["type": "text/javascript"], c) }
public func blockquote(_ c: Closure) { element("blockquote", c) }
public func figcaption(_ c: Closure) { element("figcaption", c) }

public func stylesheet(_ c: Closure) { element("link", ["rel": "stylesheet", "type": "text/css"], c) }

public func element(_ node: String, _ c: Closure) { evaluate(node, [:], c) }
public func element(_ node: String, _ attrs: [String: String?] = [:], _ c: Closure) { evaluate(node, attrs, c) }

var ScopesBuffer = [UInt64: String]()

private func evaluate(_ node: String, _ attrs: [String: String?] = [:], _ c: Closure) {
    
    // Push the attributes.
    
    let stackid = idd
    let stackdir = dir
    let stackrel = rel
    let stackrev = rev
    let stackalt = alt
    let stackfor = forr
    let stacksrc = src
    let stacktype = type
    let stackhref = href
    let stacktext = text
    let stackabbr = abbr
    let stacksize = size
    let stackface = face
    let stackchar = char
    let stackcite = cite
    let stackspan = span
    let stackdata = data
    let stackaxis = axis
    let stackName = Name
    let stackname = name
    let stackcode = code
    let stacklink = link
    let stacklang = lang
    let stackcols = cols
    let stackrows = rows
    let stackismap = ismap
    let stackshape = shape
    let stackstyle = style
    let stackalink = alink
    let stackwidth = width
    let stackrules = rules
    let stackalign = align
    let stackframe = frame
    let stackvlink = vlink
    let stackdefer = deferr
    let stackcolor = color
    let stackmedia = media
    let stacktitle = title
    let stackscope = scope
    let stackclass = classs
    let stackvalue = value
    let stackclear = clear
    let stackstart = start
    let stacklabel = label
    let stackaction = action
    let stackheight = height
    let stackmethod = method
    let stackaccept = acceptt
    let stackobject = object
    let stackscheme = scheme
    let stackcoords = coords
    let stackusemap = usemap
    let stackonblur = onblur
    let stacknohref = nohref
    let stacknowrap = nowrap
    let stackhspace = hspace
    let stackborder = border
    let stackvalign = valign
    let stackvspace = vspace
    let stackonload = onload
    let stacktarget = target
    let stackprompt = prompt
    let stackonfocus = onfocus
    let stackenctype = enctype
    let stackonclick = onclick
    let stackonkeyup = onkeyup
    let stackprofile = profile
    let stackversion = version
    let stackonreset = onreset
    let stackcharset = charset
    let stackstandby = standby
    let stackcolspan = colspan
    let stackcharoff = charoff
    let stackclassid = classid
    let stackcompact = compact
    let stackdeclare = declare
    let stackrowspan = rowspan
    let stackchecked = checked
    let stackarchive = archive
    let stackbgcolor = bgcolor
    let stackcontent = content
    let stacknoshade = noshade
    let stacksummary = summary
    let stackheaders = headers
    let stackonselect = onselect
    let stackreadonly = readonly
    let stacktabindex = tabindex
    let stackonchange = onchange
    let stacknoresize = noresize
    let stackdisabled = disabled
    let stacklongdesc = longdesc
    let stackcodebase = codebase
    let stacklanguage = language
    let stackdatetime = datetime
    let stackselected = selected
    let stackhreflang = hreflang
    let stackonsubmit = onsubmit
    let stackmultiple = multiple
    let stackonunload = onunload
    let stackcodetype = codetype
    let stackscrolling = scrolling
    let stackonkeydown = onkeydown
    let stackmaxlength = maxlength
    let stackvaluetype = valuetype
    let stackaccesskey = accesskey
    let stackonmouseup = onmouseup
    let stackonkeypress = onkeypress
    let stackondblclick = ondblclick
    let stackonmouseout = onmouseout
    let stackhttpEquiv = httpEquiv
    let stackbackground = background
    let stackonmousemove = onmousemove
    let stackonmouseover = onmouseover
    let stackcellpadding = cellpadding
    let stackonmousedown = onmousedown
    let stackframeborder = frameborder
    let stackmarginwidth = marginwidth
    let stackcellspacing = cellspacing
    let stackplaceholder = placeholder
    let stackmarginheight = marginheight
    let stackacceptCharset = acceptCharset
    let stackinner = inner
    
    // Reset the values before a nested scope evalutation.
    
    idd = nil
    dir = nil
    rel = nil
    rev = nil
    alt = nil
    forr = nil
    src = nil
    type = nil
    href = nil
    text = nil
    abbr = nil
    size = nil
    face = nil
    char = nil
    cite = nil
    span = nil
    data = nil
    axis = nil
    Name = nil
    name = nil
    code = nil
    link = nil
    lang = nil
    cols = nil
    rows = nil
    ismap = nil
    shape = nil
    style = nil
    alink = nil
    width = nil
    rules = nil
    align = nil
    frame = nil
    vlink = nil
    deferr = nil
    color = nil
    media = nil
    title = nil
    scope = nil
    classs = nil
    value = nil
    clear = nil
    start = nil
    label = nil
    action = nil
    height = nil
    method = nil
    acceptt = nil
    object = nil
    scheme = nil
    coords = nil
    usemap = nil
    onblur = nil
    nohref = nil
    nowrap = nil
    hspace = nil
    border = nil
    valign = nil
    vspace = nil
    onload = nil
    target = nil
    prompt = nil
    onfocus = nil
    enctype = nil
    onclick = nil
    onkeyup = nil
    profile = nil
    version = nil
    onreset = nil
    charset = nil
    standby = nil
    colspan = nil
    charoff = nil
    classid = nil
    compact = nil
    declare = nil
    rowspan = nil
    checked = nil
    archive = nil
    bgcolor = nil
    content = nil
    noshade = nil
    summary = nil
    headers = nil
    onselect = nil
    readonly = nil
    tabindex = nil
    onchange = nil
    noresize = nil
    disabled = nil
    longdesc = nil
    codebase = nil
    language = nil
    datetime = nil
    selected = nil
    hreflang = nil
    onsubmit = nil
    multiple = nil
    onunload = nil
    codetype = nil
    scrolling = nil
    onkeydown = nil
    maxlength = nil
    valuetype = nil
    accesskey = nil
    onmouseup = nil
    onkeypress = nil
    ondblclick = nil
    onmouseout = nil
    httpEquiv = nil
    background = nil
    onmousemove = nil
    onmouseover = nil
    cellpadding = nil
    onmousedown = nil
    frameborder = nil
    placeholder = nil
    marginwidth = nil
    cellspacing = nil
    marginheight = nil
    acceptCharset = nil
    inner = nil
    
    ScopesBuffer[Process.tid] = (ScopesBuffer[Process.tid] ?? "") + "<" + node
    
    // Save the current output before the nested scope evalutation.
    
    var output = ScopesBuffer[Process.tid] ?? ""
    
    // Clear the output buffer for the evalutation.
    
    ScopesBuffer[Process.tid] = ""
    
    // Evaluate the nested scope.
    
    c()
    
    // Render attributes set by the evalutation.
    
    var mergedAttributes = [String: String?]()
    
    if let idd = idd { mergedAttributes["id"] = idd }
    if let dir = dir { mergedAttributes["dir"] = dir }
    if let rel = rel { mergedAttributes["rel"] = rel }
    if let rev = rev { mergedAttributes["rev"] = rev }
    if let alt = alt { mergedAttributes["alt"] = alt }
    if let forr = forr { mergedAttributes["for"] = forr }
    if let src = src { mergedAttributes["src"] = src }
    if let type = type { mergedAttributes["type"] = type }
    if let href = href { mergedAttributes["href"] = href }
    if let text = text { mergedAttributes["text"] = text }
    if let abbr = abbr { mergedAttributes["abbr"] = abbr }
    if let size = size { mergedAttributes["size"] = size }
    if let face = face { mergedAttributes["face"] = face }
    if let char = char { mergedAttributes["char"] = char }
    if let cite = cite { mergedAttributes["cite"] = cite }
    if let span = span { mergedAttributes["span"] = span }
    if let data = data { mergedAttributes["data"] = data }
    if let axis = axis { mergedAttributes["axis"] = axis }
    if let Name = Name { mergedAttributes["Name"] = Name }
    if let name = name { mergedAttributes["name"] = name }
    if let code = code { mergedAttributes["code"] = code }
    if let link = link { mergedAttributes["link"] = link }
    if let lang = lang { mergedAttributes["lang"] = lang }
    if let cols = cols { mergedAttributes["cols"] = cols }
    if let rows = rows { mergedAttributes["rows"] = rows }
    if let ismap = ismap { mergedAttributes["ismap"] = ismap }
    if let shape = shape { mergedAttributes["shape"] = shape }
    if let style = style { mergedAttributes["style"] = style }
    if let alink = alink { mergedAttributes["alink"] = alink }
    if let width = width { mergedAttributes["width"] = width }
    if let rules = rules { mergedAttributes["rules"] = rules }
    if let align = align { mergedAttributes["align"] = align }
    if let frame = frame { mergedAttributes["frame"] = frame }
    if let vlink = vlink { mergedAttributes["vlink"] = vlink }
    if let deferr = deferr { mergedAttributes["defer"] = deferr }
    if let color = color { mergedAttributes["color"] = color }
    if let media = media { mergedAttributes["media"] = media }
    if let title = title { mergedAttributes["title"] = title }
    if let scope = scope { mergedAttributes["scope"] = scope }
    if let classs = classs { mergedAttributes["class"] = classs }
    if let value = value { mergedAttributes["value"] = value }
    if let clear = clear { mergedAttributes["clear"] = clear }
    if let start = start { mergedAttributes["start"] = start }
    if let label = label { mergedAttributes["label"] = label }
    if let action = action { mergedAttributes["action"] = action }
    if let height = height { mergedAttributes["height"] = height }
    if let method = method { mergedAttributes["method"] = method }
    if let acceptt = acceptt { mergedAttributes["accept"] = acceptt }
    if let object = object { mergedAttributes["object"] = object }
    if let scheme = scheme { mergedAttributes["scheme"] = scheme }
    if let coords = coords { mergedAttributes["coords"] = coords }
    if let usemap = usemap { mergedAttributes["usemap"] = usemap }
    if let onblur = onblur { mergedAttributes["onblur"] = onblur }
    if let nohref = nohref { mergedAttributes["nohref"] = nohref }
    if let nowrap = nowrap { mergedAttributes["nowrap"] = nowrap }
    if let hspace = hspace { mergedAttributes["hspace"] = hspace }
    if let border = border { mergedAttributes["border"] = border }
    if let valign = valign { mergedAttributes["valign"] = valign }
    if let vspace = vspace { mergedAttributes["vspace"] = vspace }
    if let onload = onload { mergedAttributes["onload"] = onload }
    if let target = target { mergedAttributes["target"] = target }
    if let prompt = prompt { mergedAttributes["prompt"] = prompt }
    if let onfocus = onfocus { mergedAttributes["onfocus"] = onfocus }
    if let enctype = enctype { mergedAttributes["enctype"] = enctype }
    if let onclick = onclick { mergedAttributes["onclick"] = onclick }
    if let onkeyup = onkeyup { mergedAttributes["onkeyup"] = onkeyup }
    if let profile = profile { mergedAttributes["profile"] = profile }
    if let version = version { mergedAttributes["version"] = version }
    if let onreset = onreset { mergedAttributes["onreset"] = onreset }
    if let charset = charset { mergedAttributes["charset"] = charset }
    if let standby = standby { mergedAttributes["standby"] = standby }
    if let colspan = colspan { mergedAttributes["colspan"] = colspan }
    if let charoff = charoff { mergedAttributes["charoff"] = charoff }
    if let classid = classid { mergedAttributes["classid"] = classid }
    if let compact = compact { mergedAttributes["compact"] = compact }
    if let declare = declare { mergedAttributes["declare"] = declare }
    if let rowspan = rowspan { mergedAttributes["rowspan"] = rowspan }
    if let checked = checked { mergedAttributes["checked"] = checked }
    if let archive = archive { mergedAttributes["archive"] = archive }
    if let bgcolor = bgcolor { mergedAttributes["bgcolor"] = bgcolor }
    if let content = content { mergedAttributes["content"] = content }
    if let noshade = noshade { mergedAttributes["noshade"] = noshade }
    if let summary = summary { mergedAttributes["summary"] = summary }
    if let headers = headers { mergedAttributes["headers"] = headers }
    if let onselect = onselect { mergedAttributes["onselect"] = onselect }
    if let readonly = readonly { mergedAttributes["readonly"] = readonly }
    if let tabindex = tabindex { mergedAttributes["tabindex"] = tabindex }
    if let onchange = onchange { mergedAttributes["onchange"] = onchange }
    if let noresize = noresize { mergedAttributes["noresize"] = noresize }
    if let disabled = disabled { mergedAttributes["disabled"] = disabled }
    if let longdesc = longdesc { mergedAttributes["longdesc"] = longdesc }
    if let codebase = codebase { mergedAttributes["codebase"] = codebase }
    if let language = language { mergedAttributes["language"] = language }
    if let datetime = datetime { mergedAttributes["datetime"] = datetime }
    if let selected = selected { mergedAttributes["selected"] = selected }
    if let hreflang = hreflang { mergedAttributes["hreflang"] = hreflang }
    if let onsubmit = onsubmit { mergedAttributes["onsubmit"] = onsubmit }
    if let multiple = multiple { mergedAttributes["multiple"] = multiple }
    if let onunload = onunload { mergedAttributes["onunload"] = onunload }
    if let codetype = codetype { mergedAttributes["codetype"] = codetype }
    if let scrolling = scrolling { mergedAttributes["scrolling"] = scrolling }
    if let onkeydown = onkeydown { mergedAttributes["onkeydown"] = onkeydown }
    if let maxlength = maxlength { mergedAttributes["maxlength"] = maxlength }
    if let valuetype = valuetype { mergedAttributes["valuetype"] = valuetype }
    if let accesskey = accesskey { mergedAttributes["accesskey"] = accesskey }
    if let onmouseup = onmouseup { mergedAttributes["onmouseup"] = onmouseup }
    if let onkeypress = onkeypress { mergedAttributes["onkeypress"] = onkeypress }
    if let ondblclick = ondblclick { mergedAttributes["ondblclick"] = ondblclick }
    if let onmouseout = onmouseout { mergedAttributes["onmouseout"] = onmouseout }
    if let httpEquiv = httpEquiv { mergedAttributes["http-equiv"] = httpEquiv }
    if let background = background { mergedAttributes["background"] = background }
    if let onmousemove = onmousemove { mergedAttributes["onmousemove"] = onmousemove }
    if let onmouseover = onmouseover { mergedAttributes["onmouseover"] = onmouseover }
    if let cellpadding = cellpadding { mergedAttributes["cellpadding"] = cellpadding }
    if let onmousedown = onmousedown { mergedAttributes["onmousedown"] = onmousedown }
    if let frameborder = frameborder { mergedAttributes["frameborder"] = frameborder }
    if let marginwidth = marginwidth { mergedAttributes["marginwidth"] = marginwidth }
    if let cellspacing = cellspacing { mergedAttributes["cellspacing"] = cellspacing }
    if let placeholder = placeholder { mergedAttributes["placeholder"] = placeholder }
    if let marginheight = marginheight { mergedAttributes["marginheight"] = marginheight }
    if let acceptCharset = acceptCharset { mergedAttributes["accept-charset"] = acceptCharset }
    
    for item in attrs.enumerated() {
        mergedAttributes.updateValue(item.element.1, forKey: item.element.0)
    }
    
    output = output + mergedAttributes.reduce("") {
        if let value = $0.1.1 {
            return $0.0 + " \($0.1.0)=\"\(value)\""
        } else {
            return $0.0
        }
    }
    
    if let inner = inner {
        ScopesBuffer[Process.tid] = output + ">" + (inner) + "</" + node + ">"
    } else {
        let current = ScopesBuffer[Process.tid]  ?? ""
        ScopesBuffer[Process.tid] = output + ">" + current + "</" + node + ">"
    }
    
    // Pop the attributes.
    
    idd = stackid
    dir = stackdir
    rel = stackrel
    rev = stackrev
    alt = stackalt
    forr = stackfor
    src = stacksrc
    type = stacktype
    href = stackhref
    text = stacktext
    abbr = stackabbr
    size = stacksize
    face = stackface
    char = stackchar
    cite = stackcite
    span = stackspan
    data = stackdata
    axis = stackaxis
    Name = stackName
    name = stackname
    code = stackcode
    link = stacklink
    lang = stacklang
    cols = stackcols
    rows = stackrows
    ismap = stackismap
    shape = stackshape
    style = stackstyle
    alink = stackalink
    width = stackwidth
    rules = stackrules
    align = stackalign
    frame = stackframe
    vlink = stackvlink
    deferr = stackdefer
    color = stackcolor
    media = stackmedia
    title = stacktitle
    scope = stackscope
    classs = stackclass
    value = stackvalue
    clear = stackclear
    start = stackstart
    label = stacklabel
    action = stackaction
    height = stackheight
    method = stackmethod
    acceptt = stackaccept
    object = stackobject
    scheme = stackscheme
    coords = stackcoords
    usemap = stackusemap
    onblur = stackonblur
    nohref = stacknohref
    nowrap = stacknowrap
    hspace = stackhspace
    border = stackborder
    valign = stackvalign
    vspace = stackvspace
    onload = stackonload
    target = stacktarget
    prompt = stackprompt
    onfocus = stackonfocus
    enctype = stackenctype
    onclick = stackonclick
    onkeyup = stackonkeyup
    profile = stackprofile
    version = stackversion
    onreset = stackonreset
    charset = stackcharset
    standby = stackstandby
    colspan = stackcolspan
    charoff = stackcharoff
    classid = stackclassid
    compact = stackcompact
    declare = stackdeclare
    rowspan = stackrowspan
    checked = stackchecked
    archive = stackarchive
    bgcolor = stackbgcolor
    content = stackcontent
    noshade = stacknoshade
    summary = stacksummary
    headers = stackheaders
    onselect = stackonselect
    readonly = stackreadonly
    tabindex = stacktabindex
    onchange = stackonchange
    noresize = stacknoresize
    disabled = stackdisabled
    longdesc = stacklongdesc
    codebase = stackcodebase
    language = stacklanguage
    datetime = stackdatetime
    selected = stackselected
    hreflang = stackhreflang
    onsubmit = stackonsubmit
    multiple = stackmultiple
    onunload = stackonunload
    codetype = stackcodetype
    scrolling = stackscrolling
    onkeydown = stackonkeydown
    maxlength = stackmaxlength
    valuetype = stackvaluetype
    accesskey = stackaccesskey
    onmouseup = stackonmouseup
    onkeypress = stackonkeypress
    ondblclick = stackondblclick
    onmouseout = stackonmouseout
    httpEquiv = stackhttpEquiv
    background = stackbackground
    onmousemove = stackonmousemove
    onmouseover = stackonmouseover
    cellpadding = stackcellpadding
    onmousedown = stackonmousedown
    frameborder = stackframeborder
    placeholder = stackplaceholder
    marginwidth = stackmarginwidth
    cellspacing = stackcellspacing
    marginheight = stackmarginheight
    acceptCharset = stackacceptCharset
    
    inner = stackinner
}
//
//  Socket+File.swift
//  Swifter
//
//  Created by Damian Kolakowski on 13/07/16.
//

import Foundation

#if os(iOS) || os(tvOS) || os (Linux)
    struct sf_hdtr { }
    
    private func sendfileImpl(_ source: UnsafeMutablePointer<FILE>, _ target: Int32, _: off_t, _: UnsafeMutablePointer<off_t>, _: UnsafeMutablePointer<sf_hdtr>, _: Int32) -> Int32 {
        var buffer = [UInt8](repeating: 0, count: 1024)
        while true {
            let readResult = fread(&buffer, 1, buffer.count, source)
            guard readResult > 0 else {
                return Int32(readResult)
            }
            var writeCounter = 0
            while writeCounter < readResult {
                let writeResult = write(target, &buffer + writeCounter, readResult - writeCounter)
                guard writeResult > 0 else {
                    return Int32(writeResult)
                }
                writeCounter = writeCounter + writeResult
            }
        }
    }
#endif

extension Socket {
    
    public func writeFile(_ file: String.File) throws -> Void {
        var offset: off_t = 0
        var sf: sf_hdtr = sf_hdtr()
        
        #if os(iOS) || os(tvOS) || os (Linux)
        let result = sendfileImpl(file.pointer, self.socketFileDescriptor, 0, &offset, &sf, 0)
        #else
        let result = sendfile(fileno(file.pointer), self.socketFileDescriptor, 0, &offset, &sf, 0)
        #endif
        
        if result == -1 {
            throw SocketError.writeFailed("sendfile: " + Errno.description())
        }
    }
    
}
//
//  Socket+Server.swift
//  Swifter
//
//  Created by Damian Kolakowski on 13/07/16.
//

import Foundation

extension Socket {

    /// - Parameters:
    ///   - listenAddress: String representation of the address the socket should accept
    ///       connections from. It should be in IPv4 format if forceIPv4 == true,
    ///       otherwise - in IPv6.
    public class func tcpSocketForListen(_ port: in_port_t, _ forceIPv4: Bool = false, _ maxPendingConnection: Int32 = SOMAXCONN, _ listenAddress: String? = nil) throws -> Socket {

        #if os(Linux)
            let socketFileDescriptor = socket(forceIPv4 ? AF_INET : AF_INET6, Int32(SOCK_STREAM.rawValue), 0)
        #else
            let socketFileDescriptor = socket(forceIPv4 ? AF_INET : AF_INET6, SOCK_STREAM, 0)
        #endif

        if socketFileDescriptor == -1 {
            throw SocketError.socketCreationFailed(Errno.description())
        }

        var value: Int32 = 1
        if setsockopt(socketFileDescriptor, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(MemoryLayout<Int32>.size)) == -1 {
            let details = Errno.description()
            Socket.close(socketFileDescriptor)
            throw SocketError.socketSettingReUseAddrFailed(details)
        }
        Socket.setNoSigPipe(socketFileDescriptor)

        var bindResult: Int32 = -1
        if forceIPv4 {
            #if os(Linux)
            var addr = sockaddr_in(
                sin_family: sa_family_t(AF_INET),
                sin_port: port.bigEndian,
                sin_addr: in_addr(s_addr: in_addr_t(0)),
                sin_zero:(0, 0, 0, 0, 0, 0, 0, 0))
            #else
            var addr = sockaddr_in(
                sin_len: UInt8(MemoryLayout<sockaddr_in>.stride),
                sin_family: UInt8(AF_INET),
                sin_port: port.bigEndian,
                sin_addr: in_addr(s_addr: in_addr_t(0)),
                sin_zero:(0, 0, 0, 0, 0, 0, 0, 0))
            #endif
            if let address = listenAddress {
              if address.withCString({ cstring in inet_pton(AF_INET, cstring, &addr.sin_addr) }) == 1 {
                // print("\(address) is converted to \(addr.sin_addr).")
              } else {
                // print("\(address) is not converted.")
              }
            }
            bindResult = withUnsafePointer(to: &addr) {
                bind(socketFileDescriptor, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        } else {
            #if os(Linux)
            var addr = sockaddr_in6(
                sin6_family: sa_family_t(AF_INET6),
                sin6_port: port.bigEndian,
                sin6_flowinfo: 0,
                sin6_addr: in6addr_any,
                sin6_scope_id: 0)
            #else
            var addr = sockaddr_in6(
                sin6_len: UInt8(MemoryLayout<sockaddr_in6>.stride),
                sin6_family: UInt8(AF_INET6),
                sin6_port: port.bigEndian,
                sin6_flowinfo: 0,
                sin6_addr: in6addr_any,
                sin6_scope_id: 0)
            #endif
            if let address = listenAddress {
              if address.withCString({ cstring in inet_pton(AF_INET6, cstring, &addr.sin6_addr) }) == 1 {
                //print("\(address) is converted to \(addr.sin6_addr).")
              } else {
                //print("\(address) is not converted.")
              }
            }
            bindResult = withUnsafePointer(to: &addr) {
                bind(socketFileDescriptor, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in6>.size))
            }
        }

        if bindResult == -1 {
            let details = Errno.description()
            Socket.close(socketFileDescriptor)
            throw SocketError.bindFailed(details)
        }

        if listen(socketFileDescriptor, maxPendingConnection) == -1 {
            let details = Errno.description()
            Socket.close(socketFileDescriptor)
            throw SocketError.listenFailed(details)
        }
        return Socket(socketFileDescriptor: socketFileDescriptor)
    }
    
    public func acceptClientSocket() throws -> Socket {
        var addr = sockaddr()
        var len: socklen_t = 0
        let clientSocket = accept(self.socketFileDescriptor, &addr, &len)
        if clientSocket == -1 {
            throw SocketError.acceptFailed(Errno.description())
        }
        Socket.setNoSigPipe(clientSocket)
        return Socket(socketFileDescriptor: clientSocket)
    }
}
//
//  Socket.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation


public enum SocketError: Error {
    case socketCreationFailed(String)
    case socketSettingReUseAddrFailed(String)
    case bindFailed(String)
    case listenFailed(String)
    case writeFailed(String)
    case getPeerNameFailed(String)
    case convertingPeerNameFailed
    case getNameInfoFailed(String)
    case acceptFailed(String)
    case recvFailed(String)
    case getSockNameFailed(String)
}

open class Socket: Hashable, Equatable {
        
    let socketFileDescriptor: Int32
    private var shutdown = false

    
    public init(socketFileDescriptor: Int32) {
        self.socketFileDescriptor = socketFileDescriptor
    }
    
    deinit {
        close()
    }
    
    public var hashValue: Int { return Int(self.socketFileDescriptor) }
    
    public func close() {
        if shutdown {
            return
        }
        shutdown = true
        Socket.close(self.socketFileDescriptor)
    }
    
    public func port() throws -> in_port_t {
        var addr = sockaddr_in()
        return try withUnsafePointer(to: &addr) { pointer in
            var len = socklen_t(MemoryLayout<sockaddr_in>.size)
            if getsockname(socketFileDescriptor, UnsafeMutablePointer(OpaquePointer(pointer)), &len) != 0 {
                throw SocketError.getSockNameFailed(Errno.description())
            }
            #if os(Linux)
                return ntohs(addr.sin_port)
            #else
                return Int(OSHostByteOrder()) != OSLittleEndian ? addr.sin_port.littleEndian : addr.sin_port.bigEndian
            #endif
        }
    }
    
    public func isIPv4() throws -> Bool {
        var addr = sockaddr_in()
        return try withUnsafePointer(to: &addr) { pointer in
            var len = socklen_t(MemoryLayout<sockaddr_in>.size)
            if getsockname(socketFileDescriptor, UnsafeMutablePointer(OpaquePointer(pointer)), &len) != 0 {
                throw SocketError.getSockNameFailed(Errno.description())
            }
            return Int32(addr.sin_family) == AF_INET
        }
    }
    
    public func writeUTF8(_ string: String) throws {
        try writeUInt8(ArraySlice(string.utf8))
    }
    
    public func writeUInt8(_ data: [UInt8]) throws {
        try writeUInt8(ArraySlice(data))
    }
    
    public func writeUInt8(_ data: ArraySlice<UInt8>) throws {
        try data.withUnsafeBufferPointer {
            try writeBuffer($0.baseAddress!, length: data.count)
        }
    }

    public func writeData(_ data: NSData) throws {
        try writeBuffer(data.bytes, length: data.length)
    }
    
    public func writeData(_ data: Data) throws {
        try data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> Void in
            try self.writeBuffer(pointer, length: data.count)
        }
    }

    private func writeBuffer(_ pointer: UnsafeRawPointer, length: Int) throws {
        var sent = 0
        while sent < length {
            #if os(Linux)
                let s = send(self.socketFileDescriptor, pointer + sent, Int(length - sent), Int32(MSG_NOSIGNAL))
            #else
                let s = write(self.socketFileDescriptor, pointer + sent, Int(length - sent))
            #endif
            if s <= 0 {
                throw SocketError.writeFailed(Errno.description())
            }
            sent += s
        }
    }
    
    open func read() throws -> UInt8 {
        var buffer = [UInt8](repeating: 0, count: 1)
        let next = recv(self.socketFileDescriptor as Int32, &buffer, Int(buffer.count), 0)
        if next <= 0 {
            throw SocketError.recvFailed(Errno.description())
        }
        return buffer[0]
    }
    
    private static let CR = UInt8(13)
    private static let NL = UInt8(10)
    
    public func readLine() throws -> String {
        var characters: String = ""
        var n: UInt8 = 0
        repeat {
            n = try self.read()
            if n > Socket.CR { characters.append(Character(UnicodeScalar(n))) }
        } while n != Socket.NL
        return characters
    }
    
    public func peername() throws -> String {
        var addr = sockaddr(), len: socklen_t = socklen_t(MemoryLayout<sockaddr>.size)
        if getpeername(self.socketFileDescriptor, &addr, &len) != 0 {
            throw SocketError.getPeerNameFailed(Errno.description())
        }
        var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        if getnameinfo(&addr, len, &hostBuffer, socklen_t(hostBuffer.count), nil, 0, NI_NUMERICHOST) != 0 {
            throw SocketError.getNameInfoFailed(Errno.description())
        }
        return String(cString: hostBuffer)
    }
    
    public class func setNoSigPipe(_ socket: Int32) {
        #if os(Linux)
            // There is no SO_NOSIGPIPE in Linux (nor some other systems). You can instead use the MSG_NOSIGNAL flag when calling send(),
            // or use signal(SIGPIPE, SIG_IGN) to make your entire application ignore SIGPIPE.
        #else
            // Prevents crashes when blocking calls are pending and the app is paused ( via Home button ).
            var no_sig_pipe: Int32 = 1
            setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
        #endif
    }
    
    public class func close(_ socket: Int32) {
        #if os(Linux)
            let _ = Glibc.close(socket)
        #else
            let _ = Darwin.close(socket)
        #endif
    }
}

public func == (socket1: Socket, socket2: Socket) -> Bool {
    return socket1.socketFileDescriptor == socket2.socketFileDescriptor
}
//
//  String+BASE64.swift
//  Swifter
//
//  Copyright © 2016 Damian Kołakowski. All rights reserved.
//

import Foundation


extension String {
    
    private static let CODES = [UInt8]("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=".utf8)
    
    public static func toBase64(_ data: [UInt8]) -> String? {
        
        // Based on: https://en.wikipedia.org/wiki/Base64#Sample_Implementation_in_Java
        
        var result = [UInt8]()
        var tmp: UInt8
        for index in stride(from: 0, to: data.count, by: 3) {
            let byte = data[index]
            tmp = (byte & 0xFC) >> 2;
            result.append(CODES[Int(tmp)])
            tmp = (byte & 0x03) << 4;
            if index + 1 < data.count {
                tmp |= (data[index + 1] & 0xF0) >> 4;
                result.append(CODES[Int(tmp)]);
                tmp = (data[index + 1] & 0x0F) << 2;
                if (index + 2 < data.count)  {
                    tmp |= (data[index + 2] & 0xC0) >> 6;
                    result.append(CODES[Int(tmp)]);
                    tmp = data[index + 2] & 0x3F;
                    result.append(CODES[Int(tmp)]);
                } else  {
                    result.append(CODES[Int(tmp)]);
                    result.append(contentsOf: [UInt8]("=".utf8));
                }
            } else {
                result.append(CODES[Int(tmp)]);
                result.append(contentsOf: [UInt8]("==".utf8));
            }
        }
        return String(bytes: result, encoding: .utf8)
    }
}
//
//  String+File.swift
//  Swifter
//
//  Copyright © 2016 Damian Kołakowski. All rights reserved.
//

import Foundation


extension String {
    
    public enum FileError: Error {
        case error(Int32)
    }
    
    public class File {
        
        let pointer: UnsafeMutablePointer<FILE>
        
        public init(_ pointer: UnsafeMutablePointer<FILE>) {
            self.pointer = pointer
        }
        
        public func close() -> Void {
            fclose(pointer)
        }
        
        public func seek(_ offset: Int) -> Bool {
            return (fseek(pointer, offset, SEEK_SET) == 0)
        }
        
        public func read(_ data: inout [UInt8]) throws -> Int {
            if data.count <= 0 {
                return data.count
            }
            let count = fread(&data, 1, data.count, self.pointer)
            if count == data.count {
                return count
            }
            if feof(self.pointer) != 0 {
                return count
            }
            if ferror(self.pointer) != 0 {
                throw FileError.error(errno)
            }
            throw FileError.error(0)
        }
        
        public func write(_ data: [UInt8]) throws -> Void {
            if data.count <= 0 {
                return
            }
            try data.withUnsafeBufferPointer {
                if fwrite($0.baseAddress, 1, data.count, self.pointer) != data.count {
                    throw FileError.error(errno)
                }
            }
        }
        
        public static func currentWorkingDirectory() throws -> String {
            guard let path = getcwd(nil, 0) else {
                throw FileError.error(errno)
            }
            return String(cString: path)
        }
    }
    
    public static var pathSeparator = "/"
    
    public func openNewForWriting() throws -> File {
        return try openFileForMode(self, "wb")
    }
    
    public func openForReading() throws -> File {
        return try openFileForMode(self, "rb")
    }
    
    public func openForWritingAndReading() throws -> File {
        return try openFileForMode(self, "r+b")
    }
    
    public func openFileForMode(_ path: String, _ mode: String) throws -> File {
        guard let file = path.withCString({ pathPointer in mode.withCString({ fopen(pathPointer, $0) }) }) else {
            throw FileError.error(errno)
        }
        return File(file)
    }
    
    public func exists() throws -> Bool {
        return try self.withStat {
            if let _ = $0 {
                return true
            }
            return false
        }
    }
    
    public func directory() throws -> Bool {
        return try self.withStat {
            if let stat = $0 {
                return stat.st_mode & S_IFMT == S_IFDIR
            }
            return false
        }
    }
    
    public func files() throws -> [String] {
        guard let dir = self.withCString({ opendir($0) }) else {
            throw FileError.error(errno)
        }
        defer { closedir(dir) }
        var results = [String]()
        while let ent = readdir(dir) {
            var name = ent.pointee.d_name
            let fileName = withUnsafePointer(to: &name) { (ptr) -> String? in
                #if os(Linux)
                    return String(validatingUTF8: [CChar](UnsafeBufferPointer<CChar>(start: UnsafePointer(unsafeBitCast(ptr, to: UnsafePointer<CChar>.self)), count: 256)))
                #else
                    var buffer = [CChar](UnsafeBufferPointer(start: unsafeBitCast(ptr, to: UnsafePointer<CChar>.self), count: Int(ent.pointee.d_namlen)))
                    buffer.append(0)
                    return String(validatingUTF8: buffer)
                #endif
            }
            if let fileName = fileName {
                results.append(fileName)
            }
        }
        return results
    }
    
    private func withStat<T>(_ closure: ((stat?) throws -> T)) throws -> T {
        return try self.withCString({
            var statBuffer = stat()
            if stat($0, &statBuffer) == 0 {
                return try closure(statBuffer)
            }
            if errno == ENOENT {
                return try closure(nil)
            }
            throw FileError.error(errno)
        })
    }
}
//
//  String+Misc.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation


extension String {
    
    public func unquote() -> String {
        var scalars = self.unicodeScalars;
        if scalars.first == "\"" && scalars.last == "\"" && scalars.count >= 2 {
            scalars.removeFirst();
            scalars.removeLast();
            return String(scalars)
        }
        return self
    }
}

extension UnicodeScalar {
    
    public func asWhitespace() -> UInt8? {
        if self.value >= 9 && self.value <= 13 {
            return UInt8(self.value)
        }
        if self.value == 32 {
            return UInt8(self.value)
        }
        return nil
    }
    
}
//
//  String+SHA1.swift
//  Swifter
//
//  Copyright 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation


public struct SHA1 {
    
    public static func hash(_ input: [UInt8]) -> [UInt8] {
        
        // Alghorithm from: https://en.wikipedia.org/wiki/SHA-1
        
        var message = input
        
        var h0 = UInt32(littleEndian: 0x67452301)
        var h1 = UInt32(littleEndian: 0xEFCDAB89)
        var h2 = UInt32(littleEndian: 0x98BADCFE)
        var h3 = UInt32(littleEndian: 0x10325476)
        var h4 = UInt32(littleEndian: 0xC3D2E1F0)
        
        // ml = message length in bits (always a multiple of the number of bits in a character).
        
        let ml = UInt64(message.count * 8)
        
        // append the bit '1' to the message e.g. by adding 0x80 if message length is a multiple of 8 bits.
        
        message.append(0x80)
        
        // append 0 ≤ k < 512 bits '0', such that the resulting message length in bits is congruent to −64 ≡ 448 (mod 512)
        
        let padBytesCount = ( message.count + 8 ) % 64
        
        message.append(contentsOf: [UInt8](repeating: 0, count: 64 - padBytesCount))
        
        // append ml, in a 64-bit big-endian integer. Thus, the total length is a multiple of 512 bits.
        
        var mlBigEndian = ml.bigEndian
        withUnsafePointer(to: &mlBigEndian) {
            message.append(contentsOf: Array(UnsafeBufferPointer<UInt8>(start: UnsafePointer(OpaquePointer($0)), count: 8)))
        }
        
        // Process the message in successive 512-bit chunks ( 64 bytes chunks ):
        
        for chunkStart in 0..<message.count/64 {
            var words = [UInt32]()
            let chunk = message[chunkStart*64..<chunkStart*64+64]
            
            // break chunk into sixteen 32-bit big-endian words w[i], 0 ≤ i ≤ 15
            
            for i in 0...15 {
                let value = chunk.withUnsafeBufferPointer({ UnsafePointer<UInt32>(OpaquePointer($0.baseAddress! + (i*4))).pointee})
                words.append(value.bigEndian)
            }
            
            // Extend the sixteen 32-bit words into eighty 32-bit words:
            
            for i in 16...79 {
                let value: UInt32 = ((words[i-3]) ^ (words[i-8]) ^ (words[i-14]) ^ (words[i-16]))
                words.append(rotateLeft(value, 1))
            }
            
            // Initialize hash value for this chunk:
            
            var a = h0
            var b = h1
            var c = h2
            var d = h3
            var e = h4
            
            for i in 0..<80 {
                var f = UInt32(0)
                var k = UInt32(0)
                switch i {
                case 0...19:
                    f = (b & c) | ((~b) & d)
                    k = 0x5A827999
                case 20...39:
                    f = b ^ c ^ d
                    k = 0x6ED9EBA1
                case 40...59:
                    f = (b & c) | (b & d) | (c & d)
                    k = 0x8F1BBCDC
                case 60...79:
                    f = b ^ c ^ d
                    k = 0xCA62C1D6
                default: break
                }
                let temp = (rotateLeft(a, 5) &+ f &+ e &+ k &+ words[i]) & 0xFFFFFFFF
                e = d
                d = c
                c = rotateLeft(b, 30)
                b = a
                a = temp
            }
            
            // Add this chunk's hash to result so far:
            
            h0 = ( h0 &+ a ) & 0xFFFFFFFF
            h1 = ( h1 &+ b ) & 0xFFFFFFFF
            h2 = ( h2 &+ c ) & 0xFFFFFFFF
            h3 = ( h3 &+ d ) & 0xFFFFFFFF
            h4 = ( h4 &+ e ) & 0xFFFFFFFF
        }
        
        // Produce the final hash value (big-endian) as a 160 bit number:
        
        var digest = [UInt8]()
        
        [h0, h1, h2, h3, h4].forEach { value in
            var bigEndianVersion = value.bigEndian
            withUnsafePointer(to: &bigEndianVersion) {
                digest.append(contentsOf: Array(UnsafeBufferPointer<UInt8>(start: UnsafePointer(OpaquePointer($0)), count: 4)))
            }
        }
        
        return digest
    }
    
    private static func rotateLeft(_ v: UInt32, _ n: UInt32) -> UInt32 {
        return ((v << n) & 0xFFFFFFFF) | (v >> (32 - n))
    }
}

extension String {
    
    public func sha1() -> [UInt8] {
        return SHA1.hash([UInt8](self.utf8))
    }
    
    public func sha1() -> String {
        return self.sha1().reduce("") { $0 + String(format: "%02x", $1) }
    }
}
//
//  HttpHandlers+WebSockets.swift
//  Swifter
//
//  Copyright © 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation


public func websocket(
      _ text: ((WebSocketSession, String) -> Void)?,
    _ binary: ((WebSocketSession, [UInt8]) -> Void)?) -> ((HttpRequest) -> HttpResponse) {
    return { r in
        guard r.hasTokenForHeader("upgrade", token: "websocket") else {
            return .badRequest(.text("Invalid value of 'Upgrade' header: \(r.headers["upgrade"])"))
        }
        guard r.hasTokenForHeader("connection", token: "upgrade") else {
            return .badRequest(.text("Invalid value of 'Connection' header: \(r.headers["connection"])"))
        }
        guard let secWebSocketKey = r.headers["sec-websocket-key"] else {
            return .badRequest(.text("Invalid value of 'Sec-Websocket-Key' header: \(r.headers["sec-websocket-key"])"))
        }
        let protocolSessionClosure: ((Socket) -> Void) = { socket in
            let session = WebSocketSession(socket)
            var fragmentedOpCode = WebSocketSession.OpCode.close
            var payload = [UInt8]() // Used for fragmented frames.
            
            func handleTextPayload(_ frame: WebSocketSession.Frame) throws {
                if let handleText = text {
                    if frame.fin {
                        if payload.count > 0 {
                            throw WebSocketSession.WsError.protocolError("Continuing fragmented frame cannot have an operation code.")
                        }
                        var textFramePayload = frame.payload.map { Int8(bitPattern: $0) }
                        textFramePayload.append(0)
                        if let text = String(validatingUTF8: textFramePayload) {
                            handleText(session, text)
                        } else {
                            throw WebSocketSession.WsError.invalidUTF8("")
                        }
                    } else {
                        payload.append(contentsOf: frame.payload)
                        fragmentedOpCode = .text
                    }
                }
            }
            
            func handleBinaryPayload(_ frame: WebSocketSession.Frame) throws {
                if let handleBinary = binary {
                    if frame.fin {
                        if payload.count > 0 {
                            throw WebSocketSession.WsError.protocolError("Continuing fragmented frame cannot have an operation code.")
                        }
                        handleBinary(session, frame.payload)
                    } else {
                        payload.append(contentsOf: frame.payload)
                        fragmentedOpCode = .binary
                    }
                }
            }
            
            func handleOperationCode(_ frame: WebSocketSession.Frame) throws {
                switch frame.opcode {
                case .continue:
                    // There is no message to continue, failed immediatelly.
                    if fragmentedOpCode == .close {
                        socket.close()
                    }
                    frame.opcode = fragmentedOpCode
                    if frame.fin {
                        payload.append(contentsOf: frame.payload)
                        frame.payload = payload
                        // Clean the buffer.
                        payload = []
                        // Reset the OpCode.
                        fragmentedOpCode = WebSocketSession.OpCode.close
                    }
                    try handleOperationCode(frame)
                case .text:
                    try handleTextPayload(frame)
                case .binary:
                    try handleBinaryPayload(frame)
                case .close:
                    throw WebSocketSession.Control.close
                case .ping:
                    if frame.payload.count > 125 {
                        throw WebSocketSession.WsError.protocolError("Payload gretter than 125 octets.")
                    } else {
                        session.writeFrame(ArraySlice(frame.payload), .pong)
                    }
                case .pong:
                    break
                }
            }
            
            do {
                while true {
                    let frame = try session.readFrame()
                    try handleOperationCode(frame)
                }
            } catch let error {
                switch error {
                case WebSocketSession.Control.close:
                    // Normal close
                    break
                case WebSocketSession.WsError.unknownOpCode:
                    print("Unknown Op Code: \(error)")
                case WebSocketSession.WsError.unMaskedFrame:
                    print("Unmasked frame: \(error)")
                case WebSocketSession.WsError.invalidUTF8:
                    print("Invalid UTF8 character: \(error)")
                case WebSocketSession.WsError.protocolError:
                    print("Protocol error: \(error)")
                default:
                    print("Unkown error \(error)")
                }
                // If an error occurs, send the close handshake.
                session.writeCloseFrame()
            }
        }
        guard let secWebSocketAccept = String.toBase64((secWebSocketKey + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").sha1()) else {
            return HttpResponse.internalServerError
        }
        let headers = ["Upgrade": "WebSocket", "Connection": "Upgrade", "Sec-WebSocket-Accept": secWebSocketAccept]
        return HttpResponse.switchProtocols(headers, protocolSessionClosure)
    }
}

public class WebSocketSession: Hashable, Equatable  {
    
    public enum WsError: Error { case unknownOpCode(String), unMaskedFrame(String), protocolError(String), invalidUTF8(String) }
    public enum OpCode: UInt8 { case `continue` = 0x00, close = 0x08, ping = 0x09, pong = 0x0A, text = 0x01, binary = 0x02 }
    public enum Control: Error { case close }
    
    public class Frame {
        public var opcode = OpCode.close
        public var fin = false
        public var rsv1: UInt8 = 0
        public var rsv2: UInt8 = 0
        public var rsv3: UInt8 = 0
        public var payload = [UInt8]()
    }

    let socket: Socket
    
    public init(_ socket: Socket) {
        self.socket = socket
    }
    
    deinit {
        writeCloseFrame()
        socket.close()
    }
    
    public func writeText(_ text: String) -> Void {
        self.writeFrame(ArraySlice(text.utf8), OpCode.text)
    }

    public func writeBinary(_ binary: [UInt8]) -> Void {
        self.writeBinary(ArraySlice(binary))
    }
    
    public func writeBinary(_ binary: ArraySlice<UInt8>) -> Void {
        self.writeFrame(binary, OpCode.binary)
    }
    
    public func writeFrame(_ data: ArraySlice<UInt8>, _ op: OpCode, _ fin: Bool = true) {
        let finAndOpCode = UInt8(fin ? 0x80 : 0x00) | op.rawValue
        let maskAndLngth = encodeLengthAndMaskFlag(UInt64(data.count), false)
        do {
            try self.socket.writeUInt8([finAndOpCode])
            try self.socket.writeUInt8(maskAndLngth)
            try self.socket.writeUInt8(data)
        } catch {
            print(error)
        }
    }
    
    public func writeCloseFrame() {
        writeFrame(ArraySlice("".utf8), .close)
    }
    
    private func encodeLengthAndMaskFlag(_ len: UInt64, _ masked: Bool) -> [UInt8] {
        let encodedLngth = UInt8(masked ? 0x80 : 0x00)
        var encodedBytes = [UInt8]()
        switch len {
        case 0...125:
            encodedBytes.append(encodedLngth | UInt8(len));
        case 126...UInt64(UINT16_MAX):
            encodedBytes.append(encodedLngth | 0x7E);
            encodedBytes.append(UInt8(len >> 8 & 0xFF));
            encodedBytes.append(UInt8(len >> 0 & 0xFF));
        default:
            encodedBytes.append(encodedLngth | 0x7F);
            encodedBytes.append(UInt8(len >> 56 & 0xFF));
            encodedBytes.append(UInt8(len >> 48 & 0xFF));
            encodedBytes.append(UInt8(len >> 40 & 0xFF));
            encodedBytes.append(UInt8(len >> 32 & 0xFF));
            encodedBytes.append(UInt8(len >> 24 & 0xFF));
            encodedBytes.append(UInt8(len >> 16 & 0xFF));
            encodedBytes.append(UInt8(len >> 08 & 0xFF));
            encodedBytes.append(UInt8(len >> 00 & 0xFF));
        }
        return encodedBytes
    }
    
    public func readFrame() throws -> Frame {
        let frm = Frame()
        let fst = try socket.read()
        frm.fin = fst & 0x80 != 0
        frm.rsv1 = fst & 0x40
        frm.rsv2 = fst & 0x20
        frm.rsv3 = fst & 0x10
        guard frm.rsv1 == 0 && frm.rsv2 == 0 && frm.rsv3 == 0
            else {
            throw WsError.protocolError("Reserved frame bit has not been negocitated.")
        }
        let opc = fst & 0x0F
        guard let opcode = OpCode(rawValue: opc) else {
            // "If an unknown opcode is received, the receiving endpoint MUST _Fail the WebSocket Connection_."
            // http://tools.ietf.org/html/rfc6455#section-5.2 ( Page 29 )
            throw WsError.unknownOpCode("\(opc)")
        }
        if frm.fin == false {
            switch opcode {
            case .ping, .pong, .close:
                // Control frames must not be fragmented
                // https://tools.ietf.org/html/rfc6455#section-5.5 ( Page 35 )
                throw WsError.protocolError("Control frames must not be fragmented.")
            default:
                break
            }
        }
        frm.opcode = opcode
        let sec = try socket.read()
        let msk = sec & 0x80 != 0
        guard msk else {
            // "...a client MUST mask all frames that it sends to the server."
            // http://tools.ietf.org/html/rfc6455#section-5.1
            throw WsError.unMaskedFrame("A client must mask all frames that it sends to the server.")
        }
        var len = UInt64(sec & 0x7F)
        if len == 0x7E {
            let b0 = UInt64(try socket.read())
            let b1 = UInt64(try socket.read())
            len = UInt64(littleEndian: b0 << 8 | b1)
        } else if len == 0x7F {
            let b0 = UInt64(try socket.read())
            let b1 = UInt64(try socket.read())
            let b2 = UInt64(try socket.read())
            let b3 = UInt64(try socket.read())
            let b4 = UInt64(try socket.read())
            let b5 = UInt64(try socket.read())
            let b6 = UInt64(try socket.read())
            let b7 = UInt64(try socket.read())
            len = UInt64(littleEndian: b0 << 54 | b1 << 48 | b2 << 40 | b3 << 32 | b4 << 24 | b5 << 16 | b6 << 8 | b7)
        }
        let mask = [try socket.read(), try socket.read(), try socket.read(), try socket.read()]
        for i in 0..<len {
            frm.payload.append(try socket.read() ^ mask[Int(i % 4)])
        }
        return frm
    }
    
    public var hashValue: Int {
        get {
            return socket.hashValue
        }
    }
}

public func ==(webSocketSession1: WebSocketSession, webSocketSession2: WebSocketSession) -> Bool {
    return webSocketSession1.socket == webSocketSession2.socket
}
