//
//  CSUScreenViewDecorator.swift
//  CSUCoordinatedPresentation
//
//  Created by Bartłomiej Bukowiecki on 19/07/2024.
//

import SwiftUI

public struct CSUScreenViewDecorator<ScreenProvider, DecoratedView>: CSUScreensProvider where ScreenProvider: CSUScreensProvider, DecoratedView: View {
    private let root: ScreenProvider
    private let decorator: (ScreenProvider.ScreenView) -> DecoratedView
    
    public init(_ screen: ScreenProvider, decorator: @escaping (ScreenProvider.ScreenView) -> DecoratedView) {
        self.root = screen
        self.decorator = decorator
    }
    
    public var screenType: ScreenProvider.ScreenType { root.screenType }
    public var viewsModifier: ScreenProvider.NavigationViewModifier { root.viewsModifier }
    
    public func makeScreen() -> some View {
        decorator(root.makeScreen())
    }
}
