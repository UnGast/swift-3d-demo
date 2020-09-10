extension String.StringInterpolation {

    mutating func appendInterpolation(_ value: Double, format: String) {

        appendLiteral(String(format: format, value))
    }
}