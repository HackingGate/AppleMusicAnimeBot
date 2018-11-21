//
//  main.swift
//  AppleMusicAnime
//
//  Created by ERU on 2018/11/13.
//

import Foundation
import Cider

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

var notFoundErrorCount: UInt = 0

func getAlbumByIdIncresement() {
    cider.album(id: String(albumID)) { (results, error) in
        if let error = error, let apierror = error as? AppleMusicAPIError {
            if apierror.status == "404" {
                notFoundErrorCount += 1
                if notFoundErrorCount > 10000 {
                    print(error.localizedDescription)
                    sema.signal()
                }
            } else {
                fatalError(error.localizedDescription)
            }
        } else {
            notFoundErrorCount = 0
        }
        
        if let results = results {
            if let attributes = results.attributes, let relationships = results.relationships {
                
                saveCurrentAlbumID(String(albumID))
                
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
                    var contentText = attributes.artistName + "の" + "「" + attributes.name + "」" + "\(attributes.trackCount)曲"
//                        + "\n" + "アルバム・" + dateFormatterForYear.string(from: date) + "・\(attributes.trackCount)曲"
                    
                    if attributes.playParams != nil {
                        // Apple Music
                        contentText = "【Apple Music 配信中】\n" + contentText
                        contentText = contentText + "\nリリース：" + dateFormatterForJP.string(from: date)
                    } else {
                        // iTunes Store
                        contentText = "【iTunes Store 販売中】\n" + contentText
                        
                        if date > Date() {
                            contentText = contentText + "\nリリース予定日：" + dateFormatterForJP.string(from: date)
                        } else {
                            contentText = contentText + "\nリリース：" + dateFormatterForJP.string(from: date)
                        }
                        
                        if let formattedPrice = getAlbumFormattedPriceFromHTML(attributes.url) {
                            contentText = contentText + "\n" + formattedPrice
                        }
                    }
                    
                    // Add genreName as hashtag before url
                    if attributes.genreNames.count > 0 {
                        contentText = contentText + "\n"
                    }
                    for genreName in attributes.genreNames {
                        // "アニメ" -> "#アニソン "
                        if genreName == "アニメ" {
                            contentText = contentText + "#アニソン "
                        } else if genreName != "ミュージック" {
                            // "J-Pop" -> "JPop", "R&B" -> "RnB", "RnB／ソウル" -> "RnB #ソウル"
                            let genreHashtag = genreName.replacingOccurrences(of: "-", with: "")
                                .replacingOccurrences(of: "&", with: "n")
                                .replacingOccurrences(of: "／", with: " #")
                            // "JPop" -> "#JPop ", "RnB #ソウル" -> "#RnB #ソウル "
                            contentText = contentText + "#" + genreHashtag + " "
                        }
                    }
                    
                    // Add url to the end
                    contentText = contentText + "\n" + attributes.url.absoluteString
                    
                    if attributes.playParams == nil {
                        // Add "?app=itunes"
                        contentText = contentText + "?app=itunes"
                    }
                    
                    print(contentText)
                    
                    if !isExplicit && !attributes.genreNames.contains("チルドレン・ミュージック") {
                        // Toot on Mastodon
                        shell("python", "Mastodon/toot.py", contentText)
                        // Tweet on Twitter
                        shell("python", "Twitter/tweet.py", contentText)
                        
                        sema.signal()
                    }
                    
                }
                
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
