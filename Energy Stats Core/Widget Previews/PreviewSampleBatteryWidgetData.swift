//
//  PreviewSampleBatteryWidgetData.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 26/09/2023.
//

import SwiftData

@available(iOS 17.0, *)
actor PreviewSampleBatteryWidgetData {
    @MainActor
    static var container: ModelContainer = try! inMemoryContainer()

    static var inMemoryContainer: () throws -> ModelContainer = {
        let schema = Schema([BatteryWidgetState.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let sampleData: [any PersistentModel] = [
            BatteryWidgetState.preview
        ]
        Task { @MainActor in
            sampleData.forEach {
                container.mainContext.insert($0)
            }
        }
        return container
    }
}
