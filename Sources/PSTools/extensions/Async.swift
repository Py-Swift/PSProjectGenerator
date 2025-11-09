//
//  Async.swift
//  PSProjectGenerator
//
//  Created by CodeBuilder on 08/11/2025.
//

import PySwiftKit
import PySerializing


public func withGIL(_ operation: @escaping () async throws ->Void) async rethrows {
    let gil = PyGILState_Ensure()
    
    try await operation()
    
    PyGILState_Release(gil)
}
