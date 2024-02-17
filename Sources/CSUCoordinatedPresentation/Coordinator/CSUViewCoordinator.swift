//
//  CSUViewCoordinator.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 11/01/2024.
//

import SwiftUI

public final class CSUViewCoordinator<ScreensProvider>: ObservableObject where ScreensProvider: CSUScreensProvider {
    typealias NavigationController = CSUCoordinatedNavigationController<ScreensProvider>
    public typealias NavigationBarUpdateHandler = (_ navigationBar: UINavigationBar) -> Void
    
    let screenType: ScreensProvider.ScreenType
    private weak var navigationController: NavigationController?
    private weak var ownerVC: UIViewController?
    
    init(screenType: ScreensProvider.ScreenType, navigationController: NavigationController?) {
        self.screenType = screenType
        self.navigationController = navigationController
    }
    
    // MARK: State related
    
    /// Boolean value indicating whether view of this coordinator is presenting other view modally.
    public var isPresentingOtherView: Bool { ownerVC?.presentedViewController != nil }
    
    /// Boolean value indicating whether view is in navigation context.
    public var isInNavigationContext: Bool { ownerVC?.navigationController != nil }
    
    /// Returns the coordinator of modally presented view if one is presented, otherwise it returns nil.
    public var childCoordinator: CSUViewCoordinator<ScreensProvider>? {
        ownerVC?.presentedViewController.flatMap { findCoordinator(of: $0) }
    }
    
    /// Accessor of `UINavigationItem` property of view coordinated by coordinator. Returns nil if view is not embeded in navigation, otherwise it returns object.
    public var navigationItem: UINavigationItem? { ownerVC?.navigationController != nil ? ownerVC?.navigationItem : nil }
    
    /// Allows update of `UINavigationBar` in underlaying `UINavigationController` if one exists.
    /// - Parameter handler: Closure responsible for handling update of `UINavigationBar`.
    public func updateNavigationBar(_ handler: NavigationBarUpdateHandler) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        handler(navigationBar)
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
    public func navPush(view provider: ScreensProvider, animated: Bool = true) {
        navigationController?.pushView(viewProvider: provider, animated: animated)
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
    
    // MARK: Presentation
    
    /// Presents view modally.
    /// - Parameters:
    ///   - provider: Provider of view to present.
    ///   - mode: Value used to determine style of presentation.
    ///   - animated: Flag to determine whether transition should get animated.
    public func present(view provider: ScreensProvider, with mode: PresentationMode, animated: Bool = true) {
        let presentedVC = NavigationController.makeCoordinatedView(for: provider, with: mode, navigationController: nil)
        
        ownerVC?.present(presentedVC, animated: animated)
    }
    
    /// Dismisses current view, and its modal children. either via navigation pop or modal dismiss.
    /// - Parameter animated: Flag to determine whether transition should get animated.
    /// - Warning: This method also dismisses any modally presented view!
    public func dismiss(animated: Bool = true) {
        if ownerVC?.presentedViewController != nil {
            ownerVC?.dismiss(animated: animated) { [weak self] in
                self?.dismiss(animated: animated)
            }
            return
        }
        
        if isInNavigationContext {
            navPopView(animated: animated)
        } else {
            ownerVC?.dismiss(animated: animated)
        }
    }
    
    // MARK: - Internal
    
    func assignNavigationController(with navigationController: NavigationController) {
        self.navigationController = navigationController
    }
    
    func assignOwningController(with viewController: UIViewController) {
        self.ownerVC = viewController
    }
    
    private func findCoordinator(of presentedVC: UIViewController) -> CSUViewCoordinator<ScreensProvider>? {
        guard let presentedHost = presentedVC as? CSUCoordinatedView else { return nil }
        
        guard let childCoordinator: CSUViewCoordinator<ScreensProvider> = presentedHost.viewCoordinator() else {
            fatalError("Found child with coordinator with different ScreenProvider, such behaviour is not permitted!")
        }
        
        return childCoordinator
    }
}
