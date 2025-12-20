//
//  SolcastSiteView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/11/2023.
//

import Energy_Stats_Core
import MapKit
import SwiftUI

struct SolcastSiteView: View {
    let site: SolcastSite

    var body: some View {
        VStack {
            Text(site.name)
                .bold()
            
            HStack(alignment: .top) {
                Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: site.lat, longitude: site.lng),
                                                                   span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015))))
                .disabled(true)
                .frame(width: 120, height: 120)
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        row(title: "Latitude", value: site.lat)
                        row(title: "Longitude", value: site.lng)
                        row(title: "AC Capacity (inverters)", value: "\(site.acCapacity) kW")
                        OptionalView(site.dcCapacity) {
                            row(title: "DC Capacity (modules)", value: "\($0) kW")
                        }
                        row(title: "Azimuth", value: site.azimuth)
                        row(title: "Tilt", value: site.tilt)
                        OptionalView(site.lossFactor) {
                            row(title: "Loss Factor", value: $0)
                        }
                        OptionalView(site.installDate) {
                            row(title: "Install Date", value: $0.monthYearString())
                        }
                    }
                    .font(.caption)
                }
            }
        }
    }

    @ViewBuilder
    private func row(title: LocalizedStringKey, value: Int) -> some View {
        row(title: title, value: String(describing: value))
    }

    @ViewBuilder
    private func row(title: LocalizedStringKey, value: Double) -> some View {
        row(title: title, value: String(describing: value))
    }

    @ViewBuilder
    private func row(title: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.secondary)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    SolcastSiteView(site: SolcastSite.preview())
}

