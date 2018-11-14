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

var albumID: UInt64 = 1442200000

func getAlbumByIdIncresement() {
    cider.album(id: String(albumID)) { (results, error) in
//        if let error = error {
//            print(error.localizedDescription)
//        }
        
        if let results = results {
            if let attributes = results.attributes {
                if attributes.genreNames.contains("アニメ") {
                    print(attributes.name + " " + String(albumID) + " is anisong")
                    print("URL is " + attributes.url.absoluteString)
                    
                    let tweetText = "「" + attributes.name + "」がApple Musicに追加されました。" + "\n" + attributes.url.absoluteString

                    // Toot on Mastodon
                    shell("python", "Mastodon/toot.py", tweetText)
                    
                    // Tweet on Twitter
                    shell("python", "Twitter/tweet.py", tweetText)
                    
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
