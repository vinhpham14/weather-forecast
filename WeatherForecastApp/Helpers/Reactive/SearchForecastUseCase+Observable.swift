//
//  SearchForecastUseCase+Observable.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/31/21.
//

import Foundation
import SearchForecast
import RxSwift


extension SearchForecastUseCase {

    public func searchForecastObservable(keyword: String, maximumForecastDay: Int, unit: UnitTemperature) -> Single<[WeatherForecastItem]> {
        return Single<[WeatherForecastItem]>.create { observer in
            self.searchForecast(parameters: (keyword, maximumForecastDay, unit)) { result in
                switch result {
                case let .success(items):
                    observer(.success(items))
                case let .failure(err):
                    observer(.failure(err))
                }
            }
            return Disposables.create { }
        }
    }
}
