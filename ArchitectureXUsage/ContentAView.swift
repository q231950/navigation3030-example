import SwiftUI

class ContentACoordinator: Coordinator {

    var router: Router
    var interactor: ContentAInteractor

    init(router: Router) {
        interactor = ContentAInteractor(router: router)
        self.router = router
    }

    var contentView: some View {
        ContentAView(interactor: interactor)
    }
}

struct ContentAInteractor: Interactor {
    let router: Router

    func presentContentB() {
        router.transition(.present(modalInPresentation: true)) {
            ContentBCoordinator(router: Router(parent: router))
        }
    }
}

struct ContentAView: View {

    let interactor: ContentAInteractor

    var body: some View {
        ZStack {
            Color.init(white: 0.9)
            VStack {
                Text("A")
                    .padding()

                Button("present") {
                    interactor.presentContentB()
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationTitle(Text("A"))
    }
}

final class ContentBCoordinator: Coordinator {

    var router: Router
    var interactor: ContentBInteractor

    init(router: Router) {
        interactor = ContentBInteractor(router: router)
        self.router = router
    }

    var contentView: some View {
        ContentBView(interactor: interactor)
    }
}

struct ContentBInteractor: Interactor {

    let router: Router

    func dismiss() {
        router.parent?.dismiss()
    }

    func navigate() {
        let x = [1,2,3].randomElement()!
        switch x {
        case 1:
            router.transition(.push) {
                ContentACoordinator(router: router)
            }
        case 2:
            router.transition(.fullscreenModal) {
                ContentBCoordinator(router: Router(parent: router))
            }
        case 3:
            router.transition(.present(modalInPresentation: false)) {
                ContentBCoordinator(router: Router(parent: router))
            }
        default: break
        }

    }
}

struct ContentBView: View {

    let interactor: ContentBInteractor

    var body: some View {
        ZStack {
            Color.init(white: 0.9)

            VStack {
                Text("B")
                    .padding()

                Button {
                    interactor.navigate()
                } label: {
                    Text("Navigate")
                }
            }
        }
        .navigationBarItems(trailing: Button("Close") {
            interactor.dismiss()
        })
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationTitle(Text("B"))
    }
}
