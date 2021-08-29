//
//  SearchForecastEndpoint.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation


public struct ForecastEndpoint {
    public typealias Unit = String
    private let baseURL: URL
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    public func search(keyword: String, maximumForcastDay: Int, unit: Unit) -> URL {
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = baseURL.path + "/forecast/daily"
        components.queryItems = [
            URLQueryItem(name: "q", value: keyword),
            URLQueryItem(name: "cnt", value: "\(maximumForcastDay)"),
            URLQueryItem(name: "units", value: unit)
        ].compactMap { $0 }
        return components.url!
    }
}
