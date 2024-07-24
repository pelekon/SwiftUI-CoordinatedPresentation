//
//  CSUPresentationMode.swift
//  CSUCoordinatedPresentation
//
//  Created by Bartłomiej Bukowiecki on 27/06/2024.
//

import UIKit

public enum CSUPresentationMode {
    case sheet
    case configuredSheet(CSUSheetConfiguration)
    case fullscreenCover
    case custom(UIPresentationController)
}
