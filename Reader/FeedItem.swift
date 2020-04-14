//
//  FeedItem.swift
//  Reader
//
//  Created by HIROKI IKEUCHI on 2020/04/14.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import Cocoa

class FeedItem: NSObject {
  let url: String
  let title: String
  let publishingDate: Date
  
  init(dictionary: NSDictionary) {
    self.url = dictionary.object(forKey: "url") as! String
    self.title = dictionary.object(forKey: "title") as! String
    self.publishingDate = dictionary.object(forKey: "date") as! Date
  }
}
