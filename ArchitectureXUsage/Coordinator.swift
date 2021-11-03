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
    associatedtype InteractorType: Interactor

    var contentView: ViewType { get }
    var interactor: InteractorType { get }
    var router: Router { get }
}

extension Coordinator {

    @ViewBuilder public func view(wrapInNavigation: Bool) -> some View {
        if wrapInNavigation {
            NavigationView {
                contentView
                    .coordinated(router: router)
            }
        } else {
            contentView
                .coordinated(router: router)
        }
    }
//    public var view: some View {
//
//    }
}

extension View {
    func coordinated(router: Router) -> some View {
        modifier(ViewCoordinator(router: router))
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
                .isDetailLink(false)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

public struct NavigationLinkDestination<ViewType: View> {
    var view: ViewType
}

extension Router {

    public func transition<C: Coordinator>(_ presentationStyle: PresentationStyle = .push, to: (/**/) -> C) {
        switch presentationStyle {
        case .push:
            navigationLinkDestination = AnyView(to().view(wrapInNavigation: false))
            isNavigationLinkActive = true
        case .present(let isModalInPresentation):
            sheet = AnyView(to().view(wrapInNavigation: true))
            showingSheet = true
            break
        case .fullscreenModal:
            fullscreenModal = AnyView(to().view(wrapInNavigation: true))
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
