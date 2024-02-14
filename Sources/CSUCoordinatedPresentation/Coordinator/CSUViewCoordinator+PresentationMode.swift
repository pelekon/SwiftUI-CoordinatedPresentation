//
//  CSUViewCoordinator+PresentationMode.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 14/01/2024.
//

import SwiftUI

extension CSUViewCoordinator {
    public enum PresentationMode {
        case sheet
        case configuredSheet(CSUSheetConfiguration)
        case fullscreenCover
        case custom(UIPresentationController)
//        case alert
//        case popover
    }
}
