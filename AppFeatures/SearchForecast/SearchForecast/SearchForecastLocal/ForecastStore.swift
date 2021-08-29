//
//  ForecastStore.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation


public enum GetCachedResult {
    case empty
    case found(items: [LocalWeatherForecastItem], timestamp: Date)
    case failure(Error)
}

public protocol ForecastStore {
    typealias SaveCompletion = (Error?) -> Void
    typealias GetCompletion = (GetCachedResult) -> Void
    
    func save(_ items: [LocalWeatherForecastItem], timestamp: Date, for key: String, completion: @escaping SaveCompletion)
    func get(for key: String, completion: @escaping GetCompletion)
}
