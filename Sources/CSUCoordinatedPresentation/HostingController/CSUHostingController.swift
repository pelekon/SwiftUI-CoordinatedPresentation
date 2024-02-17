//
//  CSUHostingController.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 14/01/2024.
//

import SwiftUI

final class CSUHostingController<Content, ScreensProvider>: UIHostingController<Content>, CSUCoordinatedViewHost, UIViewControllerTransitioningDelegate
        where Content: View, ScreensProvider: CSUScreensProvider {
    typealias Coordinator = CSUViewCoordinator<ScreensProvider>
    typealias PresentationMode = CSUViewCoordinator<ScreensProvider>.PresentationMode
    
    let coordinator: Coordinator
    let presentationMode: PresentationMode?
    
    init(coordinator: Coordinator, root: Content, presentationMode: PresentationMode? = nil) {
        self.coordinator = coordinator
        self.presentationMode = presentationMode
        super.init(rootView: root)
        
        coordinator.assignOwningController(with: self)
        if presentationMode != nil {
            self.modalPresentationStyle = .custom
            self.transitioningDelegate = self
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewCoordinator<T>() -> CSUViewCoordinator<T>? where T : CSUScreensProvider {
        return coordinator as? CSUViewCoordinator<T>
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        guard let presentationMode else { return nil }
        
        return switch presentationMode {
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
