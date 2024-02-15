//
//  CSUCoordinatedNavigationController.swift
//  CoordinatedSwiftUI
//
//  Created by Bartłomiej Bukowiecki on 14/01/2024.
//

import SwiftUI

public final class CSUCoordinatedNavigationController<ScreensProvider>: UINavigationController, UINavigationControllerDelegate where ScreensProvider: CSUScreensProvider {
    
    public let dismissPresentedViewOnViewPop: Bool
    
    init(rootScreenProvider: ScreensProvider, dismissPresentedViewOnViewPop: Bool) {
        let rootVC = Self.makeCoordinatedView(for: rootScreenProvider, navigationController: nil)
        self.dismissPresentedViewOnViewPop = dismissPresentedViewOnViewPop
        super.init(rootViewController: rootVC)
        
        self.delegate = self
        rootVC.coordinator.assignNavigationController(with: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Coordination
    
    func pushView(viewProvider: ScreensProvider, animated: Bool) {
        let hostingVC = Self.makeCoordinatedView(for: viewProvider, navigationController: self)
        
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
        let hostingVC = Self.makeCoordinatedView(for: provider, navigationController: self)
        
        setViewControllers([hostingVC], animated: true)
    }
    
    static func makeCoordinatedView(
        for viewProvider: ScreensProvider,
        with mode: CSUViewCoordinator<ScreensProvider>.PresentationMode? = nil,
        navigationController: CSUCoordinatedNavigationController<ScreensProvider>?
    ) -> CSUHostingController<some View, ScreensProvider> {
        let coordinator = CSUViewCoordinator<ScreensProvider>(screenType: viewProvider.screenType,
                                                              navigationController: navigationController)
        if let dismissFlag = navigationController?.dismissPresentedViewOnViewPop {
            coordinator.dismissPresentedViewOnViewPop = dismissFlag
        }
        let coordinatedView = viewProvider.makeScreen().environmentObject(coordinator)
        
        return CSUHostingController(coordinator: coordinator, root: coordinatedView, presentationMode: mode)
    }
    
    // MARK: - Overrides
    
    @discardableResult
    public override func popViewController(animated: Bool) -> UIViewController? {
        if let topHost = topViewController as? CSUCoordinatedView,
           let coordinator: CSUViewCoordinator<ScreensProvider> = topHost.viewCoordinator(), coordinator.dismissPresentedViewOnViewPop {
            topViewController?.dismiss(animated: false)
        }
        
        return super.popViewController(animated: animated)
    }
}
