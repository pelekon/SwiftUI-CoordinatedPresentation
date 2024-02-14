//
//  CSUCoordinatedViewHost.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 14/01/2024.
//

import SwiftUI

protocol CSUCoordinatedViewHost<ScreensProvider>: UIViewController, CSUCoordinatedView {
    associatedtype ScreensProvider: CSUScreensProvider
    
    var coordinator: CSUViewCoordinator<ScreensProvider> { get }
}
