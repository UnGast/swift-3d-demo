import CustomGraphicsMath

public class WorldGenerator {

    public var size: DSize3 = .zero

    public init() {

    }

    public func generate() -> World {

        let floorGenerator = FloorGenerator(bounds: DBoundingBox(

            min: -size / 2,

            max: size / 2
        ))

        let voxels = floorGenerator.generate()

        let world = World(voxels: voxels)

        return world
    }
}