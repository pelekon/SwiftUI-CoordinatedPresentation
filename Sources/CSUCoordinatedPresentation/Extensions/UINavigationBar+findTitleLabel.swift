//
//  UINavigationBar+findTitleLabel.swift
//  CSUCoordinatedPresentation
//
//  Created by Bartłomiej Bukowiecki on 04/07/2024.
//

import SwiftUI

extension UINavigationBar {
    public func findTitleLabel(with title: String, maxSearchDeep: Int = 2) -> UILabel? {
        findTitleLabel(in: self, for: title, maxDeep: maxSearchDeep, current: 0)
    }
    
    private func findTitleLabel(in navBar: UIView, for title: String, maxDeep: Int, current: Int) -> UILabel? {
        guard current <= maxDeep else { return nil }
        
        for child in navBar.subviews {
            if let label = child as? UILabel, label.text == title {
                return label
            }
            
            if let childLabel = findTitleLabel(in: child, for: title, maxDeep: maxDeep, current: current + 1) {
                return childLabel
            }
        }
        return nil
    }
}
