//
//  InMemoryForecastStore.swift
//  SearchForecast
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import Foundation


public class InMemoryForecastStore: ForecastStore {
    
    public class Cache {
        let timestamp: Date
        let items: [LocalWeatherForecastItem]
        
        init(_ items: [LocalWeatherForecastItem], timestamp: Date) {
            self.timestamp = timestamp
            self.items = items
        }
    }
    
    private let caches: NSCache<NSString, Cache>
    
    public init(caches: NSCache<NSString, Cache> = .init()) {
        self.caches = caches
    }
    
    public func save(_ items: [LocalWeatherForecastItem], timestamp: Date, for key: String, completion: @escaping SaveCompletion) {
        caches.setObject(Cache(items, timestamp: timestamp), forKey: key as NSString)
        completion(nil)
    }
    
    public func get(for key: String, completion: @escaping GetCompletion) {
        if let cache = caches.object(forKey: key as NSString) {
            completion(.found(items: cache.items, timestamp: cache.timestamp))
        } else {
            completion(.empty)
        }
    }
}
