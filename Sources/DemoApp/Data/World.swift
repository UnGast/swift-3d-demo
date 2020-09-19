import CustomGraphicsMath
import VisualAppBase

public class World {

    public static let upDirection = DVec3(0, 1, 0)
    
    public static let rightDirection = DVec3(1, 0, 0)
    
    public static let forwardDirection = DVec3(0, 0, 1)

    public var voxels: [Voxel]

    public var onEvent = EventHandlerManager<World.Event>()

    public init(voxels: [Voxel]) {
        
        self.voxels = voxels
    }

    public func updateVoxel(_ updatedVoxel: Voxel) {

        for (index, voxel) in voxels.enumerated() {

            if voxel.position == updatedVoxel.position {

                voxels[index] = updatedVoxel

                onEvent.invokeHandlers(.VoxelUpdated(voxel: updatedVoxel))

                break
            }
        }
    }
}

extension World {

    public enum Event {

        case VoxelUpdated(voxel: Voxel)
    }
}