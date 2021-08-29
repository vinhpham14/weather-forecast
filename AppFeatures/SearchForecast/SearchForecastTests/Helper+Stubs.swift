//
//  SearchForecastRepository+Stub.swift
//  SearchForecastTests
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation
import SearchForecast


func makeSearchParameters(cityName: String? = nil, maximumForecastDay: Int? = nil, unit: UnitTemperature? = nil) -> SearchForecastParameters {
    return SearchForecastParameters(cityName ?? anyCityName, maximumForecastDay ?? anyMaximumForecastDay, unit ?? anyUnit)
}

var anyUnit: UnitTemperature { .celsius }
var anyCityName: String { "city" }
var anyURL: URL { URL(string: "https://any-url.com")! }
var anyMaximumForecastDay: Int { 7 }
var anyError: Error { NSError(domain: "error", code: 0, userInfo: nil) }
