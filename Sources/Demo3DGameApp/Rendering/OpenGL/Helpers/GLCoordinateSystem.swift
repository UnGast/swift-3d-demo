import CustomGraphicsMath

public struct GLCoordinateSystem {

    public static func getPredictableAxisConfig(from forwardDirection: DVec3) -> (forward: DVec3, right: DVec3, up: DVec3) {
        
        var nonZeroComponent = 0

        for i in 0..<forwardDirection.count {

            if forwardDirection[i] != 0 {

                nonZeroComponent = i

                break
            }
        }

        let otherComponents = [0, 1, 2].filter { $0 != nonZeroComponent }

        var rightDirection = DVec3(1, 1, 1)

        rightDirection[nonZeroComponent] = otherComponents.reduce(into: 0, {

            $0 -= forwardDirection[$1]

        }) / forwardDirection[nonZeroComponent]

        rightDirection = rightDirection.normalized()

        let upDirection = rightDirection.cross(forwardDirection).normalized()

        return (forward: forwardDirection, right: rightDirection, up: upDirection)
    }
}