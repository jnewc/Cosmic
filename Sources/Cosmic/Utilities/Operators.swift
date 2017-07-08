//
//  Operators.swift
//  Cosmic
//
//  Created by Jack Newcombe on 27/06/2017.
//  Copyright © 2017 Jack Newcombe. All rights reserved.
//

import Foundation


/// Conditional execution operator
///
/// For a given argument:
/// * if the argument is truthy (i.e. true or non-nil), execute closure
/// * if the argument is falsy (i.e. false or nil), do not execute the closure
infix operator => : NilCoalescingPrecedence

public func =>(state: Bool, closure: @autoclosure () -> ()) {
    if state { closure() }
}

public func =><T>(state: Bool, closure: @autoclosure () -> (T)) -> T? {
    if state { return closure() }
    return nil
}

public func =><T>(state: Optional<T>, closure: @autoclosure () -> ()) {
    if state != nil { closure() }
}

public func =><T, U>(state: Optional<T>, closure: @autoclosure () -> (U)) -> U? {
    if state != nil { return closure() }
    return nil
}

///

