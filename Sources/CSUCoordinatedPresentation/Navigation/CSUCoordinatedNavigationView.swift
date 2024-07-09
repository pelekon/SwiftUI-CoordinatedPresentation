//
//  CSUCoordinatedNavigationView.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 11/01/2024.
//

import SwiftUI

public struct CSUCoordinatedNavigationView<ScreenProvider>: View where ScreenProvider: CSUScreensProvider {
    private let rootScreenProvider: ScreenProvider
    private let hideNavBarForRootView: Bool
    
    public init(rootScreenProvider: ScreenProvider, hideNavBarForRootView: Bool = true) {
        self.rootScreenProvider = rootScreenProvider
        self.hideNavBarForRootView = hideNavBarForRootView
    }
    
    public var body: some View {
        CSUCoordinatedNavigationWrapper(rootScreenProvider: rootScreenProvider, hideNavBarForRootView: hideNavBarForRootView)
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
