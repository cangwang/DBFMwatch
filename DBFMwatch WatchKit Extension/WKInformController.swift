//
//  WKInformController.swift
//  DBFMwatch
//
//  Created by air on 15/5/11.
//  Copyright (c) 2015年 air. All rights reserved.
//

import WatchKit
import Foundation

class WKInformController: WKInterfaceController {

    @IBOutlet weak var img: WKInterfaceImage!
    
    @IBOutlet weak var songlab: WKInterfaceLabel!
    
    @IBOutlet weak var artistlab: WKInterfaceLabel!
    
    @IBOutlet weak var ablumlab: WKInterfaceLabel!
    
    @IBOutlet weak var lengthlab: WKInterfaceLabel!
    
    @IBOutlet weak var publishlab: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        var currIndex = context as! Int
        
        ConfigInform(currIndex)
    }
    
    func ConfigInform(index:Int){
        var rowData:JSON = data.songs[index] as JSON
        //播放歌曲图片转化
        var imgurl = rowData["picture"].string!
        data.onSetImage(imgurl, img: img)
        
        songlab.setText(rowData["title"].string!)
        artistlab.setText(rowData["artist"].string!)
        ablumlab.setText(rowData["albumtitle"].string!)
        //播放歌曲长度转化
        var length = rowData["length"].int!
        let m = length/60
        let s = length%60
        let time = "\(m)m\(s)s"
        lengthlab.setText(time)
        //播放歌曲年份
        let year = rowData["public_time"].string!
        publishlab.setText("\(year)年")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
