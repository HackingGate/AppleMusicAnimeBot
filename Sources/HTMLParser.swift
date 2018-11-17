//
//  HTMLParser.swift
//  AppleMusicAnime
//
//  Created by ERU on 2018/11/17.
//

import Foundation
import Kanna

func getAlbumFormattedPriceFromHTML(_ url: URL) -> String? {
    if let doc = try? HTML(url: url, encoding: .utf8) {
        
        // Search for nodes by CSS
        for node in doc.css("li, class") {
            if node.className == "product-header__list__item" {
                if let text = node.text {
                    let filteredText = String(text.filter { !" \n".contains($0) })
                    let result = filteredText.range(of: "^¥\\b\\d{1,3}(,\\d{3})*\\b", options: .regularExpression) != nil
                    if result {
                        return filteredText
                    }
                }
            }
        }
    }
    return nil
}
