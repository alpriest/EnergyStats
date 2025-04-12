//
//  Pulse+URLSession.swift
//  Energy Stats
//
//  Created by Alistair Priest on 12/04/2025.
//

import Energy_Stats_Core
import Pulse

typealias URLSessionProtocol = Energy_Stats_Core.URLSessionProtocol

extension URLSessionProxy: @retroactive URLSessionProtocol {}
