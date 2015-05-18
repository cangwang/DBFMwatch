import WatchKit

//定义协议
protocol HttpProtocol{
    //定义一个方法，接收一个参数：AnyObject
    func didRecieveResults(results:AnyObject)
}

class HttpController: NSObject {
    
    var delegate:HttpProtocol?
    
    //定义一个方法，接收网址，请求数据，回调代理的方法，传回数据
    func onSearch(url:String){
        Alamofire.manager.request(Method.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, json, _) -> Void in            
            self.delegate?.didRecieveResults(json!)
        }
    }
}
