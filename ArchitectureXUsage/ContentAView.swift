import SwiftUI
import Combine

class ViewModelA: ObservableObject {
    enum Navigation {
        case dismiss, presentFullscreenB, pushB, presentB
    }

    var navigation = PassthroughSubject<Navigation, Never>()
}

class ContentACoordinator: Coordinator {

    var router: Router
    let viewModel: ViewModelA
    var disposeBag = Set<AnyCancellable>()

    var contentView: some View {
        ContentAView(viewModel: viewModel)
    }

    init(router: Router) {
        self.router = router
        self.viewModel = ViewModelA()

        self.viewModel.navigation.sink { event in
            switch event {
            case .dismiss:
                router.parent?.dismiss()
            case .presentFullscreenB:
                router.transition(.fullscreenModal) {
                    ContentBCoordinator(router: Router(parent: router))
                }
            case .pushB:
                router.transition(.push) {
                    ContentBCoordinator(router: Router(parent: router))
                }
            case .presentB:
                router.transition(.present(modalInPresentation: false)) {
                    ContentBCoordinator(router: Router(parent: router))
                }
            }
        }.store(in: &disposeBag)
    }
}

struct ContentAView: View {

    unowned var viewModel: ViewModelA

    var body: some View {
        ZStack {
            Color.init(white: 0.9)
            VStack {
                Button("Present B") {
                    viewModel.navigation.send(.presentB)
                }.padding()

                Button("Present Fullscreen B") {
                    viewModel.navigation.send(.presentFullscreenB)
                }.padding()

                Button("Push B") {
                    viewModel.navigation.send(.pushB)
                }.padding()
            }
        }
        .navigationBarItems(trailing: Button("Close") {
            viewModel.navigation.send(.dismiss)
        })
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationTitle(Text("A"))
    }
}

final class ContentBCoordinator: Coordinator {

    var router: Router
    var navigator: ContentBNavigator

    init(router: Router) {
        navigator = ContentBNavigator(router: router)
        self.router = router
    }

    var contentView: ContentBView {
        ContentBView(navigator: navigator)
    }
}

struct ContentBNavigator {

    let router: Router

    func dismiss() {
        router.parent?.dismiss()
    }

    func presentFullscreenA() {
        router.transition(.fullscreenModal) {
            ContentACoordinator(router: Router(parent: router))
        }
    }

    func pushA() {
        router.transition(.push) {
            ContentACoordinator(router: Router(parent: router))
        }
    }

    func presentA() {
        router.transition(.present(modalInPresentation: false)) {
            ContentACoordinator(router: Router(parent: router))
        }
    }
}

struct ContentBView: View {

    let navigator: ContentBNavigator

    var body: some View {
        ZStack {
            Color.init(white: 0.9)

            VStack {
                VStack {
                    Button("Present A") {
                        navigator.presentA()
                    }.padding()

                    Button("Present Fullscreen A") {
                        navigator.presentFullscreenA()
                    }.padding()

                    Button("Push A") {
                        navigator.pushA()
                    }.padding()
                }
            }
        }
        .navigationBarItems(trailing: Button("Close") {
            navigator.dismiss()
        })
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationTitle(Text("B"))
    }
}
