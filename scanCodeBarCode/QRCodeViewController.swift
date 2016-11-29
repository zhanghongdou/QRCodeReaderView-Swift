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

class QRCodeViewController: UIViewController , UIAlertViewDelegate, HandleTheResultDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var readView : QRCodeReaderView?
    var alertView : UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //添加相册识别二维码的功能
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "相册", style: .done, target: self, action: #selector(QRCodeViewController.openLocalPhotoAlbum))
       
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.title = "二维码"
        let navBar = UINavigationBar.appearance()
        let font = UIFont(name: "Snell Roundhand", size: 20.0)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.red, NSFontAttributeName: font!]
        self.initScan()
    }
    
    //进入相册
     func openLocalPhotoAlbum() {
        let picker = UIImagePickerController()
        
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        picker.delegate = self;
        
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image:UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
        //识别二维码
        if image != nil {
            let detector:CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let img = CIImage(cgImage: (image?.cgImage)!)
            let features : [CIFeature]? = detector.features(in: img, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
            if features != nil && (features?.count)! > 0 {
                let feature = features![0]
                if feature.isKind(of: CIQRCodeFeature.self)
                {
                    let featureTmp:CIQRCodeFeature = feature as! CIQRCodeFeature
                    
                    let scanResult = featureTmp.messageString
                    self.handleResult(scanResult!)
                }
            }
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //加载扫描框
    func initScan() {
        let authorStaus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if [authorStaus == .restricted, authorStaus == .denied].contains(true){
                if self.alertView != nil {
                    self.alertView = nil
                }
                self.alertView = UIAlertController.init(title: "温馨提示", message: "相机权限受限，请在设置->隐私->相机 中进行设置！", preferredStyle: .alert)
                let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: { (cancelaction) in
                    
                })
                let setAction = UIAlertAction.init(title: "去设置", style: .default, handler: { (setaction) in
                    let url = NSURL.init(string: UIApplicationOpenSettingsURLString)
                    if UIApplication.shared.canOpenURL(url as! URL) {
                        UIApplication.shared.openURL(url as! URL)
                    }
                })
            self.alertView?.addAction(cancelAction)
            self.alertView?.addAction(setAction)
            self.present(self.alertView!, animated: true, completion: nil)
            return
        }
        
        if self.readView != nil{
            self.readView?.removeFromSuperview()
            self.readView = nil
        }
        self.readView = QRCodeReaderView.init(frame: UIScreen.main.bounds)
        self.readView?.delegate = self
        self.readView?.puinMyCodeController = {() in
            //进入我的二维码界面
            let  storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let vc = storyBoard.instantiateViewController(withIdentifier: "MineQRCodeViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.readView?.backgroundColor = UIColor.white
        self.view.addSubview(self.readView!)
    }
    
    //重新扫描的方法
    func reStartScan() {
        if self.readView?.scanType != .barCode {
            self.readView?.creatDrawLine()
            self.readView?.startLineAnimation()
        }
        self.readView?.start()
    }
    
    //View将要出现的时候重新扫描
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.readView != nil {
            self.reStartScan()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.readView != nil {
            self.readView?.stop()
        }
    }
    
    //处理扫描结果
    func handleResult(_ result: String) {
        print("处理扫描结果\(result)")
    }
    
//MARK: ---UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            print("去设置")
        }
    }
    
//MARK:----HandleTheResultDelegate
    func handelTheResult(_ metadataObjectString: String) {
        //停止扫描
        self.readView?.stop()
        //播放扫描二维码的声音
        //这个只能播放不超过30秒的声音，它支持的文件格式有限，具体的说只有CAF、AIF和使用PCM或IMA/ADPCM数据的WAV文件
        //声音地址
        let path = Bundle.main.path(forResource: "noticeMusic", ofType: "wav")
        //建立的systemSoundID对象
        var soundID : SystemSoundID = 0
        let baseURL = URL(fileURLWithPath: path!)
        //赋值
        AudioServicesCreateSystemSoundID(baseURL as CFURL, &soundID)
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
