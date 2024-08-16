//
//  ImmersiveView.swift
//  position-immersive-space
//
//  Created by Robin Kanatzar on 8/16/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct ImmersiveView: View {
    
    let device = Device()
    /// Entity representing the user's current position (the device's current position)
    /// Displayed with an offset, so it is visible to the user while using the app
    let box = ModelEntity(mesh: .generateBox(size: 0.2))
    /// The entity the user wants to find in 3D space.
    let sphere = ModelEntity(mesh: .generateSphere(radius: 0.2), materials: [UnlitMaterial(color: .blue)])
    
    /// Attachment on the `box` entity, containing description of where the `sphere` is located
    @State var boxAttachment: String = "-"
    
    var body: some View {
        RealityView { content, attachments in
            if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(scene)
            }
            
            Task {
                await device.runArSession()
            }

            box.name = "box"
            /// A random value on the x-axis that goes from the user's left to the user's right
            let randomX = Float.random(in: -3..<3)
            /// A random value on the y-axis that goes from the user's feet to above the user's head
            let randomY = Float.random(in: 0..<3)
            /// A random value on the z-axis that goes from behind the user to in front of the user
            let randomZ = Float.random(in: -3..<3)
            sphere.setPosition([randomX, randomY, randomZ], relativeTo: nil)

            content.add(sphere)
            content.add(box)
            
            if let boxAttachment = attachments.entity(for: "box") {
                boxAttachment.position = [0, -0.2, 0]
                box.addChild(boxAttachment)
            }
            
            let _ = content.subscribe(to: SceneEvents.Update.self) { _ in
                Task {
                    /// Positition information for the device (Apple Vision Pro)
                    let transform = await device.getTransform()
                    /// Offset necessary to display the `box` entity while using the app
                    /// Without the offset the `box` position would be the physical position of the device,
                    /// and would not be visible to the user
                    let offset: Float = -1.0
                    
                    box.position = [Float((transform?.columns.3.x ?? 0.0)),
                                    Float((transform?.columns.3.y ?? 0.0)),
                                    Float((transform?.columns.3.z ?? 0.0)) + offset]

                    boxAttachment = "The blue sphere is \(getRelativePosition(of: sphere, to: box, zOffset: offset))"
                }
                
            }
        } attachments: {
            Attachment(id: "box") {
                Text("\(boxAttachment)")
                    .font(.extraLargeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
                    .glassBackgroundEffect()
            }
        }
    }
    
    func getRelativePosition(of entity1: Entity, to entity2: Entity?, zOffset: Float = 0.0) -> String {
        let relativePosition: SIMD3<Float> = entity1.position(relativeTo: entity2)

        var positionText = ""
        /// Custom range of tolerance on each axis
        /// For example: +/- 0.2 in the x-direction is still considered in the center
        let limit: Float = 0.2
        if relativePosition.y > limit {
            // above user
            positionText += "above you"
            positionText += zAndXAxisDesc(relativePosition: relativePosition, limit: limit, zOffset: zOffset)
        } else if relativePosition.y < -limit {
            // below user
            positionText += "below you"
            positionText += zAndXAxisDesc(relativePosition: relativePosition, limit: limit, zOffset: zOffset)
        } else {
            // in front of user, at their eye level (between -0.5 and 0.5)
            positionText += "at your eye level"
            positionText += zAndXAxisDesc(relativePosition: relativePosition, limit: limit, zOffset: zOffset)
        }
        
        return positionText
    }
    
    /// Gets the description text about the z and x-axis position
    private func zAndXAxisDesc(relativePosition: SIMD3<Float>, limit: Float, zOffset: Float) -> String {
        var positionText = ""
        if (relativePosition.z + zOffset) > limit {
            // behind user
            positionText += behind(relativePosition: relativePosition, limit: limit)
        } else if (relativePosition.z + zOffset) < -limit {
            // in front of user
            positionText += inFront(relativePosition: relativePosition, limit: limit)
        } else {
            // beside user
            positionText += beside(relativePosition: relativePosition, limit: limit)
        }
        return positionText
    }
    
    /// Gets the description text when the position is behind the user
    private func behind(relativePosition: SIMD3<Float>, limit: Float) -> String {
        var positionText = ""
        if relativePosition.x > limit {
            // to the right of the user
            positionText += ", behind you, and over your right shoulder"
        } else if relativePosition.x < -limit {
            // to the left of the user
            positionText += ", behind you, and over your left shoulder"
        } else {
            // in front of user (between -0.5 and 0.5)
            positionText += ", and directly behind you"
        }
        return positionText
    }
    
    /// Gets the description text when the position is in front of the user
    private func inFront(relativePosition: SIMD3<Float>, limit: Float) -> String {
        var positionText = ""
        if relativePosition.x > limit {
            // to the right of the user
            positionText += ", in front of you, and to your right"
        } else if relativePosition.x < -limit {
            // to the left of the user
            positionText += ", in front of you, and to your left"
        } else {
            // in front of user (between -0.5 and 0.5)
            positionText += ", and directly in front of you"
        }
        return positionText
    }
    
    /// Gets the description text when the position is beside the user
    private func beside(relativePosition: SIMD3<Float>, limit: Float) -> String {
        var positionText = ", beside you"
        if relativePosition.x > limit {
            // to the right of the user
            positionText += " on the right"
        } else if relativePosition.x < -limit {
            // to the left of the user
            positionText += " on the left"
        }
        return positionText
    }
}
