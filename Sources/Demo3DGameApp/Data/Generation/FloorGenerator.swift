import Foundation
import CustomGraphicsMath

public struct FloorGenerator: VoxelGenerator {

    public let bounds: DBoundingBox

    public func generate() -> [Voxel] {

        var voxels = [Voxel]()

        for x in Int(bounds.min.x)..<Int(bounds.max.x) {

            for y in Int(bounds.min.y)..<Int(bounds.max.y) {

                for z in Int(bounds.min.z)..<Int(bounds.max.z) {

                    voxels.append(Voxel(position: IVec3(x, y, z).asType(Double.init)))
                }
            }
        }

        return voxels
    }
}