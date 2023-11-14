import Foundation
import SwiftUI
import WebKit
import ExpoFpCommon

final class FplanViewState: ObservableObject {
    var fplanUiKitView: UIFplanView = UIFplanView()
}

public struct FplanView: UIViewRepresentable {
    
    @ObservedObject var state = FplanViewState()

    public init() {
    }
    
    public func makeUIView(context: Context) -> UIFplanView {
        return state.fplanUiKitView
    }
    
    public func updateUIView(_ webView: UIFplanView, context: Context) {
    }
    
    public static func dismantleUIView(_ uiView: UIFplanView, coordinator: ()) {
        uiView.destoy()
    }
}
