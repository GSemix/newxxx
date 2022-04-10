//
//  ClassFildErrors.swift
//  xxx
//
//  Created by Семен Безгин on 07.04.2022.
//

import SwiftUI

enum errorSignal {
    case start
    case end
    case all
    case nothing
}

class FieldErrors {
    public var errorInput: String
    public var errorType: errorSignal
    public var fastErrorInput: String
    public var fastErrorType: errorSignal
    
    init() {
        self.errorInput = ""
        self.errorType = .nothing
        self.fastErrorInput = ""
        self.fastErrorType = .nothing
    }
    
    public func setErrorInput(text: String) {
        self.errorInput = text
    }
    
    public func setErrorType(error: errorSignal) {
        self.errorType = error
    }
    
    public func setFastErrorInput(text: String) {
        self.fastErrorInput = text
    }
    
    public func setFastErrorType(error: errorSignal) {
        self.fastErrorType = error
    }
    
    public func getErrorInput() -> String {
        self.errorInput
    }
    
    public func getErrorType() -> errorSignal {
        self.errorType
    }
    
    public func getFastErrorInput() -> String {
        self.fastErrorInput
    }
    
    public func getFastErrorType() -> errorSignal {
        self.fastErrorType
    }
}
