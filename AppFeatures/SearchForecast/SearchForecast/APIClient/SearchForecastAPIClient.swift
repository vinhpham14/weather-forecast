//
//  APIClient.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import Foundation


//public protocol Cancellable {
//    func cancel()
//}

public protocol SearchForecastAPIClient {
    typealias APIResult = Swift.Result<(Data, HTTPURLResponse), Error>
    typealias APICompletion = (APIResult) -> Void
    typealias Cancellable = () -> Void
    
    @discardableResult
    func get(from url: URL, completion: @escaping APICompletion) -> Cancellable
}
