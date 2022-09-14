import Foundation
import GraphViz
import SwiftMicrograd

extension Graph {
    public func render(
        using layout: LayoutAlgorithm,
        to format: Format,
        with options: Renderer.Options = []
    ) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            self.render(using: layout, to: format, with: options) { result in
                continuation.resume(with: result)
            }
        }
    }
}

extension Value {
    public func graph() -> Graph where T: CVarArg {
        return SwiftMicrogradGraph.graph(self)
    }
}

internal struct GraphVizNode<T: FloatingPoint>: Hashable {
    internal var node: Node
    internal var value: Value<T>
}

internal struct GraphVizEdge<T: FloatingPoint>: Hashable {
    internal var from: GraphVizNode<T>
    internal var to: GraphVizNode<T>
}

internal func build<T: FloatingPoint & CVarArg>(
    value: Value<T>,
    nodes: inout Set<GraphVizNode<T>>,
    edges: inout Set<GraphVizEdge<T>>
) {
    var node = Node("\(value.objectIdentifier)")
    node.label = value.description
    node.shape = .rectangle
    let graphNode = GraphVizNode(node: node, value: value)
    guard !nodes.contains(graphNode) else {
        return
    }
    nodes.insert(graphNode)
    for child in value.previous {
        var childNode = Node("\(child.objectIdentifier)")
        childNode.label = child.description
        node.shape = .box
        let graphChildNode = GraphVizNode(node: childNode, value: child)
        edges.insert(GraphVizEdge(from: graphChildNode, to: graphNode))
        build(value: child, nodes: &nodes, edges: &edges)
    }
}

internal func trace<T: FloatingPoint & CVarArg>(_ root: Value<T>) -> (nodes: Set<GraphVizNode<T>>, edges: Set<GraphVizEdge<T>>) {
    var nodes = Set<GraphVizNode<T>>()
    var edges = Set<GraphVizEdge<T>>()
    build(value: root, nodes: &nodes, edges: &edges)
    return (nodes: nodes, edges: edges)
}

internal func graph<T: FloatingPoint & CVarArg>(_ root: Value<T>) -> Graph {
    let data = trace(root)
    var graph = Graph(directed: true)
    graph.rankDirection = .leftToRight
    for graphNode in data.nodes {
        graph.append(graphNode.node)
        if let operatorName = graphNode.value.attributes.operatorName {
            var newNode = Node("\(graphNode.value.objectIdentifier)-\(operatorName)")
            newNode.label = operatorName
            graph.append(newNode)
            graph.append(Edge(from: newNode, to: graphNode.node))
        }
    }
    for edge in data.edges {
        let toNode: Node
        if let operatorName = edge.to.value.attributes.operatorName {
            toNode = Node("\(edge.to.node.id)-\(operatorName)")
        } else {
            toNode = edge.to.node
        }
        let grahpEdge = Edge(
            from: edge.from.node,
            to: toNode
        )
        graph.append(grahpEdge)
    }
    return graph
}
