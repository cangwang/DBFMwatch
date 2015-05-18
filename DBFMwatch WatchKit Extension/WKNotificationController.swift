//
//  WKNotificationController.swift
//  DBFMwatch
//
//  Created by air on 15/5/11.
//  Copyright (c) 2015年 air. All rights reserved.
//

import WatchKit
import Foundation


class WKNotificationController: WKUserNotificationInterfaceController {

    @IBOutlet weak var titleLab: WKInterfaceLabel!
    @IBOutlet weak var messageLab: WKInterfaceLabel!
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a local notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        //completionHandler(.Custom)
        
        if let userInfo = localNotification.userInfo {
            processNotificationWithUserInfo(userInfo, withCompletion: completionHandler)
        }
    }
    
    
    
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a remote notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        //completionHandler(.Custom)
        processNotificationWithUserInfo(remoteNotification, withCompletion: completionHandler)
    }
    
    func processNotificationWithUserInfo(userInfo:[NSObject:AnyObject],withCompletion completionHandler:(WKUserNotificationInterfaceType)->Void){
        messageLab.setHidden(true)
        if let message = userInfo["message"] as? String {
            messageLab.setHidden(false)
            messageLab.setText(message)
        }
        
        titleLab.setHidden(true)
        if let title = userInfo["title"] as? String {
            titleLab.setHidden(false)
            titleLab.setText(title)
        }
        
        completionHandler(.Custom)
    }
    
}
