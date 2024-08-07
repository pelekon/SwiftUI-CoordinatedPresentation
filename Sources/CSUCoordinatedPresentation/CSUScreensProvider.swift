//
//  CSUScreensProvider.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 11/01/2024.
//

import SwiftUI

public protocol CSUScreensProvider {
    associatedtype ScreenView: View
    associatedtype ScreenType: Equatable
    associatedtype NavigationViewModifier: ViewModifier
    
    ///  Screen type used by ``CSUViewCoordinator`` to propery match views in navigation operations.
    var screenType: ScreenType { get }
    /// ViewModifier used on every created view. E.g: You can put required environment data and apply it. Default implementation returns ``EmptyModifier``.
    var viewsModifier: NavigationViewModifier { get }
    
    /// Provides view to host in navigation or modal presentation.
    /// - Returns: SwiftUI view.
    @ViewBuilder func makeScreen() -> ScreenView
}

public extension CSUScreensProvider {
    var viewsModifier: EmptyModifier { EmptyModifier() }
}
