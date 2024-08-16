//
//  Device.swift
//  position-immersive-space
//
//  Created by Robin Kanatzar on 8/16/24.
//

import ARKit
import SwiftUI

@Observable class Device {
    let session = ARKitSession()
    let worldTracking = WorldTrackingProvider()
    
    func runArSession() async {
        Task {
            try? await session.run([worldTracking])
        }
    }

    func getTransform() async -> simd_float4x4? {
        guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return nil
        }
    
        let transform = deviceAnchor.originFromAnchorTransform
        return transform
    }
}
