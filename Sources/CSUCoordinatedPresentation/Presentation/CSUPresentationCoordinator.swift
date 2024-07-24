//
//  CSUPresentationCoordinator.swift
//  CSUCoordinatedPresentation
//
//  Created by Bartłomiej Bukowiecki on 27/06/2024.
//

import UIKit

final class CSUPresentationCoordinator: NSObject, UIViewControllerTransitioningDelegate {
    let mode: CSUPresentationMode
    
    init(mode: CSUPresentationMode) {
        self.mode = mode
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return switch mode {
        case .sheet:
            makeSheetPresentationController(configuration: nil, presentedViewController: presented, presenting: source)
        case let .configuredSheet(configuration):
            makeSheetPresentationController(configuration: configuration, presentedViewController: presented, presenting: source)
        case .fullscreenCover:
            CSUFullScreenCoverPresentationController(presentedViewController: presented, presenting: source)
        case let .custom(controller):
            controller
        }
    }
    
    private func makeSheetPresentationController(configuration: CSUSheetConfiguration?,
                                                 presentedViewController: UIViewController,
                                                 presenting: UIViewController?) -> UIPresentationController {
        if #available(iOS 15, *) {
            return CSUSheetPresentationController(configuration: configuration,
                                                  presentedViewController: presentedViewController,
                                                  presenting: presenting)
        } else {
            return CSUPageSheetPresentationController(configuration: configuration,
                                                      presentedViewController: presentedViewController,
                                                      presenting: presenting)
        }
    }
}
