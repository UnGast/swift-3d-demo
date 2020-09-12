import CustomGraphicsMath

public class World {

    public static let upDirection = DVec3(0, 1, 0)
    
    public static let rightDirection = DVec3(1, 0, 0)
    
    public static let forwardDirection = DVec3(0, 0, 1)

    public var voxels: [Voxel]

    public init(voxels: [Voxel]) {
        
        self.voxels = voxels
    }
}