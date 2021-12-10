import SwiftUI
import Combine
import ArchitectureX

class ViewModelA: ObservableObject {
    enum Navigation {
        case dismiss, presentFullscreenB, pushB, presentB
    }

    var navigation = PassthroughSubject<Navigation, Never>()
    private var coordinator: ContentACoordinator

    @Published var title: String = "A"

    init(coordinator: ContentACoordinator) {
        self.coordinator = coordinator

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.title = self?.title == "A" ? "a" : "A"
        }
    }
}

class ContentACoordinator: Coordinator {

    var router: Router? = Router()
    var disposeBag = Set<AnyCancellable>()

    var contentView: some View {
        let viewModel = ViewModelA(coordinator: self)
        viewModel.navigation.sink { [weak self] event in
            switch event {
            case .dismiss:
                self?.dismiss()
            case .presentFullscreenB:
                self?.transition(to: ContentBCoordinator(), style: .fullscreenModal)
            case .pushB:
                self?.transition(to: ContentBCoordinator(), style: .push)
            case .presentB:
                self?.transition(to: ContentBCoordinator(), style: .present(modalInPresentation: false))
            }
        }.store(in: &disposeBag)

        return ContentAView(viewModel: viewModel)
    }

}

struct ContentAView: View {

    @ObservedObject var viewModel: ViewModelA

    init(viewModel: ViewModelA) {
        self.viewModel = viewModel
    }

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
        .navigationTitle(Text(viewModel.title))
    }
}

final class ContentBCoordinator: Coordinator {

    var router: Router?

    var contentView: ContentBView {
        ContentBView(coordinator: self)
    }

    func presentFullscreenA() {
        transition(to: ContentACoordinator(), style: .fullscreenModal)
    }

    func pushA() {
        transition(to: ContentACoordinator(), style: .push)
    }

    func presentA() {
        transition(to: ContentACoordinator(), style: .present(modalInPresentation: false))
    }
}

struct ContentBView: View {

    let coordinator: ContentBCoordinator

    var body: some View {
        ZStack {
            Color.init(white: 0.9)

            VStack {
                VStack {
                    Button("Present A") {
                        coordinator.presentA()
                    }.padding()

                    Button("Present Fullscreen A") {
                        coordinator.presentFullscreenA()
                    }.padding()

                    Button("Push A") {
                        coordinator.pushA()
                    }.padding()
                }
            }
        }
        .navigationBarItems(trailing: Button("Close") {
            coordinator.dismiss()
        })
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationTitle(Text("B"))
    }
}
