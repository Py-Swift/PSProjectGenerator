//
//  URLSession.swift
//  PythonSwiftProject
//
import Foundation
import PathKit

extension URLSession {
    public static func download(from url: URL, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (Path, URLResponse) {
        let result: (URL, URLResponse) = try await shared.download(from: url)
        return (Path(result.0.path()), result.1)
    }
}
