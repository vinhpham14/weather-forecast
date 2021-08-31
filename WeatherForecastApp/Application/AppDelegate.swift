//
//  AppDelegate.swift
//  WeatherForecastApp
//
//  Created by Pham Quang Vinh on 8/29/21.
//

import UIKit

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
