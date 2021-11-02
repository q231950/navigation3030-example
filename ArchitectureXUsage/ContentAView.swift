import SwiftUI

class ContentACoordinator: Coordinator {

    var router: Router
    var interactor: ContentAInteractor

    init() {
        let router = Router()
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
            //        router.transition(.fullscreenModal) {
            ContentBCoordinator(router: Router(parent: router))
        }
    }
}

struct ContentAView: View {

    let interactor: ContentAInteractor

    var body: some View {
        VStack {
            Text("A")
                .padding()

            Button("toggle") {
                interactor.presentContentB()
            }
        }
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
}

struct ContentBView: View {

    let interactor: ContentBInteractor

    var body: some View {
        NavigationView {
            ZStack {
                Color.secondary

                Text(["A", "a", "B", "b"].randomElement()!)
                    .navigationBarItems(trailing: Button("Close") {
                        interactor.dismiss()
                    })
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .navigationTitle(Text("abc"))
        }
    }
}
