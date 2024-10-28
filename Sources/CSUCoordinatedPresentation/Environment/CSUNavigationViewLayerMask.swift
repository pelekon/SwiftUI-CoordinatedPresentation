//
//  CSUNavigationViewLayerMask.swift
//  CSUCoordinatedPresentation
//
//  Created by Bartłomiej Bukowiecki on 28/10/2024.
//

import SwiftUI

public enum CSUNavigationViewLayerMask: Equatable {
    case roundedRect(radius: CGFloat)
    case roundedCorners(radius: CGFloat, corners: UIRectCorner)
    
    func toShapeLayer(for view: UIView) -> CAShapeLayer {
        switch self {
        case .roundedRect(let radius):
            let shape = CAShapeLayer()
            shape.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: radius).cgPath
            return shape
        case .roundedCorners(let radius, let corners):
            let shape = CAShapeLayer()
            shape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
            return shape
        }
    }
}

extension EnvironmentValues {
    @Entry var csuNavigationLayerMask: CSUNavigationViewLayerMask?
}

extension View {
    public func csuNavigationLayerMask(_ shape: CSUNavigationViewLayerMask) -> some View {
        environment(\.csuNavigationLayerMask, shape)
    }
}
