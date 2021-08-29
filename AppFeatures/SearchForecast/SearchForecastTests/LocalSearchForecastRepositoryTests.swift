//
//  LocalSearchForecastRepositoryTests.swift
//  SearchForecastTests
//
//  Created by Pham Quang Vinh on 8/29/21.
//


import XCTest


public protocol ForecastStore {
    
}

class ForecastStoreSpy: ForecastStore {
    enum Message {
        case insert
    }
    
    private(set) var receivedMessages: [Message] = []
}

public class LocalSearchForecastRepository {
    private let store: ForecastStore
    
    public init(store: ForecastStore) {
        self.store = store
    }
}


final class LocalSearchForecastRepositoryTests: XCTestCase {
    
    func test_init_haveNoMessages() {
        let (_, store) = makeSUT()
        
        XCTAssert(store.receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalSearchForecastRepository, store: ForecastStoreSpy) {
        let store = ForecastStoreSpy()
        let sut = LocalSearchForecastRepository(store: store)
        return (sut, store)
    }
}
