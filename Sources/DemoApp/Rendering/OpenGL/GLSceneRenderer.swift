import CustomGraphicsMath

public class GLSceneRenderer {

    private let scene: Scene

    public init(scene: Scene) {

        self.scene = scene
    }

    public func setup() {

        GLVoxelRenderer.setup()
    }

    public func render() {

        GLVoxelRenderer.render(voxels: scene.voxels, camera: scene.camera)
    }
}