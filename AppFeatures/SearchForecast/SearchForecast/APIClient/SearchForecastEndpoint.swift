//
//  SearchForecastEndpoint.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation


public struct ForecastEndpoint {
    public typealias Unit = UnitTemperature
    private let baseURL: URL
    private let appID: String
    
    public init(baseURL: URL, appID: String) {
        self.baseURL = baseURL
        self.appID = appID
    }
    
    public func search(keyword: String, maximumForcastDay: Int, unit: Unit) -> URL {
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = baseURL.path + "/data/2.5/forecast"
        components.queryItems = [
            URLQueryItem(name: "q", value: keyword),
            URLQueryItem(name: "cnt", value: "\(maximumForcastDay)"),
            URLQueryItem(name: "units", value: unit.stringParam),
            URLQueryItem(name: "appid", value: appID)
        ].compactMap { $0 }
        return components.url!
    }
}


private extension UnitTemperature {
    var stringParam: String {
        switch self {
        case .celsius:
            return "metric"
        case .fahrenheit:
            return "imperial"
        default:
            return "standard"
        }
    }
}
