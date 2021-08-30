//
//  SearchForecastUseCase.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation


public enum SearchForecastUseCaseResult {
    case success(items: [WeatherForecastItem])
    case failure(_ error: Error)
}

public protocol SearchForecastUseCase {
    typealias Result = SearchForecastUseCaseResult
    typealias SearchParameters = (keyword: String, maximumForecastDay: Int, unit: UnitTemperature)
    
    func searchForecast(parameters: SearchParameters, completion: @escaping (SearchForecastUseCaseResult) -> Void)
}
