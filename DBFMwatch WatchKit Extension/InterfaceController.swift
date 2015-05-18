import WatchKit
import Foundation
import MediaPlayer
//页面跳转的标志
var controlflag = 0;
//歌曲计时器
var songtime = 0
//歌曲长度
var songlength = 0

//申明一个计时器
var timer:NSTimer?

//声明一个媒体播放器的实例
var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()

//网络控制器的类的实例
var eHttp:HttpController = HttpController()
//引用单例类
var data:LZData = LZData.instance

class InterfaceController: WKInterfaceController ,HttpProtocol{
    @IBOutlet weak var img: WKInterfaceImage!
    
    @IBOutlet weak var lab: WKInterfaceLabel!
    
    @IBOutlet weak var btnPre: WKInterfaceButton!
    
    @IBOutlet weak var btnPlay: WKInterfaceButton!
    
    @IBOutlet weak var btnNext: WKInterfaceButton!
    
    
    //当前播放歌曲的索引值
    var currIndex:Int = 0
    
    //界面跳转到频道列表
    @IBAction func onShowChannel() {
        self.presentControllerWithName("channel", context: self)
        //isReLoad = true
    }
    
    @IBAction func onShowInfo() {
        self.presentControllerWithName("info", context: currIndex)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        //频道列表数据地址：
        //http://www.douban.com/j/app/radio/channels
        //频道音乐数据网址
        //http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite
        eHttp.delegate = self
        if controlflag == 1 {
            let rowIndex = context as! Int
            onSetSong(rowIndex)

            controlflag = 0
        }else if controlflag == 2 {
            controlflag = 0
            let rowIndex = context as! Int
            let channelId = data.channels[rowIndex]["channel_id"].stringValue
            onChangeChannel(channelId)
        }else{
            eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
            eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        }
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
        onSetSong(index)
    }
    
    //根据歌曲索引设置音乐信息
    func onSetSong(index:Int){
        //设置当前索引值
        currIndex = index
        
        //获取行数据
        var rowData:JSON = data.songs[index] as JSON
        //设置封面
        onSetImage(rowData)
        
        //获取歌曲文件地址
        var songUrl:String = rowData["url"].string!
        songlength = rowData["length"].int! + 1
        println("song:\(songlength)")
        //播放歌曲
        onSetAudio(songUrl)
    }
    //播放歌曲的方法
    func onSetAudio(url:String){
        //先销毁计时器
        timer?.invalidate()
        
        //歌曲播放时间至0
        songtime = 0
        
        isPlay = true
        btnPlay.setBackgroundImageNamed("btnPause")
        
        audioPlayer.stop()
        audioPlayer.contentURL = NSURL(string:url)
        audioPlayer.play()
        
        //设定定时器
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "TimerToNext", userInfo: nil, repeats: true)
    }
    
    func TimerToNext(){
        if isPlay {
           songtime++
           //println(songtime)
        }
        if songtime >= songlength {
           onNext()
        }
    }
    
    @IBAction func onPre() {
        //自减
        currIndex--
        if currIndex < 0{
            currIndex = data.songs.count - 1
        }
        onSetSong(currIndex)
    }
    
    @IBAction func onNext() {
        //自增
        currIndex++
        if currIndex > data.songs.count - 1 {
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
        
        let sTitle = rowData["title"].string
        let sArtist = rowData["artist"].string
        let title = "\(sTitle!)-\(sArtist!)"
        //主线程更新UI
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            data.onSetImage(imgUrl!, img: self.img)
            self.lab.setText(title)
        })
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        //通过标志位判断
        
        if data.songs.count > 0 {
            var rowData:JSON = data.songs[currIndex] as JSON
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
    //响应本地通知按钮
    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        if let userInfo = localNotification.userInfo {
            processActionWithIdentifier(identifier, withUserInfo: userInfo)
        }
    }
    //响应远程通知
    override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
        processActionWithIdentifier(identifier, withUserInfo: remoteNotification)
    }
    //自定义userInfo
    func processActionWithIdentifier(identifier:String?,withUserInfo userInfo:[NSObject:AnyObject]){
        if identifier! == "firstButtonAction" {
            let userInfo:[NSObject:AnyObject] = [
                "catergory":"fistpage",
                "timer":10,
                "message":"轻松一下",
                "title":"王子音乐"
            ]
            
            WKInterfaceController.openParentApplication(userInfo, reply: nil)
        }
    }

}
