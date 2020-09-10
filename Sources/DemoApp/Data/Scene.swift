public class Scene {

    public var voxels: [Voxel]

    public var camera: Camera

    public init(voxels: [Voxel], camera: Camera) {

        self.voxels = voxels

        self.camera = camera
    }
}