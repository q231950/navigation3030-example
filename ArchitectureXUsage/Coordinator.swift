import Foundation
import SwiftUI

/// The style a coordinator should be presented in when transitioning to it.
public enum PresentationStyle {
    case push
    case present(modalInPresentation: Bool)
    case fullscreenModal
    case replace
}

public class Router: ObservableObject {
    public unowned var parent: Router?

    @Published public var showingSheet = false
    public var sheet: AnyView = AnyView(EmptyView())

    @Published public var showingFullscreenModal = false
    public var fullscreenModal: AnyView = AnyView(EmptyView())

    @Published public var isNavigationLinkActive = false
    var navigationLinkDestination: AnyView?

    public init(parent: Router? = nil) {
        self.parent = parent
    }
}

public protocol Coordinator {
    associatedtype ViewType: View

    var contentView: ViewType { get }
    var router: Router { get }
}

extension Coordinator {
    public var view: some View {
        contentView
            .coordinated(router: router)
    }
}

class AnyCoordinator: Coordinator {
    var router: Router

    let view: AnyView
    let child: Any

    init<C: Coordinator>(_ child: C) {
        view = AnyView(child.contentView)
        self.router = child.router
        self.child = child
    }

    var contentView: AnyView {
        view
    }

}

class AppCoordinator: Coordinator {

    static var shared = {
        AppCoordinator(Router())
    }()

    var children = [AnyCoordinator]()

    private init(_ router: Router) {
        self.router = router
    }

    func add<C: Coordinator>(_ child: C) {
        children.append(AnyCoordinator(child))
    }

    var router: Router

    var root: AnyCoordinator?

    func configure<C: Coordinator>(with root: C) {
        let child = AnyCoordinator(root)
        children.append(child)
        self.root = child
        router = child.router
    }

    var contentView: some View {
        root?.contentView
    }
}


extension View {
    func coordinated(router: Router) -> some View {
        modifier(ViewCoordinator(router: router))
    }

    var containInNavigation: some View {
        modifier(ViewNavigationContainer())
    }
}

struct ViewNavigationContainer: ViewModifier {

    func body(content: Content) -> some View {
        NavigationView {
            content
        }
    }
}

struct ViewCoordinator: ViewModifier {
    @ObservedObject var router: Router

    /// Hiding the navigation bar is possible with view modifiers:
    /// ```swift
    ///  Button("present") {
    ///   interactor.presentContentB()
    /// }
    /// .navigationBarTitle("")
    /// .navigationBarHidden(true)
    /// ```
    ///
    func body(content: Content) -> some View {
            ZStack {
                content
                    .fullScreenCover(isPresented: $router.showingFullscreenModal) {
                        router.fullscreenModal
                    }
                    .sheet(isPresented: $router.showingSheet) {
                        router.sheet
                    }
                NavigationLink(isActive: $router.isNavigationLinkActive) {
                    router.navigationLinkDestination
                } label: {
                    // nothing since this is provided by the initiator of the navigation link
                }
        }
    }
}

public struct NavigationLinkDestination<ViewType: View> {
    var view: ViewType
}

extension Router {

    public func transition<C: Coordinator>(_ presentationStyle: PresentationStyle, to: (/**/) -> C) {

        let child = to()
        AppCoordinator.shared.add(AnyCoordinator(child))

        switch presentationStyle {
        case .push:
            navigationLinkDestination = AnyView(child.view)
            isNavigationLinkActive = true
        case .present(let isModalInPresentation):
            sheet = AnyView(child.view.containInNavigation)
            showingSheet = true
            break
        case .fullscreenModal:
            fullscreenModal = AnyView(child.view.containInNavigation)
            showingFullscreenModal = true
            break
        case .replace:
            break
        }
    }

    public func dismiss() {
        showingSheet = false
        showingFullscreenModal = false
    }
    
    public func pop() {
        isNavigationLinkActive = false
    }
}
