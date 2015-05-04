import WatchKit


class LZData{
    
    internal static let instance:LZData={
        return LZData()
    }()
    //存放歌曲数据
    var songs = [JSON]()
    //存储频道列表数据
    var channels = [JSON]()
    
    //申明一个字典，实现图片缓存
    var imageCache = Dictionary<String,UIImage>()
    //缓存策略，显示图像，iPhone端
    func onSetImage2(url:String,img:WKInterfaceImage){
        //通过URL去缓存中查找有没有缓存过的图像
        let image = self.imageCache[url] as UIImage?
        
        if image == nil {
            //如果缓存没有这张图片，就通过网络去获取
            Alamofire.manager.request(Method.GET, url).response({ (_, _, data, error) -> Void in
                //获取到的图像数据将赋予imgView
                let imgData = UIImage(data: data as! NSData)
                img.setImage(imgData)
                self.imageCache[url] = imgData
            })
        }else {
            //如果缓存中有，就直接调用
            img.setImage(image)
        }
    }
    //watch端的图像缓存策略
    func onSetImage(url:String, img:WKInterfaceImage){
        let device = WKInterfaceDevice.currentDevice()
        let nsUrl = NSURL(string: url)
        //获取图像文件名，eko.jpg
        let imgName = nsUrl?.path?.lastPathComponent
        
        if cacheContainsImageNamed(imgName!) == true {
            img.setImageNamed(imgName)
        }else {
            Alamofire.manager.request(Method.GET, url).response({ (_, _, data, error) -> Void in
                if error == nil {
                    //获取的图像赋予img
                    let image = UIImage(data: data as! NSData)
                    self.addImageToCache(image!, name: imgName!)
                    img.setImageNamed(imgName!)
                }
            })
        }
    }
    

    
    //根据图像名称，来判断缓存中是否有图像
    func cacheContainsImageNamed(name:String) ->Bool {
        
        return contains(cachedImages.keys, name)
    }
    
    //删除图像缓存的方法
    func removeRandomImageFromCache()->Bool {
        let cachedImageNames = cachedImages.keys
        //从集合中找出第一个元素，从缓存中去除掉
        if let randomImageName = cachedImageNames.first {
            WKInterfaceDevice.currentDevice().removeCachedImageWithName(randomImageName)
            return true
        }
        return false
    }
    
    //将图像加入到缓存中，以图像名称为key，图像数据为value
    func addImageToCache(image:UIImage,name:String){
        //获取当前设备
        let device = WKInterfaceDevice.currentDevice()
        //假设加入缓存不成功，清楚缓存第一个元素，要是不成功，则清空所有缓存，再强行加入
        while (device.addCachedImage(image, name: name) == false){
            let removeImage = removeRandomImageFromCache()
            if !removeImage {
                device.removeAllCachedImages()
                device.addCachedImage(image, name: name)
                break
            }
        }
    }
    
    var cachedImages: [String:NSNumber] = {
        return WKInterfaceDevice.currentDevice().cachedImages as! [String:NSNumber]
    }()
}
