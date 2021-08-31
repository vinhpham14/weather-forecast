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


struct WeatherForecastViewModel: Equatable {
    private let presentableItem: WeatherForecastPresentable
    
    init(_ item: WeatherForecastPresentable) {
        self.presentableItem = item
    }
    
    static func == (lhs: WeatherForecastViewModel, rhs: WeatherForecastViewModel) -> Bool {
        lhs.presentableItem.date == rhs.presentableItem.date
        && lhs.presentableItem.pressure == rhs.presentableItem.pressure
        && lhs.presentableItem.humidity == rhs.presentableItem.humidity
        && lhs.presentableItem.temperature == rhs.presentableItem.temperature
        && lhs.presentableItem.description == rhs.presentableItem.description
    }
}

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transfrom(_ input: Input) -> Output
}

class SearchForecastViewModel: ViewModelType {
    
    struct Input {
        let searchTextChanged: Driver<String?>
    }
    
    struct Output {
        let weatherForecastItems: Driver<[WeatherForecastViewModel]>
        let popupErrorMessage: Driver<String?>
    }
    
    private let searchKeywordCountThreshold: Int
    private let searchForecastUseCase: SearchForecastUseCase
    
    init(searchKeywordCountThreshold: Int, searchForecastUseCase: SearchForecastUseCase) {
        self.searchKeywordCountThreshold = searchKeywordCountThreshold
        self.searchForecastUseCase = searchForecastUseCase
    }
    
    func transfrom(_ input: Input) -> Output {
        
        let errorTracker = ErrorTracker()
        
        let items = input.searchTextChanged
            .map({ $0 ?? "" })
            .filter({ [searchKeywordCountThreshold] in $0.count >= searchKeywordCountThreshold })
            .flatMapLatest { [searchForecastUseCase] in
                return searchForecastUseCase
                    .searchForecastObservable(keyword: $0, maximumForecastDay: 7, unit: .celsius)
                    .trackError(errorTracker)
                    .asDriver { _ in Driver.empty() }
            }
            .map {
                $0
                    .map { WeatherForecastPresentableMapper.map(item: $0) }
                    .map({ WeatherForecastViewModel($0) })
            }
        
        let error = errorTracker.map({
            $0.localizedDescription.isEmpty
                ? $0.localizedDescription
                : "Unexpected error"
        })
        .map({ Optional.some($0) })
        .asDriver()
        
        return Output(weatherForecastItems: items, popupErrorMessage: error)
    }
}
