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
    
    init(rootScreenProvider: ScreenProvider, hideNavBarForRootView: Bool) {
        self.rootScreenProvider = rootScreenProvider
        self.hideNavBarForRootView = hideNavBarForRootView
    }
    
    func makeUIViewController(context: Context) -> CSUCoordinatedNavigationController<ScreenProvider> {
        let navigation = CSUCoordinatedNavigationController<ScreenProvider>(
            rootScreenProvider: rootScreenProvider,
            hideNavBarForRootView: hideNavBarForRootView
        )
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: CSUCoordinatedNavigationController<ScreenProvider>, context: Context) {
        // DO nothing?
    }
}
