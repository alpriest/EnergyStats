//
//  URLSessionProtocol.swift
//  Energy Stats
//
//  Created by Alistair Priest on 12/04/2025.
//

public protocol URLSessionProtocol {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
