import Foundation

// MARK: Layer

public final class Layer<T: FloatingPoint> {
    public var neurons: [Neuron<T>]

    public init(
        inputCount: Int,
        outputCount: Int,
        isNonLinear: Bool,
        initialValue: @autoclosure @escaping () -> T
    ) {
        neurons = (0 ..< outputCount).map { _ in
            Neuron(
                inputCount: inputCount,
                isNonLinear: isNonLinear,
                initialValue: initialValue()
            )
        }
    }

    public func callAsFunction(_ x: [Value<T>]) -> [Value<T>] where T == Float {
        return neurons.map { $0(x) }
    }

    public func callAsFunction(_ x: [Value<T>]) -> [Value<T>] where T == Double {
        return neurons.map { $0(x) }
    }
}

// MARK: Layer > Module

extension Layer: Module {
    public var parameters: [Value<T>] {
        return neurons.flatMap(\.parameters)
    }
}

// MARK: Layer > CustomStringConvertible

extension Layer: CustomStringConvertible {
    public var description: String {
        return """
        <Layer:
            \(neurons)
        >
        """
    }
}
