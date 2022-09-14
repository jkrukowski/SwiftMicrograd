import Foundation

// MARK: MultilayerPerceptron

public final class MultilayerPerceptron<T: FloatingPoint> {
    public var layers: [Layer<T>]

    public init(
        inputCount: Int,
        outputs: [Int],
        initialValue: @autoclosure @escaping () -> T
    ) {
        let inputs = [inputCount] + outputs
        var layers = [Layer<T>]()
        for index in 0 ..< outputs.count {
            layers.append(
                Layer(
                    inputCount: inputs[index],
                    outputCount: inputs[index + 1],
                    isNonLinear: index < outputs.count - 1,
                    initialValue: initialValue()
                )
            )
        }
        self.layers = layers
    }

    public func callAsFunction(_ x: [Float]) -> [Value<T>] where T == Float {
        var result = x.map { Value($0) }
        for layer in layers {
            result = layer(result)
        }
        return result
    }

    public func callAsFunction(_ x: [Double]) -> [Value<T>] where T == Double {
        var result = x.map { Value($0) }
        for layer in layers {
            result = layer(result)
        }
        return result
    }
}

// MARK: MultilayerPerceptron > Module

extension MultilayerPerceptron: Module {
    public var parameters: [Value<T>] {
        return layers.flatMap(\.parameters)
    }
}

// MARK: MultilayerPerceptron > CustomStringConvertible

extension MultilayerPerceptron: CustomStringConvertible {
    public var description: String {
        return """
        <MultilayerPerceptron:
            \(layers)
        >
        """
    }
}
