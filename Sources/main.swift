//
//  main.swift
//  AppleMusicAnime
//
//  Created by ERU on 2018/11/13.
//

import Foundation
import Cider
import Kanna

// Need to block the thread and wait for URLSession to finish
// https://stackoverflow.com/q/30702387/4063462
var sema = DispatchSemaphore(value: 0)

let cider = CiderClient(storefront: .japan, developerToken: developerToken)

//cider.search(term: "ラブライブ！", types: [.albums, .songs]) { results, error in
//
//    if let error = error {
//        fatalError(error.localizedDescription)
//    }
//
//    if let results = results {
//        print(results)
//    }
//
//    sema.signal()
//}

let dateFormatterForAPI = DateFormatter()
dateFormatterForAPI.dateFormat = "yyyy-MM-dd"
let dateFormatterForJP = DateFormatter()
dateFormatterForJP.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
let dateFormatterForYear = DateFormatter()
dateFormatterForYear.dateFormat = "yyyy年"

var albumID: UInt64 = 1441410630

func getAlbumByIdIncresement() {
    cider.album(id: String(albumID)) { (results, error) in
//        if let error = error {
//            print(error.localizedDescription)
//        }
        
        if let results = results {
            if let attributes = results.attributes, let relationships = results.relationships {
                if attributes.genreNames.first == "アニメ" {
                    print(attributes.name + " " + String(albumID) + " is anisong")
                    
                    guard let date = dateFormatterForAPI.date(from: attributes.releaseDate) else { fatalError("DateFormatter error") }
                    
                    // Detect explicit
                    var isExplicit = false
                    if let trackDataArray = relationships.tracks.data {
                        for trackData in trackDataArray {
                            if trackData.attributes?.contentRating == ContentRating.explicit {
                                isExplicit = true
                                continue
                            }
                        }
                    }
                    
                    // Create content to post
                    var contentText = attributes.artistName + "の" + "「" + attributes.name + "」"
//                        + "アルバム・" + dateFormatterForYear.string(from: date) + "・\(attributes.trackCount)曲\n"
                    
                    if attributes.playParams != nil {
                        // Apple Music
                        contentText = "【Apple Music 配信中】\n" + contentText
                    } else {
                        // iTunes Store
                        contentText = "【iTunes Store 配信中】\n" + contentText
                        
                        if let formattedPrice = getAlbumFormattedPriceFromHTML(attributes.url) {
                            contentText = contentText + "\n" + formattedPrice + "で販売中"
                        }

                        if date > Date() {
                            // not yet released
                            contentText = contentText + "\n予約注文: リリース予定日：" + dateFormatterForJP.string(from: date)
                        }
                    }
                    
                    // Add genreName as hashtag before url
                    if attributes.genreNames.count > 0 {
                        contentText = contentText + "\n"
                    }
                    for genreName in attributes.genreNames {
                        // J-Pop -> JPop, R&B -> RnB, RnB／ソウル -> RnB #ソウル
                        let genreHashtag = genreName.replacingOccurrences(of: "-", with: "")
                            .replacingOccurrences(of: "&", with: "n")
                            .replacingOccurrences(of: "／", with: " #")
                        // "JPop" -> "#JPop ", "RnB #ソウル" -> "#RnB #ソウル "
                        contentText = contentText + "#" + genreHashtag + " "
                    }
                    
                    // Add url to the end
                    contentText = contentText + "\n" + attributes.url.absoluteString
                    
                    print(contentText)
                    
                    if !isExplicit {
                        // Toot on Mastodon
                        shell("python", "Mastodon/toot.py", contentText)
                        // Tweet on Twitter
                        shell("python", "Twitter/tweet.py", contentText)
                    }
                    
                } else {
                    print(attributes.name + " " + String(albumID) + " is not anisong")
                }
                
                saveCurrentAlbumID(String(albumID))
            }
        }
        
        albumID += 1
        getAlbumByIdIncresement()
        //    sema.signal()
    }
}

if let albumIDString = getCurrentAlbumID() {
    if let unwrappedAlbumID = UInt64(albumIDString) {
        // Request for next id
        albumID = unwrappedAlbumID + 1
    }
}

getAlbumByIdIncresement()

sema.wait()
