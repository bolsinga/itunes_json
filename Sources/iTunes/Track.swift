//
//  Track.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 7/24/20.
//

import Foundation

struct Track: Codable, Hashable, Sendable {
  var album: String? = nil  // "Album"
  var albumArtist: String? = nil  // "Album Artist"
  var albumRating: Int? = nil  // "Album Rating"
  var albumRatingComputed: Bool? = nil  // "Album Rating Computed"
  var artist: String? = nil  // "Artist"
  //    var artworkCount : UInt? = nil // "Artwork Count"
  var bitRate: Int? = nil  // "Bit Rate"
  var bPM: Int? = nil  // "BPM"
  var comments: String? = nil  // "Comments"
  var compilation: Bool? = nil  // "Compilation"
  var composer: String? = nil  // "Composer"
  var contentRating: String? = nil  // "Content Rating"
  var dateAdded: String? = nil  // "Date Added"
  var dateModified: String? = nil  // "Date Modified"
  var disabled: Bool? = nil  // "Disabled"
  var discCount: Int? = nil  // "Disc Count"
  var discNumber: Int? = nil  // "Disc Number"
  var episode: String? = nil  // "Episode"
  var episodeOrder: Int? = nil  // "Episode Order"
  var explicit: Bool? = nil  // "Explicit"
  var genre: String? = nil  // "Genre"
  var grouping: String? = nil  // "Grouping"
  var hasVideo: Bool? = nil  // "Has Video"
  var hD: Bool? = nil  // "HD"
  var kind: String? = nil  // "Kind"
  var location: String? = nil  // "Location"
  var movie: Bool? = nil  // "Movie"
  var musicVideo: Bool? = nil  // "Music Video"
  var name: String  // "Name"
  var partOfGaplessAlbum: Bool? = nil  // "Part Of Gapless Album"
  var persistentID: UInt  // "Persistent ID"
  var playCount: Int? = nil  // "Play Count"
  var playDateUTC: String? = nil  // "Play Date UTC"
  var podcast: Bool? = nil  // "Podcast"
  var protected: Bool? = nil  // "Protected"
  var purchased: Bool? = nil  // "Purchased"
  var rating: Int? = nil  // "Rating"
  var ratingComputed: Bool? = nil  // "Rating Computed"
  var releaseDate: String? = nil  // "Release Date"
  var sampleRate: Int? = nil  // "Sample Rate"
  var season: Int? = nil  // "Season"
  var series: String? = nil  // "Series"
  var size: UInt64? = nil  // "Size"
  var skipCount: Int? = nil  // "Skip Count"
  var skipDate: String? = nil  // "Skip Date"
  var sortAlbum: String? = nil  // "Sort Album"
  var sortAlbumArtist: String? = nil  // "Sort Album Artist"
  var sortArtist: String? = nil  // "Sort Artist"
  var sortComposer: String? = nil  // "Sort Composer"
  var sortName: String? = nil  // "Sort Name"
  var sortSeries: String? = nil  // "Sort Series"
  var totalTime: Int? = nil  // "Total Time"
  var trackCount: Int? = nil  // "Track Count"
  var trackNumber: Int? = nil  // "Track Number"
  var trackType: String? = nil  // "Track Type"
  var tVShow: Bool? = nil  // "TV Show"
  var unplayed: Bool? = nil  // "Unplayed"
  var videoHeight: Int? = nil  // "Video Height"
  var videoWidth: Int? = nil  // "Video Width"
  var year: Int? = nil  // "Year"
  var isrc: String?  // https://en.wikipedia.org/wiki/International_Standard_Recording_Code
}
