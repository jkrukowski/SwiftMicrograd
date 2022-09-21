import ArgumentParser
import Foundation
import Gnuplot
import Logging
import SwiftMicrograd
import SwiftMicrogradGraph

let logger = Logger(label: "SwiftMicrograd")

struct InputData: Codable {
    var x: [[Double]]
    var y: [Double]
}

extension InputData: CustomStringConvertible {
    var description: String {
        return "<InputData x: \(x.count)x\(x.first?.count ?? 0) y: \(y.count)>"
    }
}

enum MicrogradError: Swift.Error {
    case missingFile
}

extension Collection where Element == Value<Double> {
    func sum() -> Element {
        guard var result = first else {
            return Value(0)
        }
        for element in dropFirst() {
            result += element
        }
        return result
    }
}

extension Collection where Element: FloatingPoint {
    func sum() -> Element {
        reduce(Element.zero, +)
    }
}

func render(inputData: InputData, renderPath: String) throws {
    var series1 = [[Double]]()
    var series2 = [[Double]]()
    for (x, y) in zip(inputData.x, inputData.y) {
        if y > 0 {
            series1.append(x)
        } else {
            series2.append(x)
        }
    }
    let plot = Gnuplot(xys: [series1, series2], titles: ["A", "B"], style: .points)
    try plot(.png(path: renderPath))
}

func loss(data: InputData, model: MultilayerPerceptron<Double>, alpha: Double = 1e-4) -> (loss: Value<Double>, accuracy: Double) {
    let scores = data.x.flatMap { model($0) }
    var losses = [Value<Double>]()
    var accuracies = [Double]()
    for (y, score) in zip(data.y, scores) {
        losses.append((1 + -y * score).relu())
        if (y > 0) == (score.value > 0) {
            accuracies.append(1)
        } else {
            accuracies.append(0)
        }
    }
    let dataLoss = losses.sum() * (1.0 / Double(losses.count))
    let regLoss = alpha * (model.parameters.map { $0 * $0 }).sum()
    let totalLoss = dataLoss + regLoss
    let accuracy = accuracies.sum() / Double(accuracies.count)
    return (totalLoss, accuracy)
}

@main struct SwiftMicrogradCLI: ParsableCommand {
    @Argument(help: "Number of training steps")
    var steps: Int = 100

    @Argument(help: "Input data render path.")
    var renderPath: String?

    mutating func run() throws {
        guard let dataUrl = Bundle.module.url(forResource: "data", withExtension: "json") else {
            throw MicrogradError.missingFile
        }
        let data = try Data(contentsOf: dataUrl)
        let loadedData = try JSONDecoder().decode(InputData.self, from: data)
        let scaledData = InputData(x: loadedData.x, y: loadedData.y.map { 2 * $0 - 1 })
        do {
            if let renderPath {
                try render(inputData: scaledData, renderPath: renderPath)
            }
        } catch {
            logger.info("Error while plotting the data \(error)")
        }

        logger.info("Data: \(scaledData)")

        let model = MultilayerPerceptron<Double>(
            inputCount: 2,
            outputs: [16, 16, 1],
            initialValue: Double.random(in: -1 ... 1)
        )

        for k in 0 ..< steps {
            let (totalLoss, accuracy) = loss(data: scaledData, model: model)
            model.zeroGradient()
            totalLoss.backward()

            let learningRate = 1.0 - 0.9 * Double(k) / 100.0
            for p in model.parameters {
                p.value -= learningRate * p.gradient
            }

            logger.info("Step: \(k) loss: \(totalLoss.value) accuracy: \(accuracy * 100)% learningRate: \(learningRate)")
        }
    }
}
