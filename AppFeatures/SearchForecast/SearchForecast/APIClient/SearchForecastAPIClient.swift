//
//  APIClient.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import Foundation


public protocol SearchForecastAPIClient {
    typealias APIResult = Swift.Result<(Data, HTTPURLResponse), Error>
    typealias APICompletion = (APIResult) -> Void
    
    func get(from url: URL, completion: @escaping APICompletion)
}
