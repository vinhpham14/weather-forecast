//
//  AppDelegate.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import UIKit
import SearchForecast

private let baseURL = "https://api.openweathermap.org"
private let appID = "17f883ef3221481d77e9389a5ce28b7b"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window:UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = makeRootViewController()
        window?.makeKeyAndVisible()
        return true
    }
    
    func makeRootViewController() -> UIViewController {
        let useCase = makeLocalAndFallbackWithRemoteSearchForecastUseCase(
            apiClient: URLSessionSearchForecastAPIClient(session: URLSession.shared),
            entryPoint: ForecastEndpoint(baseURL: URL(string: baseURL)!, appID: appID),
            store: InMemoryForecastStore()
        )
        return makeSearchForecastViewController(
            searchKeywordCountThreshold: 3,
            searchForecastUseCase: useCase
        )
    }

}


// MARK: - factory functions

fileprivate func makeSearchForecastViewController(
    searchKeywordCountThreshold: Int,
    searchForecastUseCase: SearchForecastUseCase
) -> SearchForecastViewController {
    
    let viewModel = SearchForecastViewModel(
        searchKeywordCountThreshold: searchKeywordCountThreshold,
        temperatureUnit: .celsius,
        searchForecastUseCase: searchForecastUseCase
    )
    
    let vc = UIStoryboard(name: "SearchForecast", bundle: nil)
        .instantiateInitialViewController() as! SearchForecastViewController
    
    vc.viewModel = viewModel
    
    return vc
}

fileprivate func makeLocalAndFallbackWithRemoteSearchForecastUseCase(
    apiClient: SearchForecastAPIClient,
    entryPoint: ForecastEndpoint,
    store: ForecastStore
) -> SearchForecastUseCase {
    
    let repo = CacheWithFallbackRemoteSearchForecastRepository(
        cacheStore: store,
        remoteRepository: RemoteSearchForecastRepository(
            endpoint: entryPoint,
            apiClient: apiClient
        )
    )
    
    return DefaultSearchForecastUseCase(searchRepository: repo)
}
