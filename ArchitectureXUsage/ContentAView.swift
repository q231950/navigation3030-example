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

    func dismiss() {
        router.parent?.dismiss()
    }

    func presentFullscreenB() {
        router.transition(.fullscreenModal) {
            ContentBCoordinator(router: Router(parent: router))
        }
    }

    func pushB() {
        router.transition(.push) {
            ContentBCoordinator(router: Router(parent: router))
        }
    }

    func presentB() {
        router.transition(.present(modalInPresentation: false)) {
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
                Button("Present B") {
                    interactor.presentB()
                }.padding()

                Button("Present Fullscreen B") {
                    interactor.presentFullscreenB()
                }.padding()

                Button("Push B") {
                    interactor.pushB()
                }.padding()
            }
        }
        .navigationBarItems(trailing: Button("Close") {
            interactor.dismiss()
        })
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

    var contentView: ContentBView {
        ContentBView(interactor: interactor)
    }
}

struct ContentBInteractor: Interactor {

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

    let interactor: ContentBInteractor

    var body: some View {
        ZStack {
            Color.init(white: 0.9)

            VStack {
                VStack {
                    Button("Present A") {
                        interactor.presentA()
                    }.padding()

                    Button("Present Fullscreen A") {
                        interactor.presentFullscreenA()
                    }.padding()

                    Button("Push A") {
                        interactor.pushA()
                    }.padding()
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
