//
//  Feed.swift
//  Reader
//
//  Created by HIROKI IKEUCHI on 2020/04/14.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import Cocoa

class Feed: NSObject {
  let name: String
  var children = [FeedItem]()
  
  init(name: String) {
    self.name = name
  }
  
  class func feedList(_ fileName: String) -> [Feed] {
    var feeds = [Feed]()
    
    // ファイルから読み取りを試みる
    if let feedList = NSArray(contentsOfFile: fileName) as? [NSDictionary] {
      // エントリーをループする
      for feedItems in feedList {
        let feed = Feed(name: feedItems.object(forKey: "name") as! String)  // Feedの作成
        let items = feedItems.object(forKey: "items") as! [NSDictionary]    // FeedItemsの取得
        for dict in items {  // FeedItemsをループ
          let item = FeedItem(dictionary: dict)  // FeedItemの作成
          feed.children.append(item)  // Feedのchildren(:[FeedItem])にぶら下げる
        }
        feeds.append(feed)
      }
    }
    
    return feeds
  }
  
  
}
