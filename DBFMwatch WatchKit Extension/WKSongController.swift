import WatchKit
import Foundation


class WKSongController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    
    //申明代理
    var delegate:SongProtocol?
    
    //引用数据中心单例
    var data:LZData = LZData.instance

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.delegate = context as? SongProtocol
        
        // Configure interface objects here.
        table.setNumberOfRows(data.songs.count, withRowType: "songRow")
        for (index,json) in enumerate(data.songs){
            let row = table.rowControllerAtIndex(index) as! WKSongRow
            let title = json["title"].stringValue
            let artist = json["artist"].stringValue
            let imgUrl = json["picture"].stringValue
            row.lbArtist.setText(artist)
            row.lbTitle.setText(title)
            data.onSetImage(imgUrl, img: row.img)
        }
        
    }
    
    //点击具体某一首歌的时候，返回主视图，并将当前视图消失
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        delegate?.onChangeSong(rowIndex)
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

protocol SongProtocol {
    //回调方法，将歌曲索引值返回
    func onChangeSong(index:Int)
}
