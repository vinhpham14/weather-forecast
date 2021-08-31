//
//  Observable+Fallback.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 9/1/21.
//

import RxSwift

extension Observable {
    
    func fallback(to fallbackPublisher: @escaping () -> Observable) -> Observable {
        self.catch({ _ in fallbackPublisher() })
    }
}
