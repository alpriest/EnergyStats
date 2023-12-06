//
//  OptionalView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/09/2022.
//

import SwiftUI

public struct OptionalView<T, Content>: View where Content: View {
    public init(_ item: T?, @ViewBuilder content: @escaping (T) -> Content) {
        self.item = item
        self.content = content
    }

    public let item: T?
    public var content: (T) -> Content

    public var body: some View {
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
            OptionalView(optional) { f in
                Text(f)
                Text(f)
            }

            OptionalView(unset) {
                Text($0)
            }
        }
    }
}
