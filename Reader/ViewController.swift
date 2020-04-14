/*
* Copyright (c) 2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Cocoa
import WebKit

class ViewController: NSViewController {
  
  var feeds = [Feed]()
  var dateFormatter = DateFormatter()
  
  @IBOutlet weak var webView: WebView!
  @IBOutlet weak var outlineView: NSOutlineView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateFormatter.dateStyle = .short
    
    // Do any additional setup after loading the view.
    if let filePath = Bundle.main.path(forResource: "Feeds", ofType: "plist") {
      feeds = Feed.feedList(filePath)  // Feedの一覧を取得する
      print(feeds)
    }
    outlineView.reloadData()
  }
  
}

extension ViewController: NSOutlineViewDataSource {
  // オブジェクトの含めるchildrenの数を返す
  // e.g. feedsであればFeedの数を、FeedであればFeed.childrenの数
  // すべてのデータ階層で呼ばれる
  // item = nilの場合、トップレベルの項目のChildrenの数を返す
  // というか、itemが値を持つ場合は、closureを展開した場合に呼ばれるタイミングだったりする
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    if let feed = item as? Feed {
      return feed.children.count
    }
    
    return feeds.count
  }
  
  // 親に対する子の情報を与える
  // item will be nil for the root object.
  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    if let feed = item as? Feed {
      return feed.children[index]
    }
    
    return feeds[index]
  }
  
  // ここではFeedsのみ（Feedsに関してのときにitemがFeed？）展開可能である
  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    if let feed = item as? Feed {
      return feed.children.count > 0
    }
      
    return false
  }
}

extension ViewController: NSOutlineViewDelegate {
  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    var view: NSTableCellView?
    
    if let feed = item as? Feed {
      
      if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "DateColumn") {
        // FeedのDateに関して、空にしておく
        view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DateCell"), owner: self) as? NSTableCellView
        if let textField = view?.textField {
          textField.stringValue = ""
          textField.sizeToFit()
        }
      } else {
        view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FeedCell"), owner: self) as? NSTableCellView
        if let textField = view?.textField {
          textField.stringValue = feed.name
          textField.sizeToFit()
        }
      }

    } else if let feedItem = item as? FeedItem {  // FeedItemに関して、2つのアイテムが有りcolumnのidentifierで見分ける
      if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "DateColumn") {  // FeedItem->Dateの場合
        view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DateCell"), owner: self) as? NSTableCellView
        
        if let textField = view?.textField {
          textField.stringValue = dateFormatter.string(from: feedItem.publishingDate)
          textField.sizeToFit()
        }
      } else {  // FeedItem-titleの場合
        view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FeedItemCell"), owner: self) as? NSTableCellView
        if let textField = view?.textField {
          textField.stringValue = feedItem.title
          textField.sizeToFit()
        }
      }
    }

    return view
  }
    
  // 選択された行の情報をWebViewに表示する
  func outlineViewSelectionDidChange(_ notification: Notification) {
    // 通知元がNSOutlineViewかどうかの確認
    guard let outlineView = notification.object as? NSOutlineView else {
      return
    }
    
    let selectedIndex = outlineView.selectedRow
    if let feedItem = outlineView.item(atRow: selectedIndex) as? FeedItem {
      let url = URL(string: feedItem.url)
      if let url = url {
        self.webView.mainFrame.load(URLRequest(url: url))
      }
    }
  }
}
