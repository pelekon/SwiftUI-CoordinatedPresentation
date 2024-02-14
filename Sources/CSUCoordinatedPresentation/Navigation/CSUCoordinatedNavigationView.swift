//
//  CSUCoordinatedNavigationView.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 11/01/2024.
//

import SwiftUI

public struct CSUCoordinatedNavigationView<ScreenProvider>: UIViewControllerRepresentable where ScreenProvider: CSUScreensProvider {
    private let rootScreenProvider: ScreenProvider
    private let dismissPresentedViewOnViewPop: Bool
    
    public init(rootScreenProvider: ScreenProvider, dismissPresentedViewOnViewPop: Bool = true) {
        self.rootScreenProvider = rootScreenProvider
        self.dismissPresentedViewOnViewPop = dismissPresentedViewOnViewPop
    }
    
    public func makeUIViewController(context: Context) -> CSUCoordinatedNavigationController<ScreenProvider> {
        let navigation = CSUCoordinatedNavigationController<ScreenProvider>(
            rootScreenProvider: rootScreenProvider,
            dismissPresentedViewOnViewPop: dismissPresentedViewOnViewPop
        )
        
        return navigation
    }
    
    public func updateUIViewController(_ uiViewController: CSUCoordinatedNavigationController<ScreenProvider>, context: Context) {
        // DO nothing?
    }
}

//#Preview {
//    enum TestScreen: CSUScreensProvider {
//        
//    }
//    
//    return CSUCoordinatedNavigationView<TestScreen>()
//}
