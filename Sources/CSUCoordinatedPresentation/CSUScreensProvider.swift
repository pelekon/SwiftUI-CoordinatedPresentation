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
    
    var screenType: ScreenType { get }
    
    @ViewBuilder func makeScreen() -> ScreenView
}
