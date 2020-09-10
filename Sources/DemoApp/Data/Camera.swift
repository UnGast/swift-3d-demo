import CustomGraphicsMath

public struct Camera {

    public var position: DVec3

    public var fov: Double

    public var pitch: Double = 0

    public var yaw: Double = 0

    public var direction: DVec3 {

        get {

            DVec3(x: tan(yaw), y: tan(pitch), z: 1).normalized()
        }
    }

    public func getAxes() -> (x: DVec3, y: DVec3, z: DVec3) {

        let z = direction

        let x = z.cross(DVec3(0, 1, 0)).normalized()

        let y = z.cross(x).normalized()

        return (x, y, z)
    }
}