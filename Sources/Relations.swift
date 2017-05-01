import Foundation
import SourceKittenFramework
import Files
import Commander
import Graph

typealias StructureDictionary = [String: SourceKitRepresentable]

func traverse(structure: StructureDictionary, process: (StructureDictionary) -> Void) {
    process(structure)

    if let substructure = structure["key.substructure"] as? [StructureDictionary] {
        substructure.forEach { traverse(structure: $0, process: process) }
    }
}

command(
    VariadicOption<String>("typePredicate", description: "Predicate for types evaluated with a [String: SourceKitRepresentable]. You must double-escape slashes, which usually means a \\ turns into a \\\\\\\\"),
    VariadicOption<String>("varPredicate", description: "Predicate for properties evaluated with a [String: SourceKitRepresentable]. You must double-escape slashes, which usually means a \\ turns into a \\\\\\\\"),
    Option("output", "graph.dot", flag: Character("o"), description: "Relative path for Graphviz .dot file")
) { typePredicates, varPredicates, relativeOutputPath in
    print("Analyzing relations...\n")

    let currentFolder = FileSystem().currentFolder

    var graph = Graph<String>()
    var lastVertex: Vertex<String>?

    let swiftFiles = currentFolder.makeSubfolderSequence(recursive: true).flatMap { $0.files }.filter { $0.extension == "swift" }
    swiftFiles.forEach { file in
        guard let sourceKittenFile = SourceKittenFramework.File(path: file.path) else { return }
        let structure = Structure(file: sourceKittenFile)

        traverse(structure: structure.dictionary) { structure in
            guard
                let rawKind = structure["key.kind"] as? String,
                let kind = SwiftDeclarationKind(rawValue: rawKind)
            else { return }

            switch kind {
            case .class:
                for typePredicate in typePredicates {
                    let predicate = NSPredicate(format: typePredicate)
                    guard predicate.evaluate(with: structure) else { return }
                }

                guard let name = structure["key.name"] as? String else { return }
                print("Found type \"\(name)\"")
                lastVertex = graph.addVertex(name)
            case .varInstance:
                guard
                    let name = structure["key.name"] as? String,
                    var typeName = structure["key.typename"] as? String
                else { return }

                typeName = typeName.replacingOccurrences(of: "?", with: "")

                for varPredicate in varPredicates {
                    let predicate = NSPredicate(format: varPredicate)
                    guard predicate.evaluate(with: structure) else { return }
                }

                guard let lastVertex = lastVertex else { return }

                print("Found property \"\(name): \(typeName)\"")

                let newVertex = graph.addVertex(typeName)
                graph.addEdge(from: lastVertex, to: newVertex)
            default:
                // There wasn't a Wireframe type in a Wireframe file
                lastVertex = nil
            }
        }
    }

    print("\nWriting graph to \(relativeOutputPath)")
    do {
        let file = try currentFolder.createFile(named: relativeOutputPath)
        try file.write(string: graph.DOTDescription)
    }
    catch {
        print(error)
    }
}.run()

