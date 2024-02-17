//
//  CSUCoordinatedNavigationView.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 11/01/2024.
//

import SwiftUI

public struct CSUCoordinatedNavigationView<ScreenProvider>: View where ScreenProvider: CSUScreensProvider {
    private let rootScreenProvider: ScreenProvider
    
    public init(rootScreenProvider: ScreenProvider) {
        self.rootScreenProvider = rootScreenProvider
    }
    
    public var body: some View {
        CSUCoordinatedNavigationWrapper(rootScreenProvider: rootScreenProvider)
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
