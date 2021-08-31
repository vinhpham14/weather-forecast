//
//  SearchForecastRepository.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 9/1/21.
//

import SearchForecast


class CacheWithFallbackRemoteSearchForecastRepository: SearchForecastRepository {
    private let cacheRepository: SearchForecastRepository
    private let remoteRepository: SearchForecastRepository
    private let cacheStore: ForecastStore
    
    init(cacheStore: ForecastStore, remoteRepository: SearchForecastRepository) {
        self.cacheStore = cacheStore
        self.cacheRepository = LocalSearchForecastRepository(store: cacheStore)
        self.remoteRepository = remoteRepository
    }
    
    func searchForecast(_ parameters: SearchParameters, completion: @escaping (SearchForecastResult) -> Void) {
        self.cacheRepository.searchForecast(parameters, completion: { [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .failure:
                weakSelf.remoteRepository.searchForecast(parameters, completion: { [weak self] remoteResult in
                    guard self != nil else { return }
                    if case let .success(items) = remoteResult {
                        self?.cacheStore.save(
                            items.map({ $0.toLocal() }),
                            timestamp: Date(),
                            for: parameters.encode(),
                            completion: { _ in }
                        )
                    }
                    completion(remoteResult)
                })
                
            case .success:
                completion(result)
            }
        })
    }
}


private extension WeatherForecastItem {
    func toLocal() -> LocalWeatherForecastItem {
        return LocalWeatherForecastItem(
            id: id,
            date: date,
            pressure: pressure,
            humidity: humidity,
            temperature: temperature,
            description: description
        )
    }
}
