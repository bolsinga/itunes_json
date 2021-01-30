import Foundation
import iTunesLibrary
import func Darwin.fputs
import var Darwin.stderr

extension Track {
    init(_ mediaItem: ITLibMediaItem) {
        let artist = mediaItem.artist
        let album = mediaItem.album

        if let name = album.title, name.count > 0 {
            self.album = name
        }
        if let name = album.albumArtist {
            self.albumArtist = name
        }
        if album.rating != 0 {
            self.albumRating = album.rating
        }
        if album.isRatingComputed {
            self.albumRatingComputed = mediaItem.isRatingComputed
        }
        if let name = artist?.name {
            self.artist = name
        }
    //    self.ARTWORK_COUNT = mediaItem.ARTWORK_COUNT
        if mediaItem.bitrate != 0 {
            self.bitRate = mediaItem.bitrate
        }
        if mediaItem.beatsPerMinute != 0 {
            self.bPM = mediaItem.beatsPerMinute
        }
        if let comments = mediaItem.comments {
            self.comments = comments
        }
        if album.isCompilation {
            self.compilation = album.isCompilation
        }
        if mediaItem.composer.count > 0 {
            self.composer = mediaItem.composer
        }
        if let contentRating = mediaItem.contentRating {
            self.contentRating = contentRating
        }
        if let date = mediaItem.addedDate {
            self.dateAdded = date
        }
        if let date = mediaItem.modifiedDate {
            self.dateModified = date
        }
        if mediaItem.isUserDisabled {
            self.disabled = mediaItem.isUserDisabled
        }
        if album.discCount != 0 {
            self.discCount = album.discCount
        }
        if album.discNumber != 0 {
            self.discNumber = album.discNumber
        }
        if mediaItem.lyricsContentRating == .explicit {
            self.explicit = true
        }
        if mediaItem.genre.count > 0 {
            self.genre = mediaItem.genre
        }
        if let grouping = mediaItem.grouping {
            self.grouping = grouping
        }
        if mediaItem.isVideo {
            self.hasVideo = true
        }
        if let kind = mediaItem.kind {
            self.kind = kind
        }
        if let location = mediaItem.location {
            if location.isFileURL && !FileManager.default.fileExists(atPath: location.path) {
                print("Non-existant media file: \(location)", to: &standardError)
            }
            self.location = location.absoluteString
        }
        if mediaItem.mediaKind == .kindMovie {
            self.movie = true
        } else if mediaItem.mediaKind == .kindMusicVideo {
            self.musicVideo = true
        } else if mediaItem.mediaKind == .kindPodcast {
            self.podcast = true
        } else if mediaItem.mediaKind == .kindTVShow {
            self.tVShow = true
        }
        self.name = mediaItem.title
        if album.isGapless {
            self.partOfGaplessAlbum = album.isGapless
        }
        self.persistentID = mediaItem.persistentID.uintValue // Hex?
        self.playCount = mediaItem.playCount
        if let date = mediaItem.lastPlayedDate {
            self.playDateUTC = date
        }
        if mediaItem.isDRMProtected {
            self.protected = mediaItem.isDRMProtected
        }
        if mediaItem.isPurchased {
            self.purchased = mediaItem.isPurchased
        }
        if mediaItem.rating != 0 {
            self.rating = mediaItem.rating
        }
        if mediaItem.isRatingComputed {
            self.ratingComputed = mediaItem.isRatingComputed
        }
        if let date = mediaItem.releaseDate {
            self.releaseDate = date
        }
        self.sampleRate = mediaItem.sampleRate
        self.size = mediaItem.fileSize
        if mediaItem.skipCount != 0 {
            self.skipCount = mediaItem.skipCount
        }
        if let date = mediaItem.skipDate {
            self.skipDate = date
        }
        if let name = album.sortTitle {
            self.sortAlbum = name
        }
        if let name = album.sortAlbumArtist {
            self.sortAlbumArtist = name
        }
        if let name = artist?.sortName {
            self.sortArtist = name
        }
        if let sortComposer = mediaItem.sortComposer {
            self.sortComposer = sortComposer
        }
        if let sortName = mediaItem.sortTitle {
            self.sortName = sortName
        }
        self.totalTime = mediaItem.totalTime
        if album.trackCount != 0 {
            self.trackCount = album.trackCount
        }
        self.trackNumber = mediaItem.trackNumber
        switch mediaItem.locationType {
        case .file:
            self.trackType = "File"
        case .URL:
            self.trackType = "URL"
        case .remote:
            self.trackType = "Remote"
        case .unknown:
            break
        @unknown default:
            break
        }
        if mediaItem.playStatus == .unplayed {
            self.unplayed = true
        }
        self.year = mediaItem.year

        if let videoInfo = mediaItem.videoInfo {
            if let episode = videoInfo.episode {
                self.episode = episode
            }
            if videoInfo.episodeOrder != 0 {
                self.episodeOrder = videoInfo.episodeOrder
            }
            if videoInfo.isHD {
                self.hD = videoInfo.isHD
            }
            if videoInfo.season != 0 {
                self.season = videoInfo.season
            }
            if let series = videoInfo.series {
                self.series = series
            }
            if let sortSeries = videoInfo.sortSeries {
                self.sortSeries = sortSeries
            }
            if videoInfo.videoHeight != 0 {
                self.videoHeight = videoInfo.videoHeight
            }
            if videoInfo.videoWidth != 0 {
                self.videoWidth = videoInfo.videoWidth
            }
        }
    }
}

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

let itunesLib: ITLibrary?
do {
    itunesLib = try ITLibrary(apiVersion: "1.0")
} catch {
    print("Cannot open the library: \(error).", to: &standardError)
    exit(1)
}

guard let itunes = itunesLib else {
    print("No library", to: &standardError)
    exit(1)
}

var tracks = itunes.allMediaItems.map{ Track($0) }

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
