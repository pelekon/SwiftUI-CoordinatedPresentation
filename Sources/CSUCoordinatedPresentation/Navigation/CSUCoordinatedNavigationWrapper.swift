//
//  File.swift
//  
//
//  Created by Bartłomiej Bukowiecki on 17/02/2024.
//

import SwiftUI

struct CSUCoordinatedNavigationWrapper<ScreenProvider>: UIViewControllerRepresentable where ScreenProvider: CSUScreensProvider {
    private let rootScreenProvider: ScreenProvider
    
    init(rootScreenProvider: ScreenProvider) {
        self.rootScreenProvider = rootScreenProvider
    }
    
    func makeUIViewController(context: Context) -> CSUCoordinatedNavigationController<ScreenProvider> {
        let navigation = CSUCoordinatedNavigationController<ScreenProvider>(
            rootScreenProvider: rootScreenProvider
        )
        
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: CSUCoordinatedNavigationController<ScreenProvider>, context: Context) {
        // DO nothing?
    }
}
