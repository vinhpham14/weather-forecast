//
//  SearchForecastViewModel.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/31/21.
//

import Foundation
import SearchForecast
import RxSwift
import RxCocoa


class SearchForecastViewModel: ViewModelType {
    
    struct Input {
        let searchTextChanged: Driver<String?>
    }
    
    struct Output {
        let weatherForecastItems: Driver<[WeatherForecastViewModel]>
        let popupErrorMessage: Driver<String?>
        let loading: Driver<Bool>
    }
    
    private let temperatureUnit: UnitTemperature
    private let searchKeywordCountThreshold: Int
    private let searchForecastUseCase: SearchForecastUseCase
    
    init(searchKeywordCountThreshold: Int,
         temperatureUnit: UnitTemperature,
         searchForecastUseCase: SearchForecastUseCase) {
        self.searchKeywordCountThreshold = searchKeywordCountThreshold
        self.searchForecastUseCase = searchForecastUseCase
        self.temperatureUnit = temperatureUnit
    }
    
    func transfrom(_ input: Input) -> Output {
        
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()
        
        let items = input.searchTextChanged
            .map({ $0 ?? "" })
            .filter({ [searchKeywordCountThreshold] in $0.count >= searchKeywordCountThreshold })
            .flatMapLatest { [searchForecastUseCase] in
                return searchForecastUseCase
                    .searchForecastObservable(keyword: $0, maximumForecastDay: 7, unit: .celsius)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriver { _ in Driver.empty() }
            }
            .map { [temperatureUnit] in
                $0
                    .map { WeatherForecastPresentableMapper.map(item: $0, unit: temperatureUnit) }
                    .map({ WeatherForecastViewModel($0) })
            }
        
        let error = errorTracker.map({
            $0.localizedDescription.isEmpty
                ? $0.localizedDescription
                : "Unexpected error"
        })
        .map({ Optional.some($0) })
        .asDriver()
        
        let loading = activityIndicator.asDriver()
        
        return Output(weatherForecastItems: items, popupErrorMessage: error, loading: loading)
    }
}
