//
//  ArchitectureXUsageApp.swift
//  ArchitectureXUsage
//
//  Created by Martin Kim Dung-Pham on 02.08.21.
//

import SwiftUI
import ArchitectureX

@main
struct ArchitectureXUsageApp: App {

    var body: some Scene {
        WindowGroup {
            ContentACoordinator()
                .view
                .containInNavigation
        }
    }
}
