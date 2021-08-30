//
//  SearchForecastUseCaseTests.swift
//  SearchForecastTests
//
//  Created by Pham Quang Vinh on 8/30/21.
//

import XCTest
import SearchForecast


public class DefaultSearchForecastUseCase {
    private let searchRepository: SearchForecastRepository
    
    public init(searchRepository: SearchForecastRepository) {
        self.searchRepository = searchRepository
    }
}

class SearchForecastUseCaseTests: XCTestCase {
    
    func test_init_doesNotHaveAnyMessages() {
        let (_, repo) = makeSUT()
        
        XCTAssertTrue(repo.messages.isEmpty)
    }
    
    // MARK: - MARKS
    
    private func makeSUT() -> (sut: DefaultSearchForecastUseCase, repo: MockSearchForecastRepository) {
        let repo = MockSearchForecastRepository()
        let sut = DefaultSearchForecastUseCase(searchRepository: repo)
        return (sut, repo)
    }
}


class MockSearchForecastRepository: SearchForecastRepository {
    
    var messages = [(params: SearchParameters, completion: (SearchForecastResult) -> Void)]()
    
    func searchForecast(_ parameters: SearchParameters, completion: @escaping (SearchForecastResult) -> Void) {
        messages.append((params: parameters, completion: completion))
    }
}
