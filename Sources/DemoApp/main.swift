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
    }

    private func buildGUI() -> Root {

        Root(rootWidget: Background(fill: Color(50, 70, 80, 200)) { [unowned self] in

            Padding(all: 32) {

                TextConfigProvider(fontSize: 24, fontWeight: .Bold, color: .White) {

                    Column(spacing: 16) {
                        
                        Row {

                            Text("Position:")
                            
                            ObservingBuilder($cameraPositionText) {
                                
                                Text(cameraPositionText)
                            }
                        }

                        for voxel in scene.voxels {

                            Text("Voxel at x: \(voxel.position.x) y: \(voxel.position.y) z: \(voxel.position.z)")
                        }
                    }
                }
            }
        })
    }

    private func updateGUIBounds() {

        guiRoot.bounds.size = DSize2(window.size.width * 0.3, window.size.height)

        guiRoot.bounds.min = DVec2(window.size.width * 0.7, 0)
    }

    private func updateGUIContent() {

        cameraPositionText = """
        x: \(scene.camera.position.x, format: "%.2f") y: \(scene.camera.position.y, format: "%.2f") z: \(scene.camera.position.z, format: "%.2f")
        """
    }

    private func frame(_ deltaTime: Int) {

        let timeStep = Double(deltaTime) / 1000

        if system.keyStates[.ArrowUp] {

            scene.camera.position.z += 1 * timeStep
        }

        if system.keyStates[.ArrowDown] {

            scene.camera.position.z -= 1 * timeStep
        }
        
        if system.keyStates[.ArrowLeft] {

            scene.camera.position.x += 1 * timeStep
        }

        if system.keyStates[.ArrowRight] {

            scene.camera.position.x -= 1 * timeStep
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