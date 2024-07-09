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
    
    let coordinator: Coordinator
    let presentationMode: CSUPresentationMode?
    private let hideNavBarWhenViewIsVisible: Bool
    private let presentationCoordinator: CSUPresentationCoordinator?
    
    init(coordinator: Coordinator, root: Content, hideNavBarWhenViewIsVisible: Bool,
         presentationMode: CSUPresentationMode? = nil) {
        self.coordinator = coordinator
        self.hideNavBarWhenViewIsVisible = hideNavBarWhenViewIsVisible
        self.presentationMode = presentationMode
        self.presentationCoordinator = presentationMode.flatMap { .init(mode: $0) }
        super.init(rootView: root)
        
        coordinator.assignOwningController(with: self)
        if presentationCoordinator != nil {
            self.modalPresentationStyle = .custom
            self.transitioningDelegate = presentationCoordinator
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if hideNavBarWhenViewIsVisible {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        coordinator.updateIsVisible(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coordinator.updateIsVisible(false)
        
        if hideNavBarWhenViewIsVisible {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    func viewCoordinator<T>() -> CSUViewCoordinator<T>? where T : CSUScreensProvider {
        return coordinator as? CSUViewCoordinator<T>
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if let callback = coordinator.onDissmissedCallback, parent == nil && coordinator.isInNavigationContext {
            callback()
        }
    }
}
