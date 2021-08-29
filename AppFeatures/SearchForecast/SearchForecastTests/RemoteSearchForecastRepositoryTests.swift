//
//  RemoteSearchForecastRepositoryTests.swift
//  SearchForecastTests
//
//  Created by Pham Quang Vinh on 8/29/21.
//


import XCTest
import SearchForecast


public enum SearchForecastResult {
    case success(_ items: [WeatherForecastItem])
    case failure(_ error: Error)
}

class RemoteSearchForecastRepository {
    private let url: URL
    private let apiClient: APIClient
    
    init(url: URL, apiClient: APIClient) {
        self.url = url
        self.apiClient = apiClient
    }
    
    func searchForecast(cityName: String, completion: @escaping (SearchForecastResult) -> Void) {
        apiClient.get(from: url)
    }
}

public protocol APIClient {
    func get(from url: URL)
}

class APIClientSpy: APIClient {
    var requestedURLs: [URL] = []
    
    func get(from url: URL) {
        requestedURLs.append(url)
    }
}

class RemoteSearchForecastRepositoryTests: XCTestCase {
    
    func test_init_noRequestHappens() {
        let (_, api) = makeSUT()
        
        XCTAssertTrue(api.requestedURLs.isEmpty)
    }
    
    func test_doSearchTwice_requestHappendsTwice() {
        let url = randomURL
        let (sut, api) = makeSUT(url: url)
        
        sut.searchForecast(cityName: randomCityName, completion: { _ in })
        sut.searchForecast(cityName: randomCityName, completion: { _ in })
        
        XCTAssertEqual(api.requestedURLs, [url, url])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteSearchForecastRepository, api: APIClientSpy) {
        let api = APIClientSpy()
        let sut = RemoteSearchForecastRepository(url: url, apiClient: api)
        return (sut, api)
    }
    
    private var randomCityName: String { "city \(randomNumber)" }
    private var randomURL: URL { URL(string: "https://any-url.com/(\(randomNumber)")! }
    private var randomNumber: Int { Int.random(in: 1...100) }
}
