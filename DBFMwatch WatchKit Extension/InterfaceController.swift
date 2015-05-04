import WatchKit
import Foundation
import MediaPlayer

class InterfaceController: WKInterfaceController ,HttpProtocol,ChannelProtocol,SongProtocol{
    @IBOutlet weak var img: WKInterfaceImage!
    
    @IBOutlet weak var lab: WKInterfaceLabel!
    
    @IBOutlet weak var btnPre: WKInterfaceButton!
    
    @IBOutlet weak var btnPlay: WKInterfaceButton!
    
    @IBOutlet weak var btnNext: WKInterfaceButton!
    
    //网络控制器的类的实例
    var eHttp:HttpController = HttpController()
    //引用单例类
    var data:LZData = LZData.instance
    
    //声明一个媒体播放器的实例
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    
    //当前播放歌曲的索引值
    var currIndex:Int = 0
    
    //判断是否更新主界面的信息
    //var isReLoad:Bool = false
    
    //界面跳转到频道列表
    @IBAction func onShowChannel() {
        self.presentControllerWithName("channel", context: self)
        //isReLoad = true
    }
    
    @IBAction func onShowSong() {
        self.presentControllerWithName("song", context: self)
        //isReLoad = true
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        //频道列表数据地址：
        //http://www.douban.com/j/app/radio/channels
        //频道音乐数据网址
        //http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite
        
        eHttp.delegate = self
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
       
    }
    
    func didRecieveResults(results: AnyObject) {
        println("\(results)")
        let json = JSON(results)
        //判断是否是频道列表数据
        if let channels = json["channels"].array{
            data.channels = channels
        }else if let songs = json["song"].array{
            data.songs = songs
            //设置第一首音乐的数据
            onSetSong(0)
        }
    }
    
    //接收频道id
    func onChangeChannel(channel_id: String) {
        //println("channel_id:\(channel_id)")
        
        //拼频道列表的歌曲数据网络网址
        let url: String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        eHttp.onSearch(url)
    }
    
    //接收歌曲索引
    func onChangeSong(index: Int) {
        //println("song index:\(index)")
        onSetSong(index)
        
    }
    
    //根据歌曲索引设置音乐信息
    func onSetSong(index:Int){
        //设置当前索引值
        currIndex = index
        
        //获取行数据
        var rowData:JSON = self.data.songs[index] as JSON
        //设置封面
        onSetImage(rowData)
        
        //获取歌曲文件地址
        var songUrl:String = rowData["url"].string!
        //播放歌曲
        onSetAudio(songUrl)
    }
    //播放歌曲的方法
    func onSetAudio(url:String){
        isPlay = true
        btnPlay.setBackgroundImageNamed("btnPause")
        
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string:url)
        self.audioPlayer.play()
    }
    
    @IBAction func onPre() {
        //自减
        currIndex--
        if currIndex < 0{
            currIndex = self.data.songs.count - 1
        }
        onSetSong(currIndex)
    }
    
    @IBAction func onNext() {
        //自增
        currIndex++
        if currIndex > self.data.songs.count - 1 {
            currIndex = 0
        }
        onSetSong(currIndex)
    }
    //播放状态
    var isPlay:Bool = true
    @IBAction func onPlay() {
        isPlay = !isPlay
        
        if isPlay {
            audioPlayer.play()
            btnPlay.setBackgroundImageNamed("btnPause")
        }else {
            audioPlayer.pause()
            btnPlay.setBackgroundImageNamed("btnPlay")
        }
    }
    
    //设置歌曲封面以及信息
    func onSetImage(rowData:JSON){
        let imgUrl = rowData["picture"].string
        data.onSetImage(imgUrl!, img: img)
        
        let sTitle = rowData["title"].string
        let sArtist = rowData["artist"].string
        let title = "\(sTitle!)-\(sArtist!)"
        lab.setText(title)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        //通过标志位判断
//        if isReLoad {
//            var rowData:JSON = self.data.songs[currIndex] as JSON
//            onSetImage(rowData)
//            isReLoad = false
//        }
        
        if self.data.songs.count > 0 {
            var rowData:JSON = self.data.songs[currIndex] as JSON
            onSetImage(rowData)
            if isPlay {
                btnPlay.setBackgroundImageNamed("btnPause")
            }
            
        }
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
