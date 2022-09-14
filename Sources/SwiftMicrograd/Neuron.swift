import Foundation

// MARK: Neuron

public final class Neuron<T: FloatingPoint> {
    public var w: [Value<T>]
    public var b: Value<T>
    public var isNonLinear: Bool

    public init(
        inputCount: Int,
        isNonLinear: Bool,
        initialValue: @autoclosure () -> T
    ) {
        w = (0 ..< inputCount).map { _ in Value<T>(initialValue()) }
        b = Value<T>(T.zero)
        self.isNonLinear = isNonLinear
    }

    public func callAsFunction(_ x: [Value<T>]) -> Value<T> where T == Float {
        let result = apply(x)
        return isNonLinear ? result.relu() : result
    }

    public func callAsFunction(_ x: [Value<T>]) -> Value<T> where T == Double {
        let result = apply(x)
        return isNonLinear ? result.relu() : result
    }

    private func apply(_ x: [Value<T>]) -> Value<T> {
        var node = b
        for (iw, ix) in zip(w, x) {
            node += iw * ix
        }
        return node
    }
}

// MARK: Neuron > Module

extension Neuron: Module {
    public var parameters: [Value<T>] {
        return w + [b]
    }
}

// MARK: Neuron > CustomStringConvertible

extension Neuron: CustomStringConvertible {
    public var description: String {
        return """
        <Neuron:
            w: \(w)
            b: \(b)
        >
        """
    }
}
