//
//  QRCodeReaderView.swift
//  hunbian
//
//  Created by haohao on 16/8/11.
//  Copyright © 2016年 haohao. All rights reserved.
//

import UIKit
import AVFoundation
//进入我的二维码的闭包
typealias putInMyQRCodeController = () -> Void
//处理扫描结果的delegate
protocol HandleTheResultDelegate : class {
    func handelTheResult(_ metadataObjectString: String) -> Void
}
extension HandleTheResultDelegate {
    func handelTheResult(_ metadataObjectString: String) -> Void {}
}
//enum DAOError: ErrorType {
//    case NoData
//    case NullKey
//}

//设置扫描的结构体
enum ScanQRCodeType: Int {
    case qrCode = 1
    case barCode
}

class QRCodeReaderView: UIView, AVCaptureMetadataOutputObjectsDelegate{
    let device:AVCaptureDevice? = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo);
    var puinMyCodeController : putInMyQRCodeController?
    var captureSession : AVCaptureSession?
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    var lastResult = Bool()
    var isAnmotion = false
    var lineImageView : UIImageView?
    var delegate : HandleTheResultDelegate?
    var input : AVCaptureDeviceInput?
    //创建输出流
    var outPut : AVCaptureMetadataOutput!
    //扫描的类型
    var scanType : ScanQRCodeType?
    let defaultBothSideWidth : CGFloat = 60
    
    //设置四周的View
    var topView : UIView?
    var leftView : UIView?
    var rightView : UIView?
    var bottomView : UIView?
    
    var leftQRCodeBtn : UIButton!
    var barCodeBtn : UIButton!
    var btnBottomView : UIView!
    
    //扫描区域的相框
    var leftTopLayer = CAShapeLayer()
    var rightTopLayer = CAShapeLayer()
    var leftBottomLayer = CAShapeLayer()
    var rightBottomLayer = CAShapeLayer()
    
    //条形码扫描的时候的红线
    var redLine : UIView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(QRCodeReaderView.creatDrawLine), name: NSNotification.Name(rawValue: "LAYERANIMATION"), object: nil)
        self.creatDataSource()
        self.setBottomBtnView()
        //条形码扫描的时候添加中间的红线
        self.addRedLineWithBarCodeScan()
    }
    
    
    override func draw(_ rect: CGRect) {
        var scanZoneSize = CGSize(width: kScreenWidth - self.defaultBothSideWidth * 2, height: kScreenWidth - self.defaultBothSideWidth * 2)
        if scanType == .barCode {
            scanZoneSize = CGSize(width: kScreenWidth - self.defaultBothSideWidth * 2, height: 150)
        }
        //获取扫描区域的坐标
        let x = self.defaultBothSideWidth
        let y = kScreenHeight / 2 - scanZoneSize.height / 2
        let scanRect = CGRect(x: x, y: y, width: scanZoneSize.width, height: scanZoneSize.height)
        self.creatOtherView(scanRect)
        //设置扫描区域
        let rect = self.creatScanZone(scanRect)
        outPut.rectOfInterest = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height)
        
        //设置扫描区域的线框
        self.setScanZoneLineBorder(scanRect)
        
        
    }
    
//MARK: ---条形码扫描的时候添加中间的红线
    func addRedLineWithBarCodeScan() {
        if self.redLine == nil {
            self.redLine = UIView()
            self.redLine?.center = self.center
            self.redLine?.bounds = CGRect(x: 0, y: 0, width: kScreenWidth - 60 * 2 - 20, height: 1.5)
            self.redLine?.backgroundColor = UIColor.red
            self.addSubview(self.redLine!)
            self.redLine?.isHidden = true
        }
    }
    
//MARK: ---设置扫描区域的线框
    func setScanZoneLineBorder(_ scanRect : CGRect) {
        leftTopLayer.removeFromSuperlayer()
        rightTopLayer.removeFromSuperlayer()
        leftBottomLayer.removeFromSuperlayer()
        rightBottomLayer.removeFromSuperlayer()
        //左上角的框
        let leftTopBezierPath = UIBezierPath()
        leftTopBezierPath.move(to: CGPoint(x: scanRect.minX + 15, y: scanRect.minY - 2))
        leftTopBezierPath.addLine(to: CGPoint(x: scanRect.minX - 2, y: scanRect.minY - 2))
        leftTopBezierPath.addLine(to: CGPoint(x: scanRect.minX - 2, y: scanRect.minY + 15))
        leftTopLayer.path = leftTopBezierPath.cgPath
        leftTopLayer.lineWidth = 4
        leftTopLayer.strokeColor = UIColor.green.cgColor
        leftTopLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(leftTopLayer)
        
        //右上角的框
        let rightTopBezierPath = UIBezierPath()
        rightTopBezierPath.move(to: CGPoint(x: scanRect.maxX - 15, y: scanRect.minY - 2))
        rightTopBezierPath.addLine(to: CGPoint(x: scanRect.maxX + 2, y: scanRect.minY - 2))
        rightTopBezierPath.addLine(to: CGPoint(x: scanRect.maxX + 2, y: scanRect.minY + 15))
        rightTopLayer.path = rightTopBezierPath.cgPath
        rightTopLayer.lineWidth = 4
        rightTopLayer.strokeColor = UIColor.green.cgColor
        rightTopLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(rightTopLayer)
        
        //左下角
        let leftBottomBezierPath = UIBezierPath()
        leftBottomBezierPath.move(to: CGPoint(x: scanRect.minX + 15, y: scanRect.maxY + 2))
        leftBottomBezierPath.addLine(to: CGPoint(x: scanRect.minX - 2, y: scanRect.maxY + 2))
        leftBottomBezierPath.addLine(to: CGPoint(x: scanRect.minX - 2, y: scanRect.maxY - 15))
        leftBottomLayer.path = leftBottomBezierPath.cgPath
        leftBottomLayer.lineWidth = 4
        leftBottomLayer.strokeColor = UIColor.green.cgColor
        leftBottomLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(leftBottomLayer)
        
        
        //右下角
        let rightBottomBezierPath = UIBezierPath()
        rightBottomBezierPath.move(to: CGPoint(x: scanRect.maxX + 2, y: scanRect.maxY - 15))
        rightBottomBezierPath.addLine(to: CGPoint(x: scanRect.maxX + 2, y: scanRect.maxY + 2))
        rightBottomBezierPath.addLine(to: CGPoint(x: scanRect.maxX - 15, y: scanRect.maxY + 2))
        rightBottomLayer.path = rightBottomBezierPath.cgPath
        rightBottomLayer.lineWidth = 4
        rightBottomLayer.strokeColor = UIColor.green.cgColor
        rightBottomLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(rightBottomLayer)

    }
    
//MARK: ---创建扫描需要的条件
    func creatDataSource() {
        self.captureSession = AVCaptureSession()
        self.captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        //创建输入流
        do {
            input = try AVCaptureDeviceInput(device: device)
            
        } catch let error as NSError{
            print("AVCaptureDeviceInput(): \(error)")
        }
        if input != nil {
            self.captureSession?.addInput(input)
        }
        
        outPut = AVCaptureMetadataOutput()
        
        if device == nil {
            return
        }
        //参数设置
        outPut.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        self.captureSession?.addOutput(outPut)
        
        //设置元数据类型（二维码和条形码都支持）
        outPut.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
        
        //设置采集的质量
        self.captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: self.captureSession)
        
        //layer进行裁剪
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.videoPreviewLayer?.frame = self.layer.bounds
        self.layer.insertSublayer(self.videoPreviewLayer!, at: 0)
        
        //设置聚焦(不是说所有的设备都支持，所以需要判断)
        if device!.isFocusPointOfInterestSupported && device!.isFocusModeSupported(AVCaptureFocusMode.continuousAutoFocus) {
            do {
                try self.input?.device.lockForConfiguration()
                self.input?.device.focusMode = AVCaptureFocusMode.continuousAutoFocus
                self.input?.device.unlockForConfiguration()
            }catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
            }
        }

    }
    
//MARK: ---设置扫描区域的边框
    func setScanZoneBorder(imageViewScan : UIImageView) {
        let leftTopImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        leftTopImageView.image = UIImage(named: "ScanQR1_16x16_")
        leftTopImageView.backgroundColor = UIColor.clear
        imageViewScan.addSubview(leftTopImageView)
        
        let rightopImageView = UIImageView.init(frame: CGRect(x: imageViewScan.frame.width - 20, y: 0, width: 20, height: 20))
        rightopImageView.image = UIImage(named: "ScanQR2_16x16_")
        rightopImageView.backgroundColor = UIColor.clear
        imageViewScan.addSubview(rightopImageView)
        
        
        let righBottomImageView = UIImageView.init(frame: CGRect(x: imageViewScan.frame.width - 20, y: imageViewScan.frame.height - 20, width: 20, height: 20))
        righBottomImageView.image = UIImage(named: "ScanQR4_16x16_")
        righBottomImageView.backgroundColor = UIColor.clear
        imageViewScan.addSubview(righBottomImageView)
        
        let leftBottomImageView = UIImageView.init(frame: CGRect(x: 0, y: imageViewScan.frame.height - 20, width: 20, height: 20))
        leftBottomImageView.image = UIImage(named: "ScanQR3_16x16_")
        leftBottomImageView.backgroundColor = UIColor.clear
        imageViewScan.addSubview(leftBottomImageView)
    }
    
//MARK: ---扫描线
    func creatDrawLine() {
        
        let rect = CGRect(x: 60 + 10, y: (kScreenHeight - (kScreenWidth - 60 * 2)) / 2, width: kScreenWidth - 60 * 2 - 20, height: 2)
        if self.lineImageView == nil {
        self.lineImageView = UIImageView.init(frame: rect)
        self.lineImageView?.image = UIImage(named: "line-1")
        self.addSubview(self.lineImageView!)
        }
        
        let transitionAnimation = CABasicAnimation.init(keyPath: "position")
        transitionAnimation.fromValue = NSValue.init(cgPoint: CGPoint(x: 60 + (kScreenWidth - 60 * 2) / 2, y: (kScreenHeight - (kScreenWidth - 60 * 2)) / 2))
        transitionAnimation.toValue = NSValue.init(cgPoint: CGPoint( x: 60 + (kScreenWidth - 60 * 2) / 2, y: kScreenHeight / 2 + (kScreenWidth - 60 * 2) / 2))
        transitionAnimation.duration = 1.8
        transitionAnimation.repeatCount = 999
        transitionAnimation.autoreverses = true
        self.lineImageView?.layer.add(transitionAnimation, forKey: "transitionAnimation")
    }

//MARK: ---暂停动画的方法
    func stopLineAnimation() {
        let pauseTime = self.lineImageView?.layer.convertTime(CACurrentMediaTime(), from: nil)
        self.lineImageView?.layer.speed = 0
        self.lineImageView?.layer.timeOffset = pauseTime!
    }
//MARK: ---继续动画的方法
    func startLineAnimation() {
        let pauseTime = self.lineImageView?.layer.timeOffset
        self.lineImageView?.layer.speed = 1
        self.lineImageView?.layer.beginTime = 0
        self.lineImageView?.layer.timeOffset = 0
        let timeSincePause = (self.lineImageView?.layer.convertTime(CACurrentMediaTime(), from: nil))! - pauseTime!
        self.lineImageView?.layer.beginTime = timeSincePause

    }
    
    func creatOtherView(_ scanRect : CGRect) {
        let allAlpha : CGFloat = 0.5

        //最上部的View
        if topView != nil {
            topView?.removeFromSuperview()
            topView = nil
        }
        topView = UIView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: scanRect.origin.y))
        topView!.alpha = allAlpha
        topView!.backgroundColor = UIColor.black
        self.addSubview(topView!)
        
        //左侧的View
        if leftView != nil {
            leftView?.removeFromSuperview()
            leftView = nil
        }
        leftView = UIView.init(frame: CGRect(x: 0, y: scanRect.origin.y, width: self.defaultBothSideWidth, height: scanRect.size.height))
        leftView!.backgroundColor = UIColor.black
        leftView!.alpha = allAlpha
        self.addSubview(leftView!)
        
        
        //右侧的View
        if rightView != nil {
            rightView?.removeFromSuperview()
            rightView = nil
        }
        rightView = UIView.init(frame: CGRect(x: scanRect.maxX, y: scanRect.origin.y, width: self.defaultBothSideWidth, height: scanRect.size.height))
        rightView!.backgroundColor = UIColor.black
        rightView!.alpha = allAlpha
        self.addSubview(rightView!)
        
        
        //底部的View
        if bottomView != nil {
            bottomView?.removeFromSuperview()
            bottomView = nil
        }
        bottomView = UIView.init(frame: CGRect(x: 0,y: scanRect.maxY, width: kScreenWidth, height: kScreenHeight - scanRect.maxY - 100))
        bottomView!.backgroundColor = UIColor.black
        bottomView!.alpha = allAlpha
        self.addSubview(bottomView!)
        
        let detailLabel = UILabel.init(frame: CGRect(x: 0, y: 10, width: kScreenWidth, height: 20))
        detailLabel.backgroundColor = UIColor.clear
        detailLabel.textColor = UIColor.white
        if self.scanType == .barCode {
            detailLabel.text = "将条形码放入框内，即可自动扫描"
        }else{
            detailLabel.text = "将二维码放入框内，即可自动扫描"
        }
        
        
        detailLabel.font = UIFont.systemFont(ofSize: 16)
        detailLabel.textAlignment = .center
        bottomView!.addSubview(detailLabel)
        
        //我的二维码
        let mineBtn = UIButton.init(frame: CGRect(x: (kScreenWidth - 150) / 2, y: 40, width: 150, height: 40))
        mineBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        mineBtn.setTitle("我的二维码", for: UIControlState())
        mineBtn.setTitleColor(UIColor.white, for: UIControlState())
        mineBtn.setImage(UIImage.init(named: "erweima_1"), for: UIControlState())
        mineBtn.layer.cornerRadius = 20
        mineBtn.backgroundColor = UIColor.black
        mineBtn.layoutButtonWithEdgesInsetsStyleWithSpace(.left, space: 10)
        mineBtn.addTarget(self, action: #selector(QRCodeReaderView.pushInMineQRCode), for: .touchUpInside)
        bottomView!.addSubview(mineBtn)
        if self.scanType == .barCode {
            mineBtn.isHidden = true
        }else{
            mineBtn.isHidden = false
        }
    }

 
//MARK: ---设置底部的按钮
    func setBottomBtnView() {
        //设置底部的按钮View
        let btnBottomViewHeight : CGFloat = 100
        btnBottomView = UIView.init(frame: CGRect(x: 0, y: kScreenHeight - btnBottomViewHeight, width: kScreenWidth, height: btnBottomViewHeight))
        btnBottomView.backgroundColor = UIColor.black
        btnBottomView.alpha = 0.8
        self.addSubview(btnBottomView)
        self.bringSubview(toFront: btnBottomView)
        
        //二维码
        let width = kScreenWidth / 3
        leftQRCodeBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: width, height: btnBottomViewHeight))
        leftQRCodeBtn.setImage(UIImage(named: "qrcode_scan_btn_myqrcode_down"), for: .selected)
        leftQRCodeBtn.setImage(UIImage(named: "qrcode_scan_btn_myqrcode_nor"), for: UIControlState())
        leftQRCodeBtn.setTitle("二维码", for: UIControlState())
        leftQRCodeBtn.layoutButtonWithEdgesInsetsStyleWithSpace(.top, space: 10)
        leftQRCodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        leftQRCodeBtn.addTarget(self, action: #selector(QRCodeReaderView.scanQRCode(_:)), for: .touchUpInside)
        btnBottomView.addSubview(leftQRCodeBtn)
        leftQRCodeBtn.isSelected = true
        //开灯
        let lightBtn = UIButton.init(frame: CGRect(x: width, y: 0, width: width, height: btnBottomViewHeight))
        lightBtn.setImage(UIImage(named: "qrcode_scan_btn_flash_on"), for: .selected)
        lightBtn.setImage(UIImage(named: "qrcode_scan_btn_flash_off"), for: UIControlState())
        lightBtn.setTitle("开灯", for: UIControlState())
        lightBtn.setTitle("关灯", for: .selected)
        lightBtn.layoutButtonWithEdgesInsetsStyleWithSpace(.top, space: 10)
        lightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        lightBtn.addTarget(self, action: #selector(QRCodeReaderView.turnOnOrOffWigthLight(_:)), for: .touchUpInside)
        btnBottomView.addSubview(lightBtn)
        
        //条形码
        barCodeBtn = UIButton.init(frame: CGRect(x: width * 2, y: 0, width: width, height: btnBottomViewHeight))
        barCodeBtn.setImage(UIImage(named: "barcodeScan0"), for: .selected)
        barCodeBtn.setImage(UIImage(named: "barcodeScan1"), for: UIControlState())
        barCodeBtn.setTitle("条形码", for: UIControlState())
        barCodeBtn.layoutButtonWithEdgesInsetsStyleWithSpace(.top, space: 10)
        barCodeBtn.addTarget(self, action: #selector(QRCodeReaderView.scanBarCode(_:)), for: .touchUpInside)
        barCodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btnBottomView.addSubview(barCodeBtn)
    }
    
//MARK: ---点击开灯按钮的事件
    func turnOnOrOffWigthLight(_ sender : UIButton) {
        sender.isSelected = sender.isSelected ? false : true
        self.theLightIsON(sender.isSelected)
    }
//MARK: ---开灯或者关灯
    func theLightIsON(_ turnLight : Bool){
        if device != nil && device!.hasTorch {
            do{
                try input?.device.lockForConfiguration()
                input?.device.torchMode = turnLight ? AVCaptureTorchMode.on : AVCaptureTorchMode.off
                input?.device.unlockForConfiguration()
            }catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
            }
        }
    }
    
//MARK: ---扫描二维码
    func scanQRCode(_ sender : UIButton) {
        if sender.isSelected {
            return
        }
        leftQRCodeBtn.isSelected = true
        barCodeBtn.isSelected = false
        self.scanType = .qrCode
        self.setNeedsDisplay()
        self.lineImageView?.isHidden = false
        self.redLine?.isHidden = true
    }
    
//MARK: ---扫描条形码
    func scanBarCode(_ sender : UIButton) {
        if sender.isSelected {
            return
        }
        leftQRCodeBtn.isSelected = false
        barCodeBtn.isSelected = true
        self.scanType = .barCode
        self.setNeedsDisplay()
        self.lineImageView?.isHidden = true
        self.redLine?.isHidden = false
    }
    
//MARK: ---进入我的二维码试图控制器
    func pushInMineQRCode() {
        if self.puinMyCodeController != nil {
            self.puinMyCodeController!()
        }
    }
//MARK: ---创建扫描区域
    func creatScanZone(_ rect: CGRect) -> CGRect {
        var x = CGFloat()
        var y = CGFloat()
        var width = CGFloat()
        var height = CGFloat()
        x = (self.frame.height - rect.height) / 2 / self.frame.height
        y = (self.frame.width - rect.width) / 2 / self.frame.width
        width = rect.height / self.frame.height
        height = rect.width / self.frame.width
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
//MARK: ---开始扫描
    func start() {
        if Platform.isSimulator {
            // Do one thing
            print("Please use real machine operation, no this function  of simulator")
        }
        else {
            // Do the other
            self.captureSession?.startRunning()
        }
        
    }
    
//MARK: ---停止
    func stop() {
        self.captureSession?.stopRunning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//MARK: ---得到扫描结果
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if self.scanType != .barCode {
            self.stopLineAnimation()
        }
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            //扫描结果返回试图控制器进行处理
            if self.delegate != nil{
                self.delegate?.handelTheResult(metadataObject.stringValue)
            }

        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
