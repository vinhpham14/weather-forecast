//
//  AppDelegate.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import UIKit
import SearchForecast

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window:UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "SearchForecast", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        return true
    }

}


// MARK: - factory functions

fileprivate func makeSearchForecastViewController(
    searchKeywordCountThreshold: Int,
    searchForecastUseCase: SearchForecastUseCase
) -> SearchForecastViewController {
    
    let viewModel = SearchForecastViewModel(
        searchKeywordCountThreshold: searchKeywordCountThreshold,
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
