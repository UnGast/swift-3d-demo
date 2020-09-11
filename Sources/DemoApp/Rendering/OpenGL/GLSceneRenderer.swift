import CustomGraphicsMath

public class GLSceneRenderer {

    private let scene: Scene

    private var voxelRenderer: GLVoxelRenderer

    public init(scene: Scene) {

        self.scene = scene

        self.voxelRenderer = GLVoxelRenderer()
    }

    public func setup() {

        voxelRenderer.setup()
    }

    public func render() {

        voxelRenderer.render(voxels: scene.world.voxels, camera: scene.camera)
    }
}