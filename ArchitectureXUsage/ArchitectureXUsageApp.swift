//
//  ArchitectureXUsageApp.swift
//  ArchitectureXUsage
//
//  Created by Martin Kim Dung-Pham on 02.08.21.
//

import SwiftUI

@main
struct ArchitectureXUsageApp: App {

    let appCoordinator = AppCoordinator.shared

    init() {
        AppCoordinator.shared.configure(with: AnyCoordinator(ContentACoordinator(router: Router())))
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinator.shared.view(wrapInNavigation: true)
        }
    }
}
