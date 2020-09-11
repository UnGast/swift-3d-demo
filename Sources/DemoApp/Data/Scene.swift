public class Scene {

    public var world: World

    public var camera: Camera

    public init(world: World, camera: Camera) {

        self.world = world

        self.camera = camera
    }
}