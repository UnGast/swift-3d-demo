import CustomGraphicsMath
import GL

public class GLSceneRenderer {

    private let scene: Scene

    private var voxelRenderer: GLVoxelRenderer

    private var gridRenderer: GLGridRenderer

    public init(scene: Scene) {

        self.scene = scene

        self.voxelRenderer = GLVoxelRenderer()

        self.gridRenderer = GLGridRenderer()
    }

    public func setup() {

        voxelRenderer.setup()

        gridRenderer.setup()
    }

    public func render() {

        let camera = scene.camera

        let cameraTransformation = Matrix4<Float>([

            camera.right.x, camera.right.y, camera.right.z, 0,

            camera.up.x, camera.up.y, camera.up.z, 0,

            camera.forward.x, camera.forward.y, camera.forward.z, 0,

            0, 0, 0, 1

        ].map(Float.init)).matmul(Matrix4<Float>([

            1, 0, 0, -camera.position.x,

            0, 1, 0, -camera.position.y,

            0, 0, 1, -camera.position.z,

            0, 0, 0, 1

        ].map(Float.init)))

        let near = 0.1

        let far = 100.0

        let fov = camera.fov

        let scale = 1 / (tan(fov / 2.0 * Double.pi / 180.0))

        let projectionTransformation = Matrix4<GLMap.Float>([

            Float(scale), 0, 0, 0,

            0, Float(scale), 0, 0,

            0, 0, Float(-far/(far - near)), Float(-(far * near)/(far - near)),

            0, 0, -1, 0
        ])

        let viewTransformation = projectionTransformation.matmul(cameraTransformation)

        var context = GLRenderContext()

        context.cameraTransformation = cameraTransformation

        context.projectionTransformation = projectionTransformation

        context.viewTransformation = viewTransformation

        voxelRenderer.viewTransformation = viewTransformation

        voxelRenderer.render(voxels: scene.world.voxels, camera: scene.camera)

        gridRenderer.render(scene: scene, context: context)
    }
}