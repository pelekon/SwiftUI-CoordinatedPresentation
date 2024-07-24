//
//  CSUViewCoordinator.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 11/01/2024.
//

import SwiftUI
import Combine

public final class CSUViewCoordinator<ScreensProvider>: ObservableObject where ScreensProvider: CSUScreensProvider {
    typealias NavigationController = CSUCoordinatedNavigationController<ScreensProvider>
    public typealias NavigationBarUpdateHandler = (_ navigationBar: UINavigationBar) -> Void
    public typealias DismissCompletion = () -> Void
    public typealias OnDismissed = () -> Void
    
    public let screenType: ScreensProvider.ScreenType
    public private(set) var viewIsVisible = false
    private weak var navigationController: NavigationController?
    private weak var ownerVC: UIViewController?
    private(set) var onDissmissedCallback: OnDismissed?
    
    init(screenType: ScreensProvider.ScreenType, navigationController: NavigationController?) {
        self.screenType = screenType
        self.navigationController = navigationController
    }
    
    // MARK: State related
    
    /// Boolean value indicating whether view of this coordinator is presenting other view modally.
    public var isPresentingOtherView: Bool { ownerVC?.presentedViewController != nil }
    
    /// Boolean value indicating whether view is in navigation context.
    public var isInNavigationContext: Bool { ownerVC?.navigationController != nil }
    
    /// Boolean value indicating whether view of this coordinator is presented modally by other view.
    public var isPresentedModally: Bool { ownerVC?.presentingViewController != nil }
    
    /// Boolean value indicating whether view is still in navigation stack.
    public var isInNavigationStack: Bool {
        guard let navigationController, let ownerVC else { return false }
        
        return navigationController.viewControllers.contains { $0 === ownerVC }
    }
    
    /// Returns the coordinator of modally presented view if one is presented, otherwise it returns nil.
    public var childCoordinator: CSUViewCoordinator<ScreensProvider>? {
        ownerVC?.presentedViewController.flatMap { findCoordinator(of: $0) }
    }
    
    /// Returns the coordinator of view which modally presented this view if one is presented, otherwise it returns nil.
    public var parentCoordinator: CSUViewCoordinator<ScreensProvider>? {
        ownerVC?.presentingViewController.flatMap { findCoordinator(in: $0) }
    }
    
    /// Accessor of `UINavigationItem` property of view coordinated by coordinator. Returns nil if view is not embeded in navigation, otherwise it returns object.
    public var navigationItem: UINavigationItem? { ownerVC?.navigationController != nil ? ownerVC?.navigationItem : nil }
    
    /// Accessor of `UINavigationBar` property of underlaying navigation controller. Returns nil if view is not embeded in navigation, otherwise it returns object.
    public var navigationBar: UINavigationBar? { navigationController?.navigationBar }
    
    /// Sets UIBarButtonItem as template for back buttons's attachment. E.g set UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) to erase previous view's title next to backIndicatorImage.
    /// - Parameter templateFactory: Closure responsible for creating `UIBarButtonItem` object on navigation's push.
    public func setCustomBackButtonAttachment(to templateFactory: @autoclosure @escaping () -> UIBarButtonItem) {
        navigationController?.backButtonAttachmentProvider = UIBarButtonProvider(factory: templateFactory)
    }
    
    /// Finds coordinator of visible view in window's root hierarchy.
    public func findVisibleCoordinatorInRootHierarchy() -> CSUViewCoordinator<ScreensProvider>? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }
            .flatMap { $0.windows }
            .compactMap { window in
                window.rootViewController.flatMap { findCoordinator(in: $0) }
            }
            .first
    }
    
    // MARK: Navigation
    
    /// Pops the top view controller from the navigation stack.
    /// - Parameter animated: Flag to determine whether transition should get animated.
    public func navPopView(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    /// Pushes the view into navigation stack.
    /// - Parameters:
    ///   - provider: Provider of view to push.
    ///   - animated: Flag to determine whether transition should get animated.
    ///   - onDismissed: Closure called then view got popped from navigation.
    public func navPush(view provider: ScreensProvider, animated: Bool = true, onDismissed: OnDismissed? = nil) {
        navigationController?.pushView(viewProvider: provider, animated: animated, onDismissed: onDismissed)
    }
    
    /// Pushes the decorated view into navigation stack.
    /// - Parameters:
    ///   - provider: Decorated provider of view to push.
    ///   - animated: Flag to determine whether transition should get animated.
    ///   - onDismissed: Closure called then view got popped from navigation.
    public func navPush<DecoratedView>(view provider: CSUScreenViewDecorator<ScreensProvider, DecoratedView>,
                                       animated: Bool = true, onDismissed: OnDismissed? = nil) where DecoratedView: View {
        navigationController?.pushView(viewProvider: provider, animated: animated, onDismissed: onDismissed)
    }
    
    /// Pops whole navigation stack all the way to the root view.
    /// - Parameter animated: Flag to determine whether transition should get animated.
    public func navPopToRootView(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    /// Pops views until the specified view is at the top of the navigation stack.
    /// - Parameters:
    ///   - screenID: View's ID used as target.
    ///   - animated: Flag to determine whether transition should get animated.
    public func navPop(to screenType: ScreensProvider.ScreenType, animated: Bool = true) {
        navigationController?.pop(to: screenType, animated: animated)
    }
    
    /// Pops all views in navgation stack until root is at top and then replaces it with specified view.
    /// - Parameters:
    ///   - provider: Provider of new root view.
    ///   - animated: Flag to determine whether transition should get animated.
    public func navReplaceRoot(with provider: ScreensProvider, animated: Bool = true) {
        navigationController?.replaceRoot(with: provider, animated: animated)
    }
    
    /// Pops all views in navgation stack until root is at top and then replaces it with specified decorated view.
    /// - Parameters:
    ///   - provider: Decorated provider of new root view.
    ///   - animated: Flag to determine whether transition should get animated.
    public func navReplaceRoot<DecoratedView>(with provider: CSUScreenViewDecorator<ScreensProvider, DecoratedView>,
                                              animated: Bool = true) where DecoratedView: View {
        navigationController?.replaceRoot(with: provider, animated: animated)
    }
    
    // MARK: Presentation
    
    /// Presents view modally.
    /// - Parameters:
    ///   - provider: Provider of view to present.
    ///   - mode: Value used to determine style of presentation.
    ///   - animated: Flag to determine whether transition should get animated.
    ///   - onDismissed: Closure called when view got dismissed.
    public func present(view provider: ScreensProvider, with mode: CSUPresentationMode, animated: Bool = true,
                        onDismissed: OnDismissed? = nil) {
        let presentedVC = NavigationController.makeCoordinatedView(for: provider, with: mode, navigationController: nil)
        presentedVC.coordinator.setOnDissmissedCallback(onDismissed)
        
        ownerVC?.present(presentedVC, animated: animated)
    }
    
    /// Presents decorated view modally.
    /// - Parameters:
    ///   - provider: Decorated provider of view to present.
    ///   - mode: Value used to determine style of presentation.
    ///   - animated: Flag to determine whether transition should get animated.
    ///   - onDismissed: Closure called when view got dismissed.
    public func present<DecoratedView>(view provider: CSUScreenViewDecorator<ScreensProvider, DecoratedView>,
                                       with mode: CSUPresentationMode,
                                       animated: Bool = true, onDismissed: OnDismissed? = nil) where DecoratedView: View {
        let presentedVC = NavigationController.makeCoordinatedView(for: provider, with: mode, navigationController: nil)
        presentedVC.coordinator.setOnDissmissedCallback(onDismissed)
        
        ownerVC?.present(presentedVC, animated: animated)
    }
    
    /// Presents navigation embeded view modally.
    /// - Parameters:
    ///   - provider: Provider of view to present.
    ///   - mode: Value used to determine style of presentation.
    ///   - hideNavBarForRootView: Flag to hide navigation bar when root view is visible. Default is true.
    ///   - animated: Flag to determine whether transition should get animated.
    ///   - onDismissed: Closure called when navigation view got dismissed.
    public func presentWithNavigation(view provider: ScreensProvider, with mode: CSUPresentationMode,
                                      hideNavBarForRootView: Bool = true,
                                      animated: Bool = true,
                                      onDismissed: OnDismissed? = nil) {
        let presentedVC = CSUCoordinatedNavigationController(rootScreenProvider: provider,
                                                             hideNavBarForRootView: hideNavBarForRootView,
                                                             presentationMode: mode)
        if let root = presentedVC.viewControllers.first, let rootCoordinator = findCoordinator(of: root) {
            rootCoordinator.setOnDissmissedCallback(onDismissed)
        }
        
        ownerVC?.present(presentedVC, animated: animated)
    }
    
    /// Dismisses current view, and its modal children. either via navigation pop or modal dismiss.
    /// - Parameter animated: Flag to determine whether transition should get animated.
    /// - Warning: This method also dismisses any modally presented view or when view is root of modally presented navigation it will dismiss whole navigation too.
    public func dismiss(animated: Bool = true, completionHandler: DismissCompletion? = nil) {
        if ownerVC?.presentedViewController != nil {
            ownerVC?.dismiss(animated: animated) { [weak self] in
                self?.dismiss(animated: animated, completionHandler: completionHandler)
            }
            return
        }
        
        guard isInNavigationContext else {
            ownerVC?.dismiss(animated: animated) { [onDissmissedCallback] in
                completionHandler?()
                onDissmissedCallback?()
            }
            return
        }
        
        if let navigationController, navigationController.presentingViewController != nil && navigationController.viewControllers.count == 1 {
            navigationController.dismiss(animated: animated, completion: completionHandler)
        } else {
            navPopView(animated: animated)
            completionHandler?()
        }
    }
    
    // MARK: - Internal
    
    func assignNavigationController(with navigationController: NavigationController) {
        self.navigationController = navigationController
    }
    
    func assignOwningController(with viewController: UIViewController) {
        self.ownerVC = viewController
    }
    
    func updateIsVisible(_ isVisible: Bool) {
        viewIsVisible = isVisible
    }
    
    func setOnDissmissedCallback(_ callback: OnDismissed?) {
        self.onDissmissedCallback = callback
    }
    
    private func findCoordinator(of presentedVC: UIViewController) -> CSUViewCoordinator<ScreensProvider>? {
        guard let presentedHost = presentedVC as? CSUCoordinatedView else { return nil }
        
        guard let childCoordinator: CSUViewCoordinator<ScreensProvider> = presentedHost.viewCoordinator() else {
            fatalError("Found child with coordinator with different ScreenProvider, such behaviour is not permitted!")
        }
        
        return childCoordinator
    }
    
    private func findCoordinator(in viewController: UIViewController) -> CSUViewCoordinator<ScreensProvider>? {
        if let navVC = viewController as? CSUCoordinatedNavigationController<ScreensProvider> {
            return navVC.topViewController.flatMap { findCoordinator(of: $0) }
        } else if let coordinatedVC = viewController as? (any CSUCoordinatedView) {
            return coordinatedVC.viewCoordinator()
        } else if let hostedNavVC = viewController.children.first as? CSUCoordinatedNavigationController<ScreensProvider> {
            return hostedNavVC.topViewController.flatMap { findCoordinator(of: $0) }
        } else if let hostedCoordinatedVC = viewController.children.first as? (any CSUCoordinatedView) {
            return hostedCoordinatedVC.viewCoordinator()
        }
        
        return nil
    }
}
