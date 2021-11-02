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

    public var view: some View {
        contentView
            .coordinated(router: router)
    }
}

extension View {
    func coordinated(router: Router) -> some View {
        modifier(ViewCoordinator(router: router))
    }
}

struct ViewCoordinator: ViewModifier {
    @ObservedObject var router: Router

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $router.showingFullscreenModal) {
                router.fullscreenModal
            }
            .sheet(isPresented: $router.showingSheet) {
                router.sheet
            }
    }
}


extension Router {

    public func transition<C: Coordinator>(_ presentationStyle: PresentationStyle = .push, to: (/**/) -> C) {
        switch presentationStyle {
        case .push:
            break
        case .present(let isModalInPresentation):
            let coordinator = to()
            sheet = AnyView(coordinator.view)
            showingSheet = true
            break
        case .fullscreenModal:
            let coordinator = to()
            fullscreenModal = AnyView(coordinator.view)
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
}
