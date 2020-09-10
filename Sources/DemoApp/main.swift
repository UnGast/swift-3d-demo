import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import CustomGraphicsMath
import GL

public class ThreeDGameApp: VisualApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow> {

    private var window: Window

    private let scene = Scene(voxels: [

        Voxel(position: DVec3(0, 0, 0)),
        
        Voxel(position: DVec3(1, 1, 1))
        
    ], camera: Camera(position: DVec3(0, 0, 0)))

    private let renderer: GLSceneRenderer

    public init() {

        let system = try! System()

        renderer = GLSceneRenderer(scene: scene)

        window = try! Window(background: .Grey, size: DSize2(800, 800))

        super.init(system: system)

        renderer.setup()

        _ = system.onFrame(frame)
    }

    private func frame(_ deltaTime: Int) {

        if system.keyStates[.ArrowUp] {

            scene.camera.position.z += 1
        }

        if system.keyStates[.ArrowDown] {

            scene.camera.position.z -= 1
        }
        
        if system.keyStates[.ArrowLeft] {

            scene.camera.position.x += 1
        }

        if system.keyStates[.ArrowRight] {

            scene.camera.position.x -= 1
        }

        window.makeCurrent()

        glClearColor(0.6, 0.3, 0.2, 1.0)

        glClear(GLMap.COLOR_BUFFER_BIT | GLMap.DEPTH_BUFFER_BIT)

        glEnable(GLMap.BLEND)

        glViewport(0, 0, GLMap.Size(window.drawableSize.width), GLMap.Size(window.drawableSize.height))

        renderer.render()

        window.updateContent()
    }
}

let app = ThreeDGameApp()

do {

    try app.start()

} catch {

    print("Error in app.")
}