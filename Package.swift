import Foundation
import PackageDescription

// Copy the script into `main.swift` to build a command line tool
let scriptURL = URL(fileURLWithPath: "Sources/Relations.swift")
let scriptData = try Data(contentsOf: scriptURL)

let mainURL = URL(fileURLWithPath: "Sources/main.swift")
try scriptData.write(to: mainURL)

let package = Package(
    name: "Relations",
    dependencies: [
        .Package(url: "git@github.com:jpsim/SourceKitten.git", majorVersion: 0, minor: 17),
        .Package(url: "git@github.com:kylef/Commander.git", majorVersion: 0, minor: 6),
        .Package(url: "git@github.com:JohnSundell/Files.git", majorVersion: 1, minor: 7),
        .Package(url: "git@github.com:interstateone/Graph.git", majorVersion: 1)
    ],
    exclude: ["Sources/Relations.swift"]
)
