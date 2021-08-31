//
//  LocalSearchForecastRepository.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation


public class LocalSearchForecastRepository {
    private let store: ForecastStore
    private let currentDate: () -> Date
    
    public init(store: ForecastStore, currentDate: @escaping () -> Date = { Date() }) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [LocalWeatherForecastItem], timestamp: Date, for key: String, completion: @escaping (Error?) -> Void) {
        store.save(items, timestamp: timestamp, for: key, completion: completion)
    }
}


extension LocalSearchForecastRepository: SearchForecastRepository {
    
    public func searchForecast(_ parameters: SearchParameters, completion: @escaping (SearchForecastResult) -> Void) {
        store.get(for: parameters.encode(), completion: { result in
            switch result {
            case .empty:
                completion(.success([]))
            case let .found(items, _):
                completion(.success(items.toItems()))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
}


fileprivate extension Array where Element == LocalWeatherForecastItem {
    func toItems() -> [WeatherForecastItem] {
        map({ WeatherForecastItem(date: $0.date, pressure: $0.pressure, humidity: $0.humidity, temperature: $0.temperature, description: $0.description) })
    }
}
