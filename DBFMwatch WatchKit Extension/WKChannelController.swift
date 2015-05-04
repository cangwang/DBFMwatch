//
//  WKChannelController.swift
//  DBFMwatch
//
//  Created by air on 15/4/30.
//  Copyright (c) 2015年 air. All rights reserved.
//

import WatchKit
import Foundation


class WKChannelController: WKInterfaceController {
    
    //申请代理
    var delegate:ChannelProtocol?

    @IBOutlet weak var table: WKInterfaceTable!
    //数据中心的单例
    var data:LZData = LZData.instance
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.delegate = context as? ChannelProtocol
        
        // Configure interface objects here.
        table.setNumberOfRows(data.channels.count, withRowType: "channelRow")
        for(index,json) in enumerate(data.channels) {
            let row = table.rowControllerAtIndex(index) as! WKChannelRow
            var title = json["name"].stringValue
            row.titleLab.setText(title)
        }
        
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let channelId = data.channels[rowIndex]["channel_id"].stringValue
        delegate?.onChangeChannel(channelId)
        
        self.dismissController()
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

protocol ChannelProtocol {
    //定义回调方法，将频道id传回主视图中
    func onChangeChannel(channel_id:String)
}
