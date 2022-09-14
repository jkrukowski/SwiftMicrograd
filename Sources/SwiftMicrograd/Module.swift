import Foundation

// MARK: Module

public protocol Module {
    associatedtype Element: FloatingPoint

    var parameters: [Value<Element>] { get }

    func zeroGradient()
}

extension Module {
    public func zeroGradient() {
        for param in parameters {
            param.gradient = Element.zero
        }
    }
}
