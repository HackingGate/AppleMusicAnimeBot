//
//  CurrentAlbumID.swift
//  AppleMusicAnime
//
//  Created by ERU on 2018/11/14.
//

import Foundation

func saveCurrentAlbumID(_ albumIDString: String) {
    let file = FileManager.default.currentDirectoryPath.appending("/current_album_id.txt")
    
    do {
        try albumIDString.write(toFile: file, atomically: false, encoding: .utf8)
    }
    catch {
        print(error.localizedDescription)
    }
}

func getCurrentAlbumID() -> String? {
    let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath.appending("/current_album_id.txt"), isDirectory: false)
    
    do {
        let albumIDString = try String(contentsOf: fileURL, encoding: .utf8)
        return String(albumIDString.filter { !" \n\t\r".contains($0) })
    }
    catch {
        print(error.localizedDescription)
    }
    
    return nil
}
