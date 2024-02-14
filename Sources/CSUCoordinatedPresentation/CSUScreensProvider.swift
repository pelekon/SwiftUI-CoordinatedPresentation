//
//  CSUScreensProvider.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 11/01/2024.
//

import SwiftUI

public protocol CSUScreensProvider: Equatable {
    associatedtype ScreenView: View
    
    @ViewBuilder func makeScreen() -> ScreenView
}
