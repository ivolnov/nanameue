//
//  ContentView.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import SwiftUI

struct ContentView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: FeedViewController())
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
