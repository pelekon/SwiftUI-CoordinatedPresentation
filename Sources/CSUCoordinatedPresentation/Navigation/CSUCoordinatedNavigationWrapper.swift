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
    private let onVisibleScreenChanged: CSUCoordinatedNavigationView<ScreenProvider>.OnScreenChangedHandler?
    
    init(rootScreenProvider: ScreenProvider, hideNavBarForRootView: Bool,
         initialConfigurationHandler: CSUCoordinatedNavigationView<ScreenProvider>.InitialConfigurationHandler? = nil,
         onVisibleScreenChanged: CSUCoordinatedNavigationView<ScreenProvider>.OnScreenChangedHandler? = nil) {
        self.rootScreenProvider = rootScreenProvider
        self.hideNavBarForRootView = hideNavBarForRootView
        self.initialConfigurationHandler = initialConfigurationHandler
        self.onVisibleScreenChanged = onVisibleScreenChanged
    }
    
    func makeUIViewController(context: Context) -> CSUCoordinatedNavigationController<ScreenProvider> {
        let navigation = CSUCoordinatedNavigationController<ScreenProvider>(
            rootScreenProvider: rootScreenProvider,
            hideNavBarForRootView: hideNavBarForRootView,
            initialConfigurationHandler: initialConfigurationHandler,
            onVisibleScreenChanged: onVisibleScreenChanged
        )
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: CSUCoordinatedNavigationController<ScreenProvider>, context: Context) {
        uiViewController.updateOnVisibleScreenChanged(to: onVisibleScreenChanged)
    }
}
