//
//  UnsupportedErrorView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/12/2023.
//

import SwiftUI

struct UnsupportedErrorView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 44) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Energy Stats was built on APIs that are used by the FoxESS cloud website and app, in the same way other 3rd party integrations were built.")

                    Text("FoxESS has recently made changes to their data access policies, which now limits the availability of certain data essential for Energy Stats to operate effectively. They have directed me towards using their OpenAPIs, but these do not currently include key pieces of information listed below. As a result, the functionality of Energy Stats is significantly impacted.")

                    Text("If a sufficient number of these information types become available I will be able to update the app.")
                }

                VStack(alignment: .leading) {
                    Text("Unavailable information")
                        .font(.title)

                    bulletItem(
                        title: "Device list",
                        detail: "used in determining what inverters you have, and if you have solar attached to the current device for the flow tab"
                    )

                    bulletItem(
                        title: "Battery residual amount",
                        detail: "used in calculating the time to full/empty"
                    )

                    bulletItem(
                        title: "Firmware versions",
                        detail: "displayed in settings > inverter tab"
                    )

                    bulletItem(
                        title: "Today's yield",
                        detail: "displayed at the top of the power flow tab"
                    )

                    bulletItem(
                        title: "Statistics",
                        detail: "used in the stats tab, summary tab, and calculating today's yield"
                    )

                    bulletItem(
                        title: "Parameter data older than 3 days",
                        detail: "used on the parameter tab for analysing historic behaviour"
                    )

                    bulletItem(
                        title: "Battery Charge Period setting",
                        detail: "used for adjusting start/stop force charge periods"
                    )

                    bulletItem(
                        title: "Battery Min SOC setting",
                        detail: "used for adjusting min SOC settings"
                    )

                    bulletItem(
                        title: "Inverter work mode setting",
                        detail: "used for adjusting the current work mode (without schedule)"
                    )

                    bulletItem(
                        title: "Scheduler template management",
                        detail: "used for defining work mode scheduler templates"
                    )

                    bulletItem(
                        title: "Datalogger data",
                        detail: "used for displaying data logger and signal strength"
                    )
                }
            }
            .padding()
        }
    }

    func bulletItem(title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top) {
            Text("•")
            VStack(alignment: .leading) {
                Text(title)
                Text(detail)
                    .font(.caption)
            }
        }
        .padding(.bottom, 4)
    }
}

#Preview {
    UnsupportedErrorView()
}
