//
//  AppDelegate.swift
//  nanameue
//
//  Created by Volnov Ivan on 09/02/2023.
//

import FirebaseCore
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
