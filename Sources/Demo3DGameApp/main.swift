import VisualAppBase
import VisualAppBaseImplSDL2OpenGL3NanoVG
import CustomGraphicsMath
import GL
import WidgetGUI

public class ThreeDGameApp: VisualApp<SDL2OpenGL3NanoVGSystem, SDL2OpenGL3NanoVGWindow> {

    private enum ControlTarget {

        case Scene, UI
    }

    private var window: Window

    private let scene: Scene

    private let sceneRenderer: GLSceneRenderer

    private let canvasRenderer: SDL2OpenGL3NanoVGRenderer

    lazy private var guiRoot: Root = buildGUI()

    @Reference private var metaView: MetaView

    @Observable private var cameraPositionText = ""

    private var controlTarget: ControlTarget = .Scene {

        didSet {

            if controlTarget == .UI {

                system.relativeMouseMode = false

            } else if controlTarget == .Scene {

                system.relativeMouseMode = true
            }
        }
    }



    public init() {

        let worldGenerator = WorldGenerator()

        worldGenerator.size = DSize3(10, 2, 10)

        let world = worldGenerator.generate()

        scene = Scene(world: world, camera: Camera(position: DVec3(0, 3, 0), fov: 45))



        let system = try! System()

        system.relativeMouseMode = true

        sceneRenderer = GLSceneRenderer(scene: scene)

        window = try! Window(background: .Grey, size: DSize2(800, 800))

        canvasRenderer = SDL2OpenGL3NanoVGRenderer(for: window)

        super.init(system: system)



        do {

            try sceneRenderer.setup()

        } catch {

            fatalError("Error during setup of SceneRenderer: \(error)")
        }

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

        _ = window.onKey(handleKeyEvent)
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

        if controlTarget == .UI {
            
            guiRoot.consume(event)

        } else if controlTarget == .Scene {

            if let event = event as? RawMouseMoveEvent {
                
                scene.camera.yaw += event.move.x * 0.001

                //scene.camera.yaw = scene.camera.yaw.truncatingRemainder(dividingBy: 2 * Double.pi)

                scene.camera.pitch += event.move.y * 0.001

                if scene.camera.pitch > Double.pi / 2 * 0.9 {

                    scene.camera.pitch = Double.pi / 2 * 0.9
                }

                if scene.camera.pitch < -Double.pi / 2 * 0.9 {

                    scene.camera.pitch = -Double.pi / 2 * 0.9
                }
            }
        }
    }

    private func handleKeyEvent(_ event: KeyEvent) {

        if let event = event as? KeyDownEvent {

            if event.key == .Escape {

                if controlTarget == .Scene {

                    controlTarget = .UI

                } else if controlTarget == .UI {

                    controlTarget = .Scene
                }
            }
        }
    }

    private func frame(_ deltaTime: Int) {

        let timeStep: Double

        if system.keyStates[.LeftShift] {

            timeStep = Double(deltaTime) / 100

        } else {

            timeStep = Double(deltaTime) / 500
        }

        if system.keyStates[.ArrowUp] || system.keyStates[.W] {

            scene.camera.position -= scene.camera.forward * timeStep
        }

        if system.keyStates[.ArrowDown] || system.keyStates[.S] {

            scene.camera.position += scene.camera.forward * timeStep
        }
        
        if system.keyStates[.ArrowLeft] || system.keyStates[.A] {

            scene.camera.position -= scene.camera.right * timeStep
        }

        if system.keyStates[.ArrowRight] || system.keyStates[.D] {

            scene.camera.position += scene.camera.right * timeStep
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