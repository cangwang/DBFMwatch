//
//  WKChannelController.swift
//  DBFMwatch
//
//  Created by air on 15/4/30.
//  Copyright (c) 2015年 air. All rights reserved.
//

import WatchKit
import Foundation

//频道列表数组
var titleList = [String]()

class WKChannelController: WKInterfaceController {
    
    //频道列表标示
    var channelslistflag = true
    
    @IBOutlet weak var table: WKInterfaceTable!
    //数据中心的单例
    //var data:LZData = LZData.instance
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //self.delegate = context as? ChannelProtocol
        
        // Configure interface objects here.
        
        
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        controlflag = 2
        channelslistflag = true
        WKInterfaceController.reloadRootControllersWithNames(["play","song","channel"], contexts: [rowIndex,"",""])
        //self.dismissController()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if channelslistflag == true {
           ConfigSetChannels()
           channelslistflag = false
        }
    }
 
    func ConfigSetChannels(){
        table.setNumberOfRows(data.channels.count, withRowType: "channelRow")
        //if titleList.count == 0 {
            for(index,json) in enumerate(data.channels) {
                let row = table.rowControllerAtIndex(index) as! WKChannelRow
                var title = json["name"].stringValue
                //titleList.append(title)
                //主线程更新列表
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    row.titleLab.setText(title)
                })
                
            }
            println("channel list")
        /*}else {
            for(index,channelsname) in enumerate(titleList) {
                let row = table.rowControllerAtIndex(index) as! WKChannelRow
                    row.titleLab.setText(channelsname)
            }
        }
        */
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

