import SwiftUI

struct AContentView: View {

    @State var isShowingContent = false

    var body: some View {
        VStack {
            Text("A")
                .padding()

            Button("toggle") {
                isShowingContent.toggle()
            }
        }
        .sheet(isPresented: $isShowingContent) {
            print("on dismiss")
        } content: {
            BContentView()
        }
    }
}

struct BContentView: View {

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Text("B")
                .navigationBarItems(trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}
