//
//  positionApp.swift
//  position
//
//  Created by Robin Kanatzar on 8/15/24.
//

import SwiftUI

@main
struct positionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
