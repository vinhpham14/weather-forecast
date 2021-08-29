//
//  SearchForecastRepository.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import Foundation


public enum SearchForecastResult {
    case success(_ items: [WeatherForecastItem])
    case failure(_ error: Swift.Error)
}

public struct SearchForecastParameters {
    public let cityName: String
    public let maximumForecastDay: Int
    public let unit: UnitTemperature
    
    public func encode() -> String {
        return "q=\(cityName)&cnt=\(maximumForecastDay)&\(unit.description)"
    }
    
    public init(_ cityName: String, _ maximumForecastDay: Int, _ unit: UnitTemperature) {
        self.cityName = cityName
        self.maximumForecastDay = maximumForecastDay
        self.unit = unit
    }
}

public protocol SearchForecastRepository {
    typealias SearchParameters = SearchForecastParameters
    typealias Result = SearchForecastResult
    
    func searchForecast(_ parameters: SearchParameters, completion: @escaping (SearchForecastResult) -> Void)
}

