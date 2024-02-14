//
//  CSUSheetConfiguration.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 14/01/2024.
//

import SwiftUI

public struct CSUSheetConfiguration {
    public var canInteractiveDismiss = true
    public var isDragIndicatorDisabled = true
    public var preferedCornerRadius: CGFloat?
    public var canInteractWithBackground = false
    public var presentationBackground: Color? = nil
    public var prefersScrollingExpandsWhenScrolledToEdge = true
    private var _detents: [Any]?
    
    public init(canInteractiveDismiss: Bool = true, 
                isDragIndicatorDisabled: Bool = true,
                preferedCornerRadius: CGFloat? = nil, 
                canInteractWithBackground: Bool = false,
                presentationBackground: Color? = nil, 
                prefersScrollingExpandsWhenScrolledToEdge: Bool = true) {
        self.canInteractiveDismiss = canInteractiveDismiss
        self.isDragIndicatorDisabled = isDragIndicatorDisabled
        self.preferedCornerRadius = preferedCornerRadius
        self.canInteractWithBackground = canInteractWithBackground
        self.presentationBackground = presentationBackground
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        self._detents = nil
    }
    
    @available(iOS 15, *)
    public var detends: [UISheetPresentationController.Detent]? {
        get {
            return _detents as? [UISheetPresentationController.Detent]
        }
        set {
            _detents = newValue
        }
    }
}
