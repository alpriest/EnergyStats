//
//  SlowServerTip.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/06/2024.
//

import TipKit

@available(iOS 17.0, *)
struct SlowServerTip: Tip {
    var title: Text {
        Text("Slow performance")
    }

    var message: Text? {
        Text("slow-performance-message")
    }

    var image: Image? {
        Image("server-performance")
    }
}

@available(iOS 17.0, *)
struct SlowServerTipStyle: TipViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                configuration.title
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
                Button(action: {
                    configuration.tip.invalidate(reason: .tipClosed)
                }, label: {
                    Image(systemName: "xmark")
                })
            }

            configuration.message?
                .font(.body)
                .fontWeight(.regular)
                .foregroundStyle(.secondary)

            configuration.image?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 350)

            if let handler = configuration.actions.first?.handler {
                Button(action: handler, label: {
                    configuration.actions.first!.label()
                })
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

@available(iOS 17.0, *)
#Preview {
    TipView(SlowServerTip())
        .tipViewStyle(SlowServerTipStyle())
}
