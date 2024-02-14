//
//  CSUCoordinatedView.swift
//
//
//  Created by Bartłomiej Bukowiecki on 10/02/2024.
//

import SwiftUI

protocol CSUCoordinatedView {
    func viewCoordinator<T>() -> CSUViewCoordinator<T>? where T: CSUScreensProvider
}
