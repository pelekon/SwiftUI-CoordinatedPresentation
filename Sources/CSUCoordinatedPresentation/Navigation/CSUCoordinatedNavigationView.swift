//
//  CSUCoordinatedNavigationView.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 11/01/2024.
//

import SwiftUI

public struct CSUCoordinatedNavigationView<ScreenProvider>: View where ScreenProvider: CSUScreensProvider {
    public typealias InitialConfigurationHandler = (_ coordinator: CSUViewCoordinator<ScreenProvider>) -> Void
    public typealias OnScreenChangedHandler = (_ currentScreen: ScreenProvider.ScreenType) -> Void
    
    private let rootScreenProvider: ScreenProvider
    private let hideNavBarForRootView: Bool
    private let additionalSafeArea: UIEdgeInsets?
    private let initialConfigurationHandler: InitialConfigurationHandler?
    private let onVisibleScreenChanged: OnScreenChangedHandler?
    
    public init(rootScreenProvider: ScreenProvider, hideNavBarForRootView: Bool = true,
                additionalSafeArea: UIEdgeInsets? = nil,
                initialConfigurationHandler: InitialConfigurationHandler? = nil,
                onVisibleScreenChanged: OnScreenChangedHandler? = nil) {
        self.rootScreenProvider = rootScreenProvider
        self.hideNavBarForRootView = hideNavBarForRootView
        self.additionalSafeArea = additionalSafeArea
        self.initialConfigurationHandler = initialConfigurationHandler
        self.onVisibleScreenChanged = onVisibleScreenChanged
    }
    
    public var body: some View {
        CSUCoordinatedNavigationWrapper(rootScreenProvider: rootScreenProvider, 
                                        hideNavBarForRootView: hideNavBarForRootView,
                                        additionalSafeArea: additionalSafeArea,
                                        initialConfigurationHandler: initialConfigurationHandler,
                                        onVisibleScreenChanged: onVisibleScreenChanged)
            .ignoresSafeArea()
    }
}
