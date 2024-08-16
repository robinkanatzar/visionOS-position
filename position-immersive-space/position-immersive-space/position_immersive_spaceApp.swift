//
//  position_immersive_spaceApp.swift
//  position-immersive-space
//
//  Created by Robin Kanatzar on 8/16/24.
//

import SwiftUI

@main
struct position_immersive_spaceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
