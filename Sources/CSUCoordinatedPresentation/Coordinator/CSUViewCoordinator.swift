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
    public var adjustsFontSizeOfNavBarTitle = false
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
    
    /// Boolean value indicating whether underlaying navigation is changing top view.
    public var isNavigationDuringTransition: Bool {
        guard let navigationController else { return false }
        
        return navigationController.isDuringTopViewChange
    }
    
    /// Checks if given screen is in current navigation's stack.
    /// - Parameter screenType: Type of screen to look for.
    /// - Returns: Boolean value indicating whether screen is in stack.
    public func hasScreenInNavigationStack(screenType: ScreensProvider.ScreenType) -> Bool {
        guard let navigationController else { return false }
        
        return navigationController.containsScreen(of: screenType)
    }
    
    /// Returns the coordinator of modally presented view if one is presented, otherwise it returns nil.
    public var childCoordinator: CSUViewCoordinator<ScreensProvider>? {
        ownerVC?.presentedViewController.flatMap { findCoordinator(in: $0) }
    }
    
    /// Returns the coordinator of view which modally presented this view if one is presented, otherwise it returns nil.
    public var parentCoordinator: CSUViewCoordinator<ScreensProvider>? {
        ownerVC?.presentingViewController.flatMap { findCoordinator(in: $0) }
    }
    
    /// Returns the coordinator of root view in navigation stack, if one is present.
    public var navRootCoordinator: CSUViewCoordinator<ScreensProvider>? {
        navigationController?.viewControllers.first.flatMap { findCoordinator(of: $0) }
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
    
    /// Looks for coordinator of specified type in children of current view.
    /// - Returns: First coordinator from children which matches given type.
    public func findCoordinatorInChildren<T: CSUScreensProvider>() -> CSUViewCoordinator<T>? {
        return ownerVC?.children.compactMap { findCoordinator(in: $0) }.first
    }
    
    /// Looks for coordinator of specified type in parents of current view.
    /// - Parameter depth: Amount dictating how deep in hierarcy search will look for.
    /// - Returns: First coordinator from parents which matches given type.
    public func findParentCoordinator<T: CSUScreensProvider>(depth: Int = 2) -> CSUViewCoordinator<T>? {
        guard let parentVC = ownerVC?.parent else { return nil }
        
        return findParentCoordinator(in: parentVC, depth: depth)
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
    public func navPopToRootView(animated: Bool = true, completionHandler: DismissCompletion? = nil) {
        navigationController?.popToRootViewController(animated: animated)
        guard let navigationController, let completionHandler else { return }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if navigationController.viewControllers.count == 1 {
                timer.invalidate()
                completionHandler()
            }
        }
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
    
    /// Replaces last view of given type, in navigation stack, with new view.
    /// - Parameters:
    ///   - type: Screen type of view to be replaced.
    ///   - provider: Provider of new view.
    ///   - animated: Flag to determine whether transition should get animated.
    public func navReplaceScreen(of type: ScreensProvider.ScreenType, with provider: ScreensProvider, animated: Bool = true) {
        navigationController?.replace(screen: type, with: provider, animated: animated)
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
    ///   - additionalSafeArea: Insets to apply as additional safe area for navigation's view.
    ///   - animated: Flag to determine whether transition should get animated.
    ///   - onDismissed: Closure called when navigation view got dismissed.
    public func presentWithNavigation(view provider: ScreensProvider, with mode: CSUPresentationMode,
                                      hideNavBarForRootView: Bool = true,
                                      additionalSafeArea: UIEdgeInsets? = nil,
                                      animated: Bool = true,
                                      onDismissed: OnDismissed? = nil) {
        let presentedVC = CSUCoordinatedNavigationController(rootScreenProvider: provider,
                                                             hideNavBarForRootView: hideNavBarForRootView,
                                                             additionalSafeArea: additionalSafeArea,
                                                             presentationMode: mode)
        if let root = presentedVC.viewControllers.first,
           let rootCoordinator: CSUViewCoordinator<ScreensProvider> = findCoordinator(of: root) {
            rootCoordinator.setOnDissmissedCallback(onDismissed)
        }
        
        ownerVC?.present(presentedVC, animated: animated)
    }
    
    /// Presents not coordinated ``UIViewController``.
    /// - Warning: This method should be used only as last possible solution.
    /// - Parameters:
    ///     - viewController: ViewController to be presented.
    ///     - animated: Flag to determine whether transition should get animated.
    public func present(notCoordinated viewController: UIViewController, animated: Bool = true) {
        ownerVC?.present(viewController, animated: animated)
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
            ownerVC?.dismiss(animated: animated) { [weak self] in
                completionHandler?()
                self?.callDismissCallback()
            }
            return
        }
        
        if let navigationController, navigationController.presentingViewController != nil && navigationController.viewControllers.count == 1 {
            navigationController.dismiss(animated: animated, completion: { [weak self] in
                self?.callDismissCallback()
                completionHandler?()
            })
        } else {
            navPopView(animated: animated)
            callDismissCallback()
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
    
    // MARK: Privates
    
    private func callDismissCallback() {
        onDissmissedCallback?()
        onDissmissedCallback = nil
    }
    
    private func findCoordinator<T: CSUScreensProvider>(of presentedVC: UIViewController) -> CSUViewCoordinator<T>? {
        guard let presentedHost = presentedVC as? CSUCoordinatedView else { return nil }
        
        guard let childCoordinator: CSUViewCoordinator<T> = presentedHost.viewCoordinator() else { return nil }
        
        return childCoordinator
    }
    
    private func findCoordinator<T: CSUScreensProvider>(
        in viewController: UIViewController,
        depth: Int = 2
    ) -> CSUViewCoordinator<T>? {
        if let navVC = viewController as? CSUCoordinatedNavigationController<T> {
            return navVC.topViewController.flatMap { findCoordinator(of: $0) }
        } else if let coordinatedVC = viewController as? (any CSUCoordinatedView) {
            return coordinatedVC.viewCoordinator()
        }
        
        guard depth != 0 else { return nil }
        
        return viewController.children.compactMap {
            findCoordinator(in: $0, depth: depth - 1)
        }.first
    }
    
    private func findParentCoordinator<T: CSUScreensProvider>(
        in viewController: UIViewController,
        depth: Int = 2
    ) -> CSUViewCoordinator<T>? {
        if let navVC = viewController as? CSUCoordinatedNavigationController<T> {
            return navVC.topViewController.flatMap { findCoordinator(of: $0) }
        } else if let coordinatedVC = viewController as? (any CSUCoordinatedView),
                  let coordinator: CSUViewCoordinator<T> = coordinatedVC.viewCoordinator() {
            return coordinator
        }
        
        guard depth != 0 else { return nil }
        
        return viewController.parent.flatMap {
            findParentCoordinator(in: $0, depth: depth - 1)
        }
    }
}
