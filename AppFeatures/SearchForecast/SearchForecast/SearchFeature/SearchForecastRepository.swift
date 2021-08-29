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

public protocol SearchForecastRepository {
    typealias SearchParameters = (cityName: String, maximumForecastDay: Int, unit: UnitTemperature)
    typealias Result = SearchForecastResult
    
    func searchForecast(_ parameters: SearchParameters, completion: @escaping (SearchForecastResult) -> Void)
}
