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
    var navigationLinkDestination: AnyView = AnyView(EmptyView())

    public init(parent: Router? = nil) {
        self.parent = parent
    }
}

public protocol Coordinator: AnyObject {
    associatedtype ViewType: View

    var contentView: ViewType { get }
    var router: Router? { get set }
}

extension Coordinator {
    public var view: some View {
        contentView
            .coordinated(coordinator: self)
    }
}

extension View {
    func coordinated<C: Coordinator>(coordinator: C) -> some View {
        modifier(ViewCoordinator(router: coordinator.router ?? Router()))
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
        .navigationViewStyle(StackNavigationViewStyle())
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

public struct NavigationLinkDestination<ViewType: View> {
    var view: ViewType
}

extension Coordinator {

    public func transition<C: Coordinator>(_ presentationStyle: PresentationStyle, to child: C) {

        child.router = Router(parent: router)

        switch presentationStyle {
        case .push:
            router?.navigationLinkDestination = AnyView(child.view)
            router?.isNavigationLinkActive = true
        case .present(let isModalInPresentation):
            router?.sheet = AnyView(child.view.containInNavigation)
            router?.showingSheet = true
            break
        case .fullscreenModal:
            router?.fullscreenModal = AnyView(child.view.containInNavigation)
            router?.showingFullscreenModal = true
            break
        case .replace:
            break
        }
    }

    public func dismiss() {
        var parent: Router? = router?.parent
        //        while parent?.parent != nil {
        //            parent = parent?.parent
        //        }
        parent?.showingSheet = false
        parent?.showingFullscreenModal = false
    }
    
    public func pop() {
        router?.isNavigationLinkActive = false
    }
}
