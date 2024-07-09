//
//  UIBarButtonProvider.swift
//  
//
//  Created by Bartłomiej Bukowiecki on 05/07/2024.
//

import SwiftUI

struct UIBarButtonProvider: BarItemProvider {
    let factory: () -> UIBarButtonItem
    
    func make() -> UIBarButtonItem {
        factory()
    }
}
