//
//  CSUCoordinatedNavigationView.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 11/01/2024.
//

import SwiftUI

public struct CSUCoordinatedNavigationView<ScreenProvider>: View where ScreenProvider: CSUScreensProvider {
    public typealias InitialConfigurationHandler = (_ coordinator: CSUViewCoordinator<ScreenProvider>) -> Void
    
    private let rootScreenProvider: ScreenProvider
    private let hideNavBarForRootView: Bool
    private let initialConfigurationHandler: InitialConfigurationHandler?
    
    public init(rootScreenProvider: ScreenProvider, hideNavBarForRootView: Bool = true,
                initialConfigurationHandler: InitialConfigurationHandler? = nil) {
        self.rootScreenProvider = rootScreenProvider
        self.hideNavBarForRootView = hideNavBarForRootView
        self.initialConfigurationHandler = initialConfigurationHandler
    }
    
    public var body: some View {
        CSUCoordinatedNavigationWrapper(rootScreenProvider: rootScreenProvider, 
                                        hideNavBarForRootView: hideNavBarForRootView,
                                        initialConfigurationHandler: initialConfigurationHandler)
            .ignoresSafeArea()
    }
}

//#Preview {
//    enum TestScreen: CSUScreensProvider {
//        
//    }
//    
//    return CSUCoordinatedNavigationView<TestScreen>()
//}
