//
//  UINavigationBar+findTitleLabel.swift
//  CSUCoordinatedPresentation
//
//  Created by Bartłomiej Bukowiecki on 04/07/2024.
//

import SwiftUI

extension UINavigationBar {
    public func findTitleLabel(with title: String, maxSearchDepth: Int = 2) -> UILabel? {
        findTitleLabel(in: self, for: title, maxDepth: maxSearchDepth, current: 0)
    }
    
    private func findTitleLabel(in navBar: UIView, for title: String, maxDepth: Int, current: Int) -> UILabel? {
        guard current <= maxDepth else { return nil }
        
        for child in navBar.subviews {
            if let label = child as? UILabel, !label.isHidden && label.text == title {
                return label
            }
            
            if let childLabel = findTitleLabel(in: child, for: title, maxDepth: maxDepth, current: current + 1) {
                return childLabel
            }
        }
        return nil
    }
}
