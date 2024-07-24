//
//  CSUPresentationCoordinator+PresentationControllers.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 14/01/2024.
//

import SwiftUI

extension CSUPresentationCoordinator {
    final class CSUPageSheetPresentationController: UIPresentationController, UIAdaptivePresentationControllerDelegate {
        let configuration: CSUSheetConfiguration?
        
        override var presentationStyle: UIModalPresentationStyle { .formSheet }
        override var adaptivePresentationStyle: UIModalPresentationStyle { .formSheet }
        
        init(configuration: CSUSheetConfiguration?, presentedViewController: UIViewController, presenting: UIViewController?) {
            self.configuration = configuration
            super.init(presentedViewController: presentedViewController, presenting: presenting)
            
            self.delegate = self
            presentedViewController.isModalInPresentation = !(configuration.flatMap { $0.canInteractiveDismiss } ?? true)
            if let backgroundColor = configuration?.presentationBackground {
                presentedViewController.view.backgroundColor = UIColor(backgroundColor)
            }
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .formSheet
        }

        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return .formSheet
        }
    }
    
    @available(iOS 15, *)
    final class CSUSheetPresentationController: UISheetPresentationController {
        let configuration: CSUSheetConfiguration?
        
        init(configuration: CSUSheetConfiguration?, presentedViewController: UIViewController, presenting: UIViewController?) {
            self.configuration = configuration
            super.init(presentedViewController: presentedViewController, presenting: presenting)
            
            if let detends = configuration?.detends {
                self.detents = detends
            }
            
            self.prefersGrabberVisible = configuration.flatMap { !$0.isDragIndicatorDisabled } ?? false
            self.preferredCornerRadius = configuration?.preferedCornerRadius
            presentedViewController.isModalInPresentation = !(configuration.flatMap { $0.canInteractiveDismiss } ?? true)
            if let backgroundColor = configuration?.presentationBackground {
                presentedViewController.view.backgroundColor = UIColor(backgroundColor)
            }
            if let flag = configuration?.prefersScrollingExpandsWhenScrolledToEdge {
                prefersScrollingExpandsWhenScrolledToEdge = flag
            }
            if let flag = configuration?.canInteractWithBackground, flag {
                largestUndimmedDetentIdentifier = .medium
            }
        }
    }
    
    final class CSUFullScreenCoverPresentationController: UIPresentationController {
        override var presentationStyle: UIModalPresentationStyle { .fullScreen }
        override var adaptivePresentationStyle: UIModalPresentationStyle { .fullScreen }
    }
}
