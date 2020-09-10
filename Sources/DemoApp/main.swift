import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import CustomGraphicsMath
import GL
import WidgetGUI

public class ThreeDGameApp: VisualApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow> {

    private var window: Window

    private let scene = Scene(voxels: [

        Voxel(position: DVec3(0, 0, 5)),
        
        //Voxel(position: DVec3(1, 1, 1))
        
    ], camera: Camera(position: DVec3(0, 0, -10), fov: 90))

    private let sceneRenderer: GLSceneRenderer

    private let canvasRenderer: SDL2OpenGL3NanoVGRenderer

    lazy private var guiRoot: Root = buildGUI()

    @Reference private var metaView: MetaView

    @Observable private var cameraPositionText = ""

    public init() {

        let system = try! System()

        sceneRenderer = GLSceneRenderer(scene: scene)

        window = try! Window(background: .Grey, size: DSize2(800, 800))

        canvasRenderer = SDL2OpenGL3NanoVGRenderer(for: window)

        super.init(system: system)

        sceneRenderer.setup()

        guiRoot.context = WidgetContext(

            window: window,

            getTextBoundsSize: { [unowned self] in canvasRenderer.getTextBoundsSize($0, fontConfig: $1, maxWidth: $2) },

            requestCursor: {

                self.system.requestCursor($0)
            })

        updateGUIBounds()

        _ = system.onFrame(frame)

        _ = window.onResize { [unowned self] _ in updateGUIBounds() }

        _ = window.onMouse(handleMouseEvent)
    }

    private func buildGUI() -> Root {

        Root(rootWidget: MetaView(scene).connect(ref: $metaView))
    }

    private func updateGUIBounds() {

        guiRoot.bounds.size = DSize2(window.size.width * 0.3, window.size.height)

        guiRoot.bounds.min = DVec2(window.size.width * 0.7, 0)
    }

    private func updateGUIContent() {

        metaView.update()
    }

    private func handleMouseEvent(_ event: RawMouseEvent) {

        guiRoot.consume(event)

        if let event = event as? RawMouseMoveEvent {
            
            scene.camera.yaw += event.move.x * 0.01

            scene.camera.pitch += event.move.y * 0.01

            if scene.camera.pitch > 90 {

                scene.camera.pitch = 90
            }

            if scene.camera.pitch < -90 {

                scene.camera.pitch = -90
            }
        }
    }

    private func frame(_ deltaTime: Int) {

        let timeStep = Double(deltaTime) / 1000

        if system.keyStates[.ArrowUp] {

            scene.camera.position += scene.camera.forward * timeStep
        }

        if system.keyStates[.ArrowDown] {

            scene.camera.position -= scene.camera.forward * timeStep
        }
        
        if system.keyStates[.ArrowLeft] {

            scene.camera.position += scene.camera.right * timeStep
        }

        if system.keyStates[.ArrowRight] {

            scene.camera.position -= scene.camera.right * timeStep
        }

        updateGUIContent()

        window.makeCurrent()

        glClearColor(0.6, 0.3, 0.2, 1.0)

        glClear(GLMap.COLOR_BUFFER_BIT | GLMap.DEPTH_BUFFER_BIT)

        glEnable(GLMap.BLEND)

        glEnable(GLMap.DEPTH_TEST)

        glViewport(0, 0, GLMap.Size(window.drawableSize.width), GLMap.Size(window.drawableSize.height))

        sceneRenderer.render()

        canvasRenderer.beginFrame()

        guiRoot.render(with: canvasRenderer)

        canvasRenderer.endFrame()

        window.updateContent()
    }
}

let app = ThreeDGameApp()

do {

    try app.start()

} catch {

    print("Error in app.")
}