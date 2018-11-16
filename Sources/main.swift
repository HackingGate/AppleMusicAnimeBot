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

var albumID: UInt64 = 1440141805

func getAlbumByIdIncresement() {
    cider.album(id: String(albumID)) { (results, error) in
//        if let error = error {
//            print(error.localizedDescription)
//        }
        
        if let results = results {
            if let attributes = results.attributes {
                if attributes.genreNames.first == "アニメ" {
                    print(attributes.name + " " + String(albumID) + " is anisong")
                    print("URL is " + attributes.url.absoluteString)
                    
                    guard let date = dateFormatterForAPI.date(from: attributes.releaseDate) else { fatalError("DateFormatter error") }
                    
                    var contentText = attributes.artistName + "の" + "「" + attributes.name + "」\n"
                        + "アルバム・" + dateFormatterForYear.string(from: date) + "・\(attributes.trackCount)曲\n"
                        + attributes.url.absoluteString
                    
                    if date > Date() {
                        // not yet released
                        contentText = contentText + "\n予約注文: リリース予定日：" + dateFormatterForJP.string(from: date)
                    } else {
                        contentText = "【Apple Music 配信中】\n" + contentText
                        
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
