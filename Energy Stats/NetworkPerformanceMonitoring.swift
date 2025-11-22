//
//  FirebaseNetworkTracer.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/11/2025.
//

import Energy_Stats_Core

#if targetEnvironment(macCatalyst)
// Unsupported by Firebase on macCatalyst
class FirebaseNetworkTracer: NetworkTracing {
    func didStartRequest(urlRequest: URLRequest) {
    }
    func didEndRequest(responseCode: Int) {
    }
    func didEndRequestWithError(errorCode: Int) {
    }
}
#else
import FirebasePerformance

class FirebaseNetworkTracer: NetworkTracing {
    private static var inFlightMetric: HTTPMetric?
    
    func didStartRequest(urlRequest: URLRequest) {
        guard let url = urlRequest.url else { return }
        
        let method: HTTPMethod = switch urlRequest.httpMethod?.lowercased() {
        case "post":
            .post
        default:
            .get
        }
        
        guard let metric = HTTPMetric(url: url, httpMethod: method) else { return }
        metric.start()
        
        FirebaseNetworkTracer.inFlightMetric = metric
    }

    func didEndRequest(responseCode: Int) {
        guard let metric = FirebaseNetworkTracer.inFlightMetric else { return }
        
        metric.responseCode = 200
        metric.stop()
    }
    
    func didEndRequestWithError(errorCode: Int) {
        guard let metric = FirebaseNetworkTracer.inFlightMetric else { return }
        
        metric.responseCode = 200
        metric.setValue(String(errorCode), forAttribute: "errorCode")
        metric.stop()
    }
}
#endif
