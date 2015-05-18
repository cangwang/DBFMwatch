import WatchKit
import Foundation

class WKSongController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    
    
    //音乐列表标示
    var songlistflag = true
    
    //引用数据中心单例
    //var data:LZData = LZData.instance

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //self.delegate = context as? SongProtocol
        
        // Configure interface objects here.
    }
    
    //点击具体某一首歌的时候，返回主视图，并将当前视图消失
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        controlflag = 1
        songlistflag = true
        WKInterfaceController.reloadRootControllersWithNames(["play","song","channel"], contexts: [rowIndex,"",""])
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if songlistflag == true{
           ConfigSetSong()
           songlistflag = false
        }
    }
    
    func ConfigSetSong(){
        table.setNumberOfRows(data.songs.count, withRowType: "songRow")
        for (index,json) in enumerate(data.songs){
            let row = table.rowControllerAtIndex(index) as! WKSongRow
            let title = json["title"].stringValue
            let artist = json["artist"].stringValue
            let imgUrl = json["picture"].stringValue
            //主线程图像更新列表
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                row.lbArtist.setText(artist)
                row.lbTitle.setText(title)
                data.onSetImage(imgUrl, img: row.img)
            })
            
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
