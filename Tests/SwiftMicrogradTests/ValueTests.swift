@testable import SwiftMicrograd
import XCTest

internal final class ValueTests: XCTestCase {
    internal func testOperators() {
        let a1 = Value(-4.0)
        let b1 = Value(10.0)
        let v1 = a1 + b1
        XCTAssertEqual(v1.value, 6.0, accuracy: Constants.accuracy)
        v1.backward()
        XCTAssertEqual(v1.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(a1.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(b1.gradient, 1.0, accuracy: Constants.accuracy)

        let a2 = Value(-4.0)
        let b2 = Value(10.0)
        let v2 = a2 - b2
        XCTAssertEqual(v2.value, -14.0, accuracy: Constants.accuracy)
        v2.backward()
        XCTAssertEqual(v2.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(a2.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(b2.gradient, -1.0, accuracy: Constants.accuracy)

        let a3 = Value(-4.0)
        let b3 = Value(10.0)
        let v3 = a3 * b3
        XCTAssertEqual(v3.value, -40.0, accuracy: Constants.accuracy)
        v3.backward()
        XCTAssertEqual(v3.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(a3.gradient, 10.0, accuracy: Constants.accuracy)
        XCTAssertEqual(b3.gradient, -4.0, accuracy: Constants.accuracy)

        let a4 = Value(-4.0)
        let b4 = Value(10.0)
        let v4 = a4 / b4
        XCTAssertEqual(v4.value, -0.4, accuracy: Constants.accuracy)
        v4.backward()
        XCTAssertEqual(v4.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(a4.gradient, 0.1, accuracy: Constants.accuracy)
        XCTAssertEqual(b4.gradient, 0.04, accuracy: Constants.accuracy)

        let a5 = Value(-4.0)
        let v5 = a5.pow(3)
        XCTAssertEqual(v5.value, -64.0, accuracy: Constants.accuracy)
        v5.backward()
        XCTAssertEqual(v5.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(a5.gradient, 48.0, accuracy: Constants.accuracy)

        let a6 = Value(4.0)
        let v6 = a6.relu()
        XCTAssertEqual(v6.value, 4.0, accuracy: Constants.accuracy)
        v6.backward()
        XCTAssertEqual(v6.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(a6.gradient, 1.0, accuracy: Constants.accuracy)
    }

    internal func testOperators2() {
        var a1 = Value(-4.0)
        let t1 = a1
        let b1 = Value(10.0)
        a1 += b1
        XCTAssertEqual(a1.value, 6.0, accuracy: Constants.accuracy)
        a1.backward()
        XCTAssertEqual(a1.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(t1.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(b1.gradient, 1.0, accuracy: Constants.accuracy)

        var a2 = Value(-4.0)
        let t2 = a2
        let b2 = Value(10.0)
        a2 -= b2
        XCTAssertEqual(a2.value, -14.0, accuracy: Constants.accuracy)
        a2.backward()
        XCTAssertEqual(a2.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(t2.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(b2.gradient, -1.0, accuracy: Constants.accuracy)

        var a3 = Value(-4.0)
        let t3 = a3
        let b3 = Value(10.0)
        a3 *= b3
        XCTAssertEqual(a3.value, -40.0, accuracy: Constants.accuracy)
        a3.backward()
        XCTAssertEqual(a3.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(t3.gradient, 10.0, accuracy: Constants.accuracy)
        XCTAssertEqual(b3.gradient, -4.0, accuracy: Constants.accuracy)

        var a4 = Value(-4.0)
        let t4 = a4
        let b4 = Value(10.0)
        a4 /= b4
        XCTAssertEqual(a4.value, -0.4, accuracy: Constants.accuracy)
        a4.backward()
        XCTAssertEqual(a4.gradient, 1.0, accuracy: Constants.accuracy)
        XCTAssertEqual(t4.gradient, 0.1, accuracy: Constants.accuracy)
        XCTAssertEqual(b4.gradient, 0.04, accuracy: Constants.accuracy)
    }

    internal func testOperators3() {
        let x = Value(-4)
        let z = 2 * x + 2 + x
        let q = z.relu() + z * x
        let h = (z * z).relu()
        let y = h + q + q * x
        y.backward()

        XCTAssertEqual(y.value, -20, accuracy: Constants.accuracy)
        XCTAssertEqual(x.gradient, 46, accuracy: Constants.accuracy)
    }

    internal func testOperators4() {
        let a = Value(-4.0)
        let b = Value(2.0)
        var c = a + b
        var d = (a * b) + b.pow(3)
        c = c + c + 1
        c = c + 1 + c + -a
        d = d + d * 2 + (b + a).relu()
        d = d + 3 * d + (b - a).relu()
        let e = c - d
        let f = e.pow(2)
        var g = f / 2.0
        g = g + (10.0 / f)
        g.backward()

        XCTAssertEqual(g.value, 24.704081, accuracy: Constants.accuracy)
        XCTAssertEqual(a.gradient, 138.833819, accuracy: Constants.accuracy)
        XCTAssertEqual(b.gradient, 645.577259, accuracy: Constants.accuracy)
    }

    internal func testOperators5() {
        let a = Value(-4.0)
        let b = Value(2.0)
        let c = a + b
        let d = (a * b) + c.pow(3)
        let e = (-d).relu()
        e.backward()

        XCTAssertEqual(e.value, 16.0, accuracy: Constants.accuracy)
        XCTAssertEqual(a.gradient, -14.0, accuracy: Constants.accuracy)
        XCTAssertEqual(b.gradient, -8.0, accuracy: Constants.accuracy)
    }

    internal func testSort() {
        let a = Value(-4.0)
        a.attributes.label = "a"
        let b = Value(2.0)
        b.attributes.label = "b"
        let c = a * b
        c.attributes.label = "c"
        let d = c + b.pow(3)
        d.attributes.label = "d"
        let sorted = d.sort()
        let sortedLabels = sorted.compactMap(\.attributes.label)

        XCTAssertTrue(
            sortedLabels == ["a", "b", "c", "d"] ||
                sortedLabels == ["b", "a", "c", "d"]
        )
    }
}
