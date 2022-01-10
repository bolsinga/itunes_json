import Foundation
import func Darwin.fputs
import var Darwin.stderr

struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding

    init(_ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
}

var fileHandle : FileHandle?
if (CommandLine.arguments.count > 1) {
    let destinationDirectoryPath = CommandLine.arguments[1]
    var destinationURL = URL(fileURLWithPath: destinationDirectoryPath, isDirectory: true)

    let dateFormatter = DateFormatter();
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: Date())

    destinationURL.appendPathComponent("iTunes-\(dateString).json")
    FileManager.default.createFile(atPath: destinationURL.path, contents: nil, attributes: nil)
    fileHandle = try FileHandle(forWritingTo: destinationURL)
}

struct StderrOutputStream: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}
var standardError = StderrOutputStream()

guard let tracks = try? Track.gatherAllTracks() else {
    print("Cannot get tracks from iTunes", to: &standardError)
    exit(1)
}

guard tracks.count > 0 else {
    print("No JSON to record", to: &standardError)
    exit(1)
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
encoder.dateEncodingStrategy = .iso8601

guard let jsonData = try? encoder.encode(tracks) else {
    print("Unable to create JSON for \(tracks)", to: &standardError)
    exit(1)
}

guard let jsonString = String(data: jsonData, encoding: .utf8) else {
    print("Unable to create JSON string for \(tracks)", to: &standardError)
    exit(1)
}

if let outputFileHandle = fileHandle {
    var standardOutput = FileHandlerOutputStream(outputFileHandle)
    print("\(jsonString)", to: &standardOutput)
} else {
    print("\(jsonString)")
}
