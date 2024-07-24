//
//  File.swift
//  
//
//  Created by Bartłomiej Bukowiecki on 17/02/2024.
//

import SwiftUI

struct CSUCoordinatedNavigationWrapper<ScreenProvider>: UIViewControllerRepresentable where ScreenProvider: CSUScreensProvider {
    private let rootScreenProvider: ScreenProvider
    private let hideNavBarForRootView: Bool
    private let initialConfigurationHandler: CSUCoordinatedNavigationView<ScreenProvider>.InitialConfigurationHandler?
    
    init(rootScreenProvider: ScreenProvider, hideNavBarForRootView: Bool,
         initialConfigurationHandler: CSUCoordinatedNavigationView<ScreenProvider>.InitialConfigurationHandler? = nil) {
        self.rootScreenProvider = rootScreenProvider
        self.hideNavBarForRootView = hideNavBarForRootView
        self.initialConfigurationHandler = initialConfigurationHandler
    }
    
    func makeUIViewController(context: Context) -> CSUCoordinatedNavigationController<ScreenProvider> {
        let navigation = CSUCoordinatedNavigationController<ScreenProvider>(
            rootScreenProvider: rootScreenProvider,
            hideNavBarForRootView: hideNavBarForRootView,
            initialConfigurationHandler: initialConfigurationHandler
        )
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: CSUCoordinatedNavigationController<ScreenProvider>, context: Context) {
        // DO nothing?
    }
}
