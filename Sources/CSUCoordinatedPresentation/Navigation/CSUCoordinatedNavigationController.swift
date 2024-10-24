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
    private var onVisibleScreenChanged: CSUCoordinatedNavigationView<ScreensProvider>.OnScreenChangedHandler?
    
    init(rootScreenProvider: ScreensProvider, hideNavBarForRootView: Bool, presentationMode: CSUPresentationMode? = nil,
         initialConfigurationHandler: CSUCoordinatedNavigationView<ScreensProvider>.InitialConfigurationHandler? = nil,
         onVisibleScreenChanged: CSUCoordinatedNavigationView<ScreensProvider>.OnScreenChangedHandler? = nil) {
        let rootVC = Self.makeCoordinatedView(for: rootScreenProvider, hideNavBarWhenViewIsVisible: hideNavBarForRootView,
                                              navigationController: nil)
        self.presentationCoordinator = presentationMode.flatMap { .init(mode: $0) }
        self.hideNavBarForRootView = hideNavBarForRootView
        self.onVisibleScreenChanged = onVisibleScreenChanged
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
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        // [Bug] IOS 15.8 sets this flag as false somehwere between VC's lifecycle events: viewWillAppear and viewDidAppear.
        // Additionally UITabBarController does same thing on tab change.
        if hideNavBarForRootView && !hidden && viewControllers.count == 1 { return }
        
        super.setNavigationBarHidden(hidden, animated: animated)
    }
    
    func updateOnVisibleScreenChanged(to handler: CSUCoordinatedNavigationView<ScreensProvider>.OnScreenChangedHandler?) {
        self.onVisibleScreenChanged = handler
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let presentedHost = viewController as? CSUCoordinatedView else { return }
        
        guard let childCoordinator: CSUViewCoordinator<ScreensProvider> = presentedHost.viewCoordinator() else {
            fatalError("Found child with coordinator with different ScreenProvider, such behaviour is not permitted!")
        }
        
        onVisibleScreenChanged?(childCoordinator.screenType)
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
            .modifier(viewProvider.viewsModifier)
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
            .modifier(viewProvider.viewsModifier)
            .environmentObject(coordinator)
        
        return CSUHostingController(coordinator: coordinator, root: coordinatedView,
                                    hideNavBarWhenViewIsVisible: hideNavBarWhenViewIsVisible, presentationMode: mode)
    }
}
