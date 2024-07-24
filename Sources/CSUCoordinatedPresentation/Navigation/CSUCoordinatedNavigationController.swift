//
//  CSUCoordinatedNavigationController.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 14/01/2024.
//

import SwiftUI

final class CSUCoordinatedNavigationController<ScreensProvider>: UINavigationController, UINavigationControllerDelegate where ScreensProvider: CSUScreensProvider {
    private let presentationCoordinator: CSUPresentationCoordinator?
    private let hideNavBarForRootView: Bool
    var backButtonAttachmentProvider: (any BarItemProvider)?
    
    init(rootScreenProvider: ScreensProvider, hideNavBarForRootView: Bool, presentationMode: CSUPresentationMode? = nil,
         initialConfigurationHandler: CSUCoordinatedNavigationView<ScreensProvider>.InitialConfigurationHandler? = nil) {
        let rootVC = Self.makeCoordinatedView(for: rootScreenProvider, hideNavBarWhenViewIsVisible: hideNavBarForRootView,
                                              navigationController: nil)
        self.presentationCoordinator = presentationMode.flatMap { .init(mode: $0) }
        self.hideNavBarForRootView = hideNavBarForRootView
        super.init(rootViewController: rootVC)
        
        self.delegate = self
        rootVC.coordinator.assignNavigationController(with: self)
        
        if let initialConfigurationHandler {
            initialConfigurationHandler(rootVC.coordinator)
        }
        
        if presentationCoordinator != nil {
            self.modalPresentationStyle = .custom
            self.transitioningDelegate = presentationCoordinator
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Coordination
    
    func pushView(viewProvider: ScreensProvider, animated: Bool, onDismissed: (() -> Void)?) {
        let hostingVC = Self.makeCoordinatedView(for: viewProvider, navigationController: self)
        pushView(hostingVC: hostingVC, animated: animated, onDismissed: onDismissed)
    }
    
    func pushView<DecoratedView>(viewProvider: CSUScreenViewDecorator<ScreensProvider, DecoratedView>,
                                 animated: Bool, onDismissed: (() -> Void)?) where DecoratedView: View {
        let hostingVC = Self.makeCoordinatedView(for: viewProvider, navigationController: self)
        pushView(hostingVC: hostingVC, animated: animated, onDismissed: onDismissed)
    }
    
    private func pushView<Content>(hostingVC: CSUHostingController<Content, ScreensProvider>, animated: Bool,
                                   onDismissed: (() -> Void)?) where Content: View {
        hostingVC.coordinator.setOnDissmissedCallback(onDismissed)
        
        if let backButtonAttachmentProvider {
            self.topViewController?.navigationItem.backBarButtonItem = backButtonAttachmentProvider.make()
        }
        
        pushViewController(hostingVC, animated: animated)
    }
    
    func pop(to screenType: ScreensProvider.ScreenType, animated: Bool) {
        let target = viewControllers.last {
            guard let coordinated = $0 as? CSUCoordinatedView else { return false }
            
            let coordinator: CSUViewCoordinator<ScreensProvider>? = coordinated.viewCoordinator()
            
            return coordinator.flatMap { $0.screenType == screenType } ?? false
        }
        
        guard let target else { return }
        
        popToViewController(target, animated: animated)
    }
    
    func replaceRoot(with provider: ScreensProvider, animated: Bool) {
        let hostingVC = Self.makeCoordinatedView(for: provider, hideNavBarWhenViewIsVisible: hideNavBarForRootView,
                                                 navigationController: self)
        
        setViewControllers([hostingVC], animated: animated)
    }
    
    func replaceRoot<DecoratedView>(with provider: CSUScreenViewDecorator<ScreensProvider, DecoratedView>,
                                    animated: Bool) where DecoratedView: View {
        let hostingVC = Self.makeCoordinatedView(for: provider, hideNavBarWhenViewIsVisible: hideNavBarForRootView,
                                                 navigationController: self)
        
        setViewControllers([hostingVC], animated: animated)
    }
    
    static func makeCoordinatedView(
        for viewProvider: ScreensProvider,
        with mode: CSUPresentationMode? = nil,
        hideNavBarWhenViewIsVisible: Bool = false,
        navigationController: CSUCoordinatedNavigationController<ScreensProvider>?
    ) -> CSUHostingController<some View, ScreensProvider> {
        let coordinator = CSUViewCoordinator<ScreensProvider>(screenType: viewProvider.screenType,
                                                              navigationController: navigationController)

        let coordinatedView = viewProvider.makeScreen()
            .environmentObject(coordinator)
        
        return CSUHostingController(coordinator: coordinator, root: coordinatedView,
                                    hideNavBarWhenViewIsVisible: hideNavBarWhenViewIsVisible, presentationMode: mode)
    }
    
    static func makeCoordinatedView<DecoratedView: View>(
        for viewProvider: CSUScreenViewDecorator<ScreensProvider, DecoratedView>,
        with mode: CSUPresentationMode? = nil,
        hideNavBarWhenViewIsVisible: Bool = false,
        navigationController: CSUCoordinatedNavigationController<ScreensProvider>?
    ) -> CSUHostingController<some View, ScreensProvider> {
        let coordinator = CSUViewCoordinator<ScreensProvider>(screenType: viewProvider.screenType,
                                                              navigationController: navigationController)

        let coordinatedView = viewProvider.makeScreen()
            .environmentObject(coordinator)
        
        return CSUHostingController(coordinator: coordinator, root: coordinatedView,
                                    hideNavBarWhenViewIsVisible: hideNavBarWhenViewIsVisible, presentationMode: mode)
    }
}
