//
//  OptionalView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/09/2022.
//

import SwiftUI

struct OptionalView<T, Content>: View where Content: View {
    internal init(_ item: T?, content: @escaping (T) -> Content) {
        self.item = item
        self.content = content
    }

    let item: T?
    var content: (T) -> Content

    var body: some View {
        Group {
            if let item = item {
                content(item)
            }
        }
    }
}

struct OptionalView_Previews: PreviewProvider {
    static var previews: some View {
        let optional: String? = "hi"
        let unset: String? = nil

        return VStack {
            OptionalView(optional) {
                Text($0)
            }

            OptionalView(unset) {
                Text($0)
            }
        }
    }
}
