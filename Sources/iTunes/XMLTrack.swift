//
//  XMLTrack.swift
//  itunes_json
//
//  Created by Greg Bolsinga on 7/24/20.
//

import Foundation

public struct XMLTrack: Codable {
  var album: String? = nil  // "Album"
  var albumArtist: String? = nil  // "Album Artist"
  var albumRating: String? = nil  // "Album Rating"
  var albumRatingComputed: Bool? = nil  // "Album Rating Computed"
  var artist: String? = nil  // "Artist"
  //    var artworkCount : UInt? = nil // "Artwork Count"
  var bitRate: String? = nil  // "Bit Rate"
  var bPM: String? = nil  // "BPM"
  var comments: String? = nil  // "Comments"
  var compilation: String? = nil  // "Compilation"
  var composer: String? = nil  // "Composer"
  var contentRating: String? = nil  // "Content Rating"
  var dateAdded: Date? = nil  // "Date Added"
  var dateModified: Date? = nil  // "Date Modified"
  var disabled: String? = nil  // "Disabled"
  var discCount: String? = nil  // "Disc Count"
  var discNumber: String? = nil  // "Disc Number"
  var episode: String? = nil  // "Episode"
  var episodeOrder: String? = nil  // "Episode Order"
  var explicit: String? = nil  // "Explicit"
  var genre: String? = nil  // "Genre"
  var grouping: String? = nil  // "Grouping"
  var hasVideo: String? = nil  // "Has Video"
  var hD: String? = nil  // "HD"
  var kind: String? = nil  // "Kind"
  var location: String? = nil  // "Location"
  var movie: String? = nil  // "Movie"
  var musicVideo: String? = nil  // "Music Video"
  var name: String  // "Name"
  var partOfGaplessAlbum: String? = nil  // "Part Of Gapless Album"
  var persistentID: String  // "Persistent ID"
  var playCount: String? = nil  // "Play Count"
  var playDateUTC: Date? = nil  // "Play Date UTC"
  var podcast: String? = nil  // "Podcast"
  var protected: String? = nil  // "Protected"
  var purchased: String? = nil  // "Purchased"
  var rating: String? = nil  // "Rating"
  var ratingComputed: String? = nil  // "Rating Computed"
  var releaseDate: Date? = nil  // "Release Date"
  var sampleRate: String? = nil  // "Sample Rate"
  var season: String? = nil  // "Season"
  var series: String? = nil  // "Series"
  var size: String? = nil  // "Size"
  var skipCount: String? = nil  // "Skip Count"
  var skipDate: Date? = nil  // "Skip Date"
  var sortAlbum: String? = nil  // "Sort Album"
  var sortAlbumArtist: String? = nil  // "Sort Album Artist"
  var sortArtist: String? = nil  // "Sort Artist"
  var sortComposer: String? = nil  // "Sort Composer"
  var sortName: String? = nil  // "Sort Name"
  var sortSeries: String? = nil  // "Sort Series"
  var totalTime: String? = nil  // "Total Time"
  var trackCount: String? = nil  // "Track Count"
  var trackNumber: String? = nil  // "Track Number"
  var trackType: String? = nil  // "Track Type"
  var tVShow: String? = nil  // "TV Show"
  var unplayed: String? = nil  // "Unplayed"
  var videoHeight: String? = nil  // "Video Height"
  var videoWidth: String? = nil  // "Video Width"
  var year: String? = nil  // "Year"
}
