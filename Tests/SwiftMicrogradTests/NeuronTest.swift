@testable import SwiftMicrograd
import XCTest

internal final class NeuronTests: XCTestCase {
    internal func testIsNotNonLinear() {
        let neuron = Neuron(inputCount: 3, isNonLinear: false, initialValue: 1.0)
        XCTAssertEqual(neuron.parameters.count, 4)

        let result = neuron([Value(1.0), Value(2.0), Value(3.0)])
        XCTAssertEqual(result.value, 6.0, accuracy: Constants.accuracy)
    }

    internal func testIsNonLinear() {
        let neuron = Neuron(inputCount: 3, isNonLinear: true, initialValue: 1.0)
        XCTAssertEqual(neuron.parameters.count, 4)

        let result1 = neuron([Value(1.0), Value(2.0), Value(3.0)])
        XCTAssertEqual(result1.value, 6.0, accuracy: Constants.accuracy)

        let result2 = neuron([Value(-1.0), Value(-2.0), Value(-3.0)])
        XCTAssertEqual(result2.value, 0.0, accuracy: Constants.accuracy)
    }
}
