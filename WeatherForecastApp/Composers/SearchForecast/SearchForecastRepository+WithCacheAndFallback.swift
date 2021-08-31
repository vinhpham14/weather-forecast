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
            guard let strongSelf = self else { return }
            
            switch result {
            case .failure:
                strongSelf.searchRemote(parameters, completion: completion)
            case .success(let items):
                if items.isEmpty {
                    strongSelf.searchRemote(parameters, completion: completion)
                } else {
                    completion(result)
                }
            }
        })
    }
    
    private func searchRemote(_ parameters: SearchParameters, completion: @escaping (SearchForecastResult) -> Void) {
        remoteRepository.searchForecast(parameters, completion: { [weak self] remoteResult in
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
    }
}


private extension WeatherForecastItem {
    func toLocal() -> LocalWeatherForecastItem {
        return LocalWeatherForecastItem(
            date: date,
            pressure: pressure,
            humidity: humidity,
            temperature: temperature,
            description: description
        )
    }
}
