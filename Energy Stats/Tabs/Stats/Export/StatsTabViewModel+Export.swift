//
//  StatsTabViewModel+Export.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/12/2025.
//

import Foundation

extension StatsTabViewModel {
    func prepareExport(rawData: [StatsGraphValue]) -> TextFile? {
        let headers = ["Type", "Date", "Value"].lazy.joined(separator: ",")
        let rows = rawData.map {
            [$0.type.networkTitle, $0.date.iso8601(), $0.formatted(2)].lazy.joined(separator: ",")
        }
        
        let text = ([headers] + rows).joined(separator: "\n")
        let exportFileName: String
        
        switch displayMode {
        case .day(let date):
            let name = dateName(from: date)
            exportFileName = "energystats_stats_\(name).csv"
        case .month(let month, let year):
            exportFileName = "energystats_stats_\(year)_\(month + 1).csv"
        case .year(let year):
            exportFileName = "energystats_stats_\(year).csv"
        case .custom(let start, let end, _):
            let startName = dateName(from: start)
            let endName = dateName(from: end)
            exportFileName = "energystats_stats_\(startName)_\(endName).csv"
        }
        
        return TextFile(text: text, filename: exportFileName)
    }
    
    func dateName(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        if let year = components.year, let month = components.month, let day = components.day {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            return "\(year)_\(month)_\(day)"
        } else {
            return "unknown_date"
        }
    }
}
