//
//  SceneDelegate.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import UIKit
import RxSwift
import SearchForecast

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    private func configureWindow() {
        
    }
}



// MARK: - Adapt Rx
extension SearchForecastRepository {
    func searchForecastsObservable(_ parameters: SearchParameters) -> Observable<[WeatherForecastItem]> {
        Single.create { observer in
            self.searchForecast(parameters) { result in
                switch result {
                case .success(let items):
                    observer(.success(items))
                case .failure(let err):
                    observer(.failure(err))
                }
            }
            return Disposables.create { }
        }.asObservable()
    }
}


