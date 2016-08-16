//
//  QRCodeViewController.swift
//  hunbian
//
//  Created by haohao on 16/8/11.
//  Copyright © 2016年 haohao. All rights reserved.
//

import UIKit
import AVFoundation
//播放声音需要的框架
import AudioToolbox

class QRCodeViewController: UIViewController , UIAlertViewDelegate, HandleTheResultDelegate{
    
    var readView : QRCodeReaderView?
    var alertView : UIAlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "二维码"
        let navBar = UINavigationBar.appearance()
        let font = UIFont(name: "Snell Roundhand", size: 20.0)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.redColor(), NSFontAttributeName: font!]
        self.initScan()
    }
    //加载扫描框
    func initScan() {
        let authorStaus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if [authorStaus == .Restricted, authorStaus == .Denied].contains(true){
            if kIOS8 == 1 {
                if self.alertView != nil {
                    self.alertView = nil
                }
                self.alertView = UIAlertView.init(title: "温馨提示", message: "相机权限受限，请在设置->隐私->相机 中进行设置！", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "设置")
                self.alertView?.show()
            }else{
                if self.alertView != nil {
                    self.alertView = nil
                    self.alertView = UIAlertView.init(title: "温馨提示", message: "相机权限受限，请在设置->隐私->相机 中进行设置！", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "设置")
                    self.alertView?.show()
                }
            }
        }
        
        if self.readView != nil{
            self.readView?.removeFromSuperview()
            self.readView = nil
        }
        self.readView = QRCodeReaderView.init(frame: UIScreen.mainScreen().bounds)
        self.readView?.delegate = self
        self.readView?.puinMyCodeController = {() in
            //进入我的二维码界面
            let  storyBoard = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle())
            let vc = storyBoard.instantiateViewControllerWithIdentifier("MineQRCodeViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.readView?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.readView!)
    }
    
    //重新扫描的方法
    func reStartScan() {
        if self.readView?.scanType != .BarCode {
            self.readView?.creatDrawLine()
            self.readView?.startLineAnimation()
        }
        self.readView?.start()
    }
    
    //View将要出现的时候重新扫描
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.readView != nil {
            self.reStartScan()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if self.readView != nil {
            self.readView?.stop()
        }
    }
    
    //处理扫描结果
    func handleResult(result: String) {
        print("处理扫描结果\(result)")
    }
    
//MARK: ---UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            print("去设置")
        }
    }
    
//MARK:----HandleTheResultDelegate
    func handelTheResult(metadataObjectString: String) {
        //停止扫描
        self.readView?.stop()
        //播放扫描二维码的声音
        //这个只能播放不超过30秒的声音，它支持的文件格式有限，具体的说只有CAF、AIF和使用PCM或IMA/ADPCM数据的WAV文件
        //声音地址
        let path = NSBundle.mainBundle().pathForResource("noticeMusic", ofType: "wav")
        //建立的systemSoundID对象
        var soundID : SystemSoundID = 0
        let baseURL = NSURL.fileURLWithPath(path!)
        //赋值
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        //播放声音
        AudioServicesPlaySystemSound(soundID)
        
        //如果是提醒的话
        
    //处理扫描结果
        self.handleResult(metadataObjectString)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
