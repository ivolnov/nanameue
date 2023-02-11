//
//  nanameueApp.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import SwiftUI

@main
struct nanameueApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().ignoresSafeArea()
        }
    }
}
