import Foundation
import Numerics

// MARK: Value

public final class Value<T: FloatingPoint> {
    public var value: T
    public var gradient: T
    public var attributes: Value.Attributes
    public private(set) var previous: Set<Value<T>>
    private var backwardStep: () -> Void

    public init(
        _ value: T,
        previous: Value...
    ) {
        self.value = value
        self.previous = Set(previous)
        gradient = T.zero
        backwardStep = {}
        attributes = Value.Attributes()
    }

    public func backward() {
        let sorted = sort()
        gradient = T(1)
        for node in sorted.reversed() {
            node.backwardStep()
        }
    }

    public func sort() -> [Value<T>] {
        var visited = Set<Value<T>>()
        var result = [Value<T>]()
        Self.sortHelper(
            node: self,
            visited: &visited,
            result: &result
        )
        return result
    }

    private static func sortHelper(
        node: Value<T>,
        visited: inout Set<Value<T>>,
        result: inout [Value<T>]
    ) {
        guard !visited.contains(node) else {
            return
        }
        visited.insert(node)
        for child in node.previous {
            sortHelper(
                node: child,
                visited: &visited,
                result: &result
            )
        }
        result.append(node)
    }
}

// MARK: Value > Equatable

extension Value: Equatable {
    public static func == (lhs: Value, rhs: Value) -> Bool {
        return lhs === rhs
    }
}

// MARK: Value > Hashable

extension Value: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(objectIdentifier)
    }

    public var objectIdentifier: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

// MARK: Value > CustomStringConvertible

extension Value: CustomStringConvertible where T: CVarArg {
    public var description: String {
        let value = String(format: "%.4f", value)
        let gradient = String(format: "%.4f", gradient)
        return "<Value: \(value) | \(gradient)>"
    }
}

// MARK: Value > Operation > Add

extension Value {
    public static func + (lhs: Value, rhs: Value) -> Value {
        let out = Value(
            lhs.value + rhs.value,
            previous: lhs, rhs
        )
        out.attributes.operatorName = "add"
        out.backwardStep = { [unowned out, unowned lhs, unowned rhs] in
            lhs.gradient += out.gradient
            rhs.gradient += out.gradient
        }
        return out
    }

    public static func + (lhs: Value, rhs: T) -> Value {
        return lhs + Value(rhs)
    }

    public static func + (lhs: T, rhs: Value) -> Value {
        return Value(lhs) + rhs
    }

    public static func += (lhs: inout Value, rhs: Value) {
        lhs = lhs + rhs
    }
}

// MARK: Value > Operation > Sub

extension Value {
    public static func - (lhs: Value, rhs: Value) -> Value {
        let out = lhs + -rhs
        out.attributes.operatorName = "sub"
        return out
    }

    public static func - (lhs: Value, rhs: T) -> Value {
        return lhs - Value(rhs)
    }

    public static func - (lhs: T, rhs: Value) -> Value {
        return Value(lhs) - rhs
    }

    public static prefix func - (rhs: Value) -> Value {
        return -1 * rhs
    }

    public static func -= (lhs: inout Value, rhs: Value) {
        lhs = lhs - rhs
    }
}

// MARK: Value > Operation > Mul

extension Value {
    public static func * (lhs: Value, rhs: Value) -> Value {
        let out = Value(
            lhs.value * rhs.value,
            previous: lhs, rhs
        )
        out.attributes.operatorName = "mul"
        out.backwardStep = { [unowned out, unowned lhs, unowned rhs] in
            lhs.gradient += rhs.value * out.gradient
            rhs.gradient += lhs.value * out.gradient
        }
        return out
    }

    public static func * (lhs: Value, rhs: T) -> Value {
        return lhs * Value(rhs)
    }

    public static func * (lhs: T, rhs: Value) -> Value {
        return Value(lhs) * rhs
    }

    public static func *= (lhs: inout Value, rhs: Value) {
        lhs = lhs * rhs
    }
}

// MARK: Value > Operation > Div

extension Value {
    public static func / (lhs: Value, rhs: Value) -> Value where T == Float {
        let out = lhs * rhs.pow(-1)
        out.attributes.operatorName = "div"
        return out
    }

    public static func / (lhs: Value, rhs: Value) -> Value where T == Double {
        let out = lhs * rhs.pow(-1)
        out.attributes.operatorName = "div"
        return out
    }

    public static func / (lhs: Value, rhs: T) -> Value where T == Float {
        return lhs / Value(rhs)
    }

    public static func / (lhs: Value, rhs: T) -> Value where T == Double {
        return lhs / Value(rhs)
    }

    public static func / (lhs: T, rhs: Value) -> Value where T == Float {
        return Value(lhs) / rhs
    }

    public static func / (lhs: T, rhs: Value) -> Value where T == Double {
        return Value(lhs) / rhs
    }

    public static func /= (lhs: inout Value, rhs: Value) where T == Float {
        lhs = lhs / rhs
    }

    public static func /= (lhs: inout Value, rhs: Value) where T == Double {
        lhs = lhs / rhs
    }
}

// MARK: Value > Operation > Pow

extension Value {
    public func pow(_ exponent: Int) -> Value where T == Float {
        pow(exponent, computePow: Float.pow)
    }

    public func pow(_ exponent: Int) -> Value where T == Double {
        pow(exponent, computePow: Double.pow)
    }

    private func pow(_ exponent: Int, computePow: @escaping (T, Int) -> T) -> Value {
        let newValue = computePow(value, exponent)
        let out = Value(newValue, previous: self)
        out.attributes.operatorName = "pow"
        out.backwardStep = { [unowned out, unowned self] in
            self.gradient += T(exponent) * computePow(self.value, exponent - 1) * out.gradient
        }
        return out
    }
}

// MARK: Value > Operation > Tanh

extension Value {
    public func tanh() -> Value where T == Float {
        tanh(computeTanh: Float.tanh, computePow: Float.pow)
    }

    public func tanh() -> Value where T == Double {
        tanh(computeTanh: Double.tanh, computePow: Double.pow)
    }

    private func tanh(computeTanh: (T) -> T, computePow: @escaping (T, Int) -> T) -> Value {
        let newValue = computeTanh(value)
        let out = Value(newValue, previous: self)
        out.attributes.operatorName = "tanh"
        out.backwardStep = { [unowned out, unowned self] in
            self.gradient += (1 - computePow(newValue, 2)) * out.gradient
        }
        return out
    }
}

// MARK: Value > Operation > Relu

extension Value {
    public func relu() -> Value {
        let out = Value(value < 0 ? 0 : value, previous: self)
        out.attributes.operatorName = "relu"
        out.backwardStep = { [unowned out, unowned self] in
            self.gradient += out.value > 0 ? out.gradient : T.zero
        }
        return out
    }
}

// MARK: Value > Attributes

extension Value {
    public struct Attributes {
        public var operatorName: String?
        public var label: String?

        public init(operatorName: String? = nil, label: String? = nil) {
            self.operatorName = operatorName
            self.label = label
        }
    }
}
