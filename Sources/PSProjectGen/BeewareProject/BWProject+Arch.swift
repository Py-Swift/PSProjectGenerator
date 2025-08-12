//
//  BWProject+Arch.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 03/08/2025.
//

import PathKit
import Foundation


extension BWProject {
    public enum Arch: String, CustomStringConvertible {
        case arm64
        case x86_64
        
        public var description: String { rawValue }
        
    }
}
