//
//  SingleSelectView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/08/2023.
//

import SwiftUI

struct SingleSelectView<T: Selectable, Header: View, Footer: View>: View {
    @ObservedObject var viewModel: SingleSelectableListViewModel<T>
    @Environment(\.dismiss) var dismiss
    private let header: () -> Header
    private let footer: () -> Footer

    init(_ viewModel: SingleSelectableListViewModel<T>,
         header: @escaping () -> Header,
         footer: @escaping () -> Footer)
    {
        self.viewModel = viewModel
        self.header = header
        self.footer = footer
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    List {
                        ForEach(viewModel.items, id: \.self) { item in
                            Button {
                                viewModel.toggle(updating: item)
                            } label: {
                                HStack(alignment: .firstTextBaseline) {
                                    Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                                    VStack(alignment: .leading) {
                                        Text(item.item.title)

                                        OptionalView(item.item.subtitle) {
                                            AnyView($0)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } header: {
                    header()
                } footer: {
                    footer()
                }
            }

            VStack(spacing: 0) {
                Color("BottomBarDivider")
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("cancel")

                    Button(action: {
                        viewModel.apply()
                        dismiss()
                    }) {
                        Text("Apply")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

struct SingleSelectView_Previews: PreviewProvider {
    static var previews: some View {
        SingleSelectView(SingleSelectableListViewModel([WorkModes.selfUse],
                                                       allItems: WorkModes.allCases,
                                                       onApply: { _ in }),
                         header: { Text("Header") },
                         footer: { Text("Footer") })
    }
}

protocol Describable {
    associatedtype ExtraContent: View

    var title: String { get }
    var subtitle: ExtraContent { get }
}

typealias Selectable = Describable & Hashable

struct SelectableItem<T: Selectable>: Identifiable, Equatable, Hashable {
    let item: T
    var isSelected: Bool
    var id: String { item.title }

    init(_ item: T, isSelected: Bool = false) {
        self.item = item
        self.isSelected = isSelected
    }

    mutating func setSelected(_ selected: Bool) {
        isSelected = selected
    }
}

protocol SelectableListViewModel: ObservableObject {
    associatedtype T: Selectable

    func toggle(updating: SelectableItem<T>)
    func apply()
}

final class SingleSelectableListViewModel<T: Selectable>: SelectableListViewModel {
    @Published var items: [SelectableItem<T>]
    private let onApply: ([T]) -> Void

    init(_ selected: [T], allItems: [T], onApply: @escaping ([T]) -> Void) {
        self.onApply = onApply
        self.items = allItems.map { SelectableItem($0, isSelected: selected.contains($0)) }
    }

    func toggle(updating: SelectableItem<T>) {
        items = items.map { existingVariable in
            var existingVariable = existingVariable

            if existingVariable.id == updating.id {
                existingVariable.setSelected(true)
            } else {
                existingVariable.setSelected(false)
            }

            return existingVariable
        }
    }

    func apply() {
        onApply(items.filter { $0.isSelected }.map { $0.item })
    }
}
