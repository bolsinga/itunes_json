//
//  Launch.swift
//
//  Copied from https://developer.apple.com/forums/thread/690310
//  Added the option to suppress the standardError.
//  Re-written using Swift Concurrency GroupTasks and Continuations.
//

import Foundation

private func posixErr(_ error: Int32) -> Error {
  NSError(domain: NSPOSIXErrorDomain, code: Int(error), userInfo: nil)
}

extension DispatchIO {
  fileprivate convenience init(readingPipe: Pipe, queue: DispatchQueue) {
    self.init(
      type: .stream, fileDescriptor: readingPipe.fileHandleForReading.fileDescriptor, queue: queue
    ) { _ in
      // `FileHandle` will automatically close the underlying file
      // descriptor when you release the last reference to it.  By holding
      // on to `readingPipe` until here, we ensure that doesn’t happen. And
      // as we have to hold a reference anyway, we might as well close it
      // explicitly.
      try! readingPipe.fileHandleForReading.close()
    }
  }

  fileprivate convenience init(writingPipe: Pipe, queue: DispatchQueue) {
    self.init(
      type: .stream, fileDescriptor: writingPipe.fileHandleForWriting.fileDescriptor, queue: queue
    ) { _ in
      // `FileHandle` will automatically close the underlying file
      // descriptor when you release the last reference to it.  By holding
      // on to `readingPipe` until here, we ensure that doesn’t happen. And
      // as we have to hold a reference anyway, we might as well close it
      // explicitly.
      try! writingPipe.fileHandleForWriting.close()
    }
  }
}

private func write(
  dispatchIO: DispatchIO, data: Data, queue: DispatchQueue,
  completionHandler: @escaping (Error?) -> Void
) {
  let inputDD = data.withUnsafeBytes { DispatchData(bytes: $0) }
  dispatchIO.write(offset: 0, data: inputDD, queue: queue) { isDone, _, err in
    if isDone || err != 0 {
      dispatchIO.close()
      var error: Error?
      if err != 0 { error = posixErr(err) }
      completionHandler(error)
    }
  }
}

private func write(dispatchIO: DispatchIO, data: Data, queue: DispatchQueue) async throws {
  let _: Bool = try await withCheckedThrowingContinuation { continuation in
    write(dispatchIO: dispatchIO, data: data, queue: queue) { error in
      if let error {
        continuation.resume(throwing: error)
      } else {
        continuation.resume(returning: true)
      }
    }
  }
}

private func read(
  dispatchIO: DispatchIO, queue: DispatchQueue, dataHandler: @escaping (DispatchData) -> Void,
  completionHandler: @escaping (Error?) -> Void
) {
  dispatchIO.read(offset: 0, length: .max, queue: queue) { isDone, chunkQ, err in
    dataHandler(chunkQ ?? .empty)
    if isDone || err != 0 {
      dispatchIO.close()
      var error: Error?
      if err != 0 { error = posixErr(err) }
      completionHandler(error)
    }
  }
}

private func read(dispatchIO: DispatchIO, queue: DispatchQueue) async throws -> Data {
  try await withCheckedThrowingContinuation { continuation in
    var data = Data()
    read(dispatchIO: dispatchIO, queue: queue) {
      data.append(contentsOf: $0)
    } completionHandler: { error in
      if let error {
        continuation.resume(throwing: error)
      } else {
        continuation.resume(returning: data)
      }
    }
  }
}

extension Process {
  func waitUntilTerminated() async -> Int32 {
    await withCheckedContinuation { continuation in
      self.terminationHandler = { process in
        continuation.resume(returning: process.terminationStatus)
      }
    }
  }
}

/// Runs the specified tool as a child process, supplying `stdin` and capturing `stdout`.
///
/// - Parameters:
///   - tool: The tool to run.
///   - arguments: The command-line arguments to pass to that tool; defaults to the empty array.
///   - input: Data to pass to the tool’s `stdin`; defaults to empty.
///   - suppressStandardErr: boolean to suppress the tool's `stderr`; defaults to false.
func launch(
  tool: URL, arguments: [String] = [], input: Data = Data(), suppressStandardErr: Bool = false
) async throws -> (Int32, Data) {
  let inputPipe = Pipe()
  let outputPipe = Pipe()

  let proc = Process()
  proc.executableURL = tool
  proc.arguments = arguments
  proc.standardInput = inputPipe
  proc.standardOutput = outputPipe
  if suppressStandardErr { proc.standardError = nil }

  // All three tasks must return, and each returns one of these.
  // This enum is used with associated types since it seemed the
  // simplest way to have the tasks return different results with
  // a single type.
  enum LaunchResult {
    case terminate(Int32)
    case write
    case read(Data)
  }

  // If you write to a pipe whose remote end has closed, the OS raises a
  // `SIGPIPE` signal whose default disposition is to terminate your
  // process.  Helpful!  `F_SETNOSIGPIPE` disables that feature, causing
  // the write to fail with `EPIPE` instead.

  let fcntlResult = fcntl(inputPipe.fileHandleForWriting.fileDescriptor, F_SETNOSIGPIPE, 1)
  guard fcntlResult >= 0 else { throw posixErr(errno) }

  return try await withThrowingTaskGroup(of: LaunchResult.self, returning: (Int32, Data).self) {
    group in

    // These group tasks will throw any errors that result from launching and tracking the
    // subprocess. The return value from the tool is return from the task group.
    group.addTask {
      try proc.run()
      return .terminate(await proc.waitUntilTerminated())
    }

    group.addTask {
      let queue = DispatchQueue.global()
      let writeIO = DispatchIO(writingPipe: inputPipe, queue: queue)
      try await write(dispatchIO: writeIO, data: input, queue: queue)
      return .write
    }

    group.addTask {
      let queue = DispatchQueue.global()
      let readIO = DispatchIO(readingPipe: outputPipe, queue: queue)
      let data = try await read(dispatchIO: readIO, queue: queue)
      return .read(data)
    }

    // This is the return value from the tool, and its standard out as Data.
    var result: (status: Int32, data: Data) = (0, Data())

    // Build the return value from the tasks' results.
    for try await launchResult in group {
      switch launchResult {
      case .terminate(let status):
        result.status = status
      case .write:
        break
      case .read(let data):
        result.data = data
      }
    }

    return result
  }
}
