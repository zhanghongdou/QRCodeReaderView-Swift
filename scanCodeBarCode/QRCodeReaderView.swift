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
    func handelTheResult(metadataObjectString: String) -> Void
}
extension HandleTheResultDelegate {
    func handelTheResult(metadataObjectString: String) -> Void {}
}
//enum DAOError: ErrorType {
//    case NoData
//    case NullKey
//}

//设置扫描的结构体
enum ScanQRCodeType: Int {
    case QRCode = 1
    case BarCode
}

class QRCodeReaderView: UIView, AVCaptureMetadataOutputObjectsDelegate{
    let device:AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
    var puinMyCodeController : putInMyQRCodeController?
    var captureSession : AVCaptureSession?
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    var lastResult = Bool()
    var isAnmotion = false
    var lineImageView : UIImageView?
    var delegate : HandleTheResultDelegate?
    var input : AVCaptureDeviceInput?
    //创建输出流
    let outPut = AVCaptureMetadataOutput()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(QRCodeReaderView.creatDrawLine), name: "LAYERANIMATION", object: nil)
        self.creatDataSource()
        self.setBottomBtnView()
        //条形码扫描的时候添加中间的红线
        self.addRedLineWithBarCodeScan()
    }
    
    
    override func drawRect(rect: CGRect) {
        var scanZoneSize = CGSizeMake(kScreenWidth - self.defaultBothSideWidth * 2, kScreenWidth - self.defaultBothSideWidth * 2)
        if scanType == .BarCode {
            scanZoneSize = CGSizeMake(kScreenWidth - self.defaultBothSideWidth * 2, 150)
        }
        //获取扫描区域的坐标
        let x = self.defaultBothSideWidth
        let y = kScreenHeight / 2 - scanZoneSize.height / 2
        let scanRect = CGRectMake(x, y, scanZoneSize.width, scanZoneSize.height)
        self.creatOtherView(scanRect)
        //设置扫描区域
        let rect = self.creatScanZone(scanRect)
        outPut.rectOfInterest = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
        
        //设置扫描区域的线框
        self.setScanZoneLineBorder(scanRect)
        
        
    }
    
//MARK: ---条形码扫描的时候添加中间的红线
    func addRedLineWithBarCodeScan() {
        if self.redLine == nil {
            self.redLine = UIView()
            self.redLine?.center = self.center
            self.redLine?.bounds = CGRectMake(0, 0, kScreenWidth - 60 * 2 - 20, 1.5)
            self.redLine?.backgroundColor = UIColor.redColor()
            self.addSubview(self.redLine!)
            self.redLine?.hidden = true
        }
    }
    
//MARK: ---设置扫描区域的线框
    func setScanZoneLineBorder(scanRect : CGRect) {
        leftTopLayer.removeFromSuperlayer()
        rightTopLayer.removeFromSuperlayer()
        leftBottomLayer.removeFromSuperlayer()
        rightBottomLayer.removeFromSuperlayer()
        //左上角的框
        let leftTopBezierPath = UIBezierPath()
        leftTopBezierPath.moveToPoint(CGPointMake(CGRectGetMinX(scanRect) + 15, CGRectGetMinY(scanRect) - 2))
        leftTopBezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(scanRect) - 2, CGRectGetMinY(scanRect) - 2))
        leftTopBezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(scanRect) - 2, CGRectGetMinY(scanRect) + 15))
        leftTopLayer.path = leftTopBezierPath.CGPath
        leftTopLayer.lineWidth = 4
        leftTopLayer.strokeColor = UIColor.greenColor().CGColor
        leftTopLayer.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(leftTopLayer)
        
        //右上角的框
        let rightTopBezierPath = UIBezierPath()
        rightTopBezierPath.moveToPoint(CGPointMake(CGRectGetMaxX(scanRect) - 15, CGRectGetMinY(scanRect) - 2))
        rightTopBezierPath.addLineToPoint(CGPointMake(CGRectGetMaxX(scanRect) + 2, CGRectGetMinY(scanRect) - 2))
        rightTopBezierPath.addLineToPoint(CGPointMake(CGRectGetMaxX(scanRect) + 2, CGRectGetMinY(scanRect) + 15))
        rightTopLayer.path = rightTopBezierPath.CGPath
        rightTopLayer.lineWidth = 4
        rightTopLayer.strokeColor = UIColor.greenColor().CGColor
        rightTopLayer.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(rightTopLayer)
        
        //左下角
        let leftBottomBezierPath = UIBezierPath()
        leftBottomBezierPath.moveToPoint(CGPointMake(CGRectGetMinX(scanRect) + 15, CGRectGetMaxY(scanRect) + 2))
        leftBottomBezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(scanRect) - 2, CGRectGetMaxY(scanRect) + 2))
        leftBottomBezierPath.addLineToPoint(CGPointMake(CGRectGetMinX(scanRect) - 2, CGRectGetMaxY(scanRect) - 15))
        leftBottomLayer.path = leftBottomBezierPath.CGPath
        leftBottomLayer.lineWidth = 4
        leftBottomLayer.strokeColor = UIColor.greenColor().CGColor
        leftBottomLayer.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(leftBottomLayer)
        
        
        //右下角
        let rightBottomBezierPath = UIBezierPath()
        rightBottomBezierPath.moveToPoint(CGPointMake(CGRectGetMaxX(scanRect) + 2, CGRectGetMaxY(scanRect) - 15))
        rightBottomBezierPath.addLineToPoint(CGPointMake(CGRectGetMaxX(scanRect) + 2, CGRectGetMaxY(scanRect) + 2))
        rightBottomBezierPath.addLineToPoint(CGPointMake(CGRectGetMaxX(scanRect) - 15, CGRectGetMaxY(scanRect) + 2))
        rightBottomLayer.path = rightBottomBezierPath.CGPath
        rightBottomLayer.lineWidth = 4
        rightBottomLayer.strokeColor = UIColor.greenColor().CGColor
        rightBottomLayer.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(rightBottomLayer)

    }
    
//MARK: ---创建扫描需要的条件
    func creatDataSource() {
        self.captureSession = AVCaptureSession()
        self.captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        //创建输入流
        do {
            //这里需要在真机运行，否则就会出错
            input = try AVCaptureDeviceInput(device: device)
            if self.input != nil {
                self.captureSession?.addInput(self.input)
            }
        } catch let error as NSError{
            print("AVCaptureDeviceInput(): \(error)")
        }
        
        //参数设置
        outPut.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        self.captureSession?.addOutput(outPut)
        
        //设置元数据类型（二维码和条形码都支持）
        outPut.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
        
        //设置采集的质量
        self.captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: self.captureSession)
        
        //layer进行裁剪
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.videoPreviewLayer?.frame = self.layer.bounds
        self.layer.insertSublayer(self.videoPreviewLayer!, atIndex: 0)
        
        //设置聚焦(不是说所有的设备都支持，所以需要判断)
        if device!.focusPointOfInterestSupported && device!.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus) {
            do {
                try self.input?.device.lockForConfiguration()
                self.input?.device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                self.input?.device.unlockForConfiguration()
            }catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
            }
        }

    }
    
//MARK: ---设置扫描区域的边框
    func setScanZoneBorder(imageViewScan imageViewScan : UIImageView) {
        let leftTopImageView = UIImageView.init(frame: CGRectMake(0, 0, 20, 20))
        leftTopImageView.image = UIImage(named: "ScanQR1_16x16_")
        leftTopImageView.backgroundColor = UIColor.clearColor()
        imageViewScan.addSubview(leftTopImageView)
        
        let rightopImageView = UIImageView.init(frame: CGRectMake(imageViewScan.frame.width - 20, 0, 20, 20))
        rightopImageView.image = UIImage(named: "ScanQR2_16x16_")
        rightopImageView.backgroundColor = UIColor.clearColor()
        imageViewScan.addSubview(rightopImageView)
        
        
        let righBottomImageView = UIImageView.init(frame: CGRectMake(imageViewScan.frame.width - 20, imageViewScan.frame.height - 20, 20, 20))
        righBottomImageView.image = UIImage(named: "ScanQR4_16x16_")
        righBottomImageView.backgroundColor = UIColor.clearColor()
        imageViewScan.addSubview(righBottomImageView)
        
        let leftBottomImageView = UIImageView.init(frame: CGRectMake(0, imageViewScan.frame.height - 20, 20, 20))
        leftBottomImageView.image = UIImage(named: "ScanQR3_16x16_")
        leftBottomImageView.backgroundColor = UIColor.clearColor()
        imageViewScan.addSubview(leftBottomImageView)
    }
    
//MARK: ---扫描线
    func creatDrawLine() {
        
        let rect = CGRectMake(60 + 10, (kScreenHeight - (kScreenWidth - 60 * 2)) / 2, kScreenWidth - 60 * 2 - 20, 2)
        if self.lineImageView == nil {
        self.lineImageView = UIImageView.init(frame: rect)
        self.lineImageView?.image = UIImage(named: "line-1")
        self.addSubview(self.lineImageView!)
        }
        
        let transitionAnimation = CABasicAnimation.init(keyPath: "position")
        transitionAnimation.fromValue = NSValue.init(CGPoint: CGPointMake(60 + (kScreenWidth - 60 * 2) / 2, (kScreenHeight - (kScreenWidth - 60 * 2)) / 2))
        transitionAnimation.toValue = NSValue.init(CGPoint: CGPointMake( 60 + (kScreenWidth - 60 * 2) / 2, kScreenHeight / 2 + (kScreenWidth - 60 * 2) / 2))
        transitionAnimation.duration = 1.8
        transitionAnimation.repeatCount = 999
        transitionAnimation.autoreverses = true
        self.lineImageView?.layer.addAnimation(transitionAnimation, forKey: "transitionAnimation")
    }

//MARK: ---暂停动画的方法
    func stopLineAnimation() {
        let pauseTime = self.lineImageView?.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        self.lineImageView?.layer.speed = 0
        self.lineImageView?.layer.timeOffset = pauseTime!
    }
//MARK: ---继续动画的方法
    func startLineAnimation() {
        let pauseTime = self.lineImageView?.layer.timeOffset
        self.lineImageView?.layer.speed = 1
        self.lineImageView?.layer.beginTime = 0
        self.lineImageView?.layer.timeOffset = 0
        let timeSincePause = (self.lineImageView?.layer.convertTime(CACurrentMediaTime(), fromLayer: nil))! - pauseTime!
        self.lineImageView?.layer.beginTime = timeSincePause

    }
    
    func creatOtherView(scanRect : CGRect) {
        let allAlpha : CGFloat = 0.5

        //最上部的View
        if topView != nil {
            topView?.removeFromSuperview()
            topView = nil
        }
        topView = UIView.init(frame: CGRectMake(0, 0, kScreenWidth, scanRect.origin.y))
        topView!.alpha = allAlpha
        topView!.backgroundColor = UIColor.blackColor()
        self.addSubview(topView!)
        
        //左侧的View
        if leftView != nil {
            leftView?.removeFromSuperview()
            leftView = nil
        }
        leftView = UIView.init(frame: CGRectMake(0, scanRect.origin.y, self.defaultBothSideWidth, scanRect.size.height))
        leftView!.backgroundColor = UIColor.blackColor()
        leftView!.alpha = allAlpha
        self.addSubview(leftView!)
        
        
        //右侧的View
        if rightView != nil {
            rightView?.removeFromSuperview()
            rightView = nil
        }
        rightView = UIView.init(frame: CGRectMake(CGRectGetMaxX(scanRect), scanRect.origin.y, self.defaultBothSideWidth, scanRect.size.height))
        rightView!.backgroundColor = UIColor.blackColor()
        rightView!.alpha = allAlpha
        self.addSubview(rightView!)
        
        
        //底部的View
        if bottomView != nil {
            bottomView?.removeFromSuperview()
            bottomView = nil
        }
        bottomView = UIView.init(frame: CGRectMake(0,CGRectGetMaxY(scanRect), kScreenWidth, kScreenHeight - CGRectGetMaxY(scanRect) - 100))
        bottomView!.backgroundColor = UIColor.blackColor()
        bottomView!.alpha = allAlpha
        self.addSubview(bottomView!)
        
        let detailLabel = UILabel.init(frame: CGRectMake(0, 10, kScreenWidth, 20))
        detailLabel.backgroundColor = UIColor.clearColor()
        detailLabel.textColor = UIColor.whiteColor()
        if self.scanType == .BarCode {
            detailLabel.text = "将条形码放入框内，即可自动扫描"
        }else{
            detailLabel.text = "将二维码放入框内，即可自动扫描"
        }
        
        
        detailLabel.font = UIFont.systemFontOfSize(16)
        detailLabel.textAlignment = .Center
        bottomView!.addSubview(detailLabel)
        
        //我的二维码
        let mineBtn = UIButton.init(frame: CGRectMake((kScreenWidth - 150) / 2, 40, 150, 40))
        mineBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        mineBtn.setTitle("我的二维码", forState: .Normal)
        mineBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        mineBtn.setImage(UIImage.init(named: "erweima_1"), forState: .Normal)
        mineBtn.layer.cornerRadius = 20
        mineBtn.backgroundColor = UIColor.blackColor()
        mineBtn.layoutButtonWithEdgesInsetsStyleWithSpace(.Left, space: 10)
        mineBtn.addTarget(self, action: #selector(QRCodeReaderView.pushInMineQRCode), forControlEvents: .TouchUpInside)
        bottomView!.addSubview(mineBtn)
        if self.scanType == .BarCode {
            mineBtn.hidden = true
        }else{
            mineBtn.hidden = false
        }
    }

 
//MARK: ---设置底部的按钮
    func setBottomBtnView() {
        //设置底部的按钮View
        let btnBottomViewHeight : CGFloat = 100
        btnBottomView = UIView.init(frame: CGRectMake(0, kScreenHeight - btnBottomViewHeight, kScreenWidth, btnBottomViewHeight))
        btnBottomView.backgroundColor = UIColor.blackColor()
        btnBottomView.alpha = 0.8
        self.addSubview(btnBottomView)
        self.bringSubviewToFront(btnBottomView)
        
        //二维码
        let width = kScreenWidth / 3
        leftQRCodeBtn = UIButton.init(frame: CGRectMake(0, 0, width, btnBottomViewHeight))
        leftQRCodeBtn.setImage(UIImage(named: "qrcode_scan_btn_myqrcode_down"), forState: .Selected)
        leftQRCodeBtn.setImage(UIImage(named: "qrcode_scan_btn_myqrcode_nor"), forState: .Normal)
        leftQRCodeBtn.setTitle("二维码", forState: .Normal)
        leftQRCodeBtn.layoutButtonWithEdgesInsetsStyleWithSpace(.Top, space: 10)
        leftQRCodeBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        leftQRCodeBtn.addTarget(self, action: #selector(QRCodeReaderView.scanQRCode(_:)), forControlEvents: .TouchUpInside)
        btnBottomView.addSubview(leftQRCodeBtn)
        leftQRCodeBtn.selected = true
        //开灯
        let lightBtn = UIButton.init(frame: CGRectMake(width, 0, width, btnBottomViewHeight))
        lightBtn.setImage(UIImage(named: "qrcode_scan_btn_flash_on"), forState: .Selected)
        lightBtn.setImage(UIImage(named: "qrcode_scan_btn_flash_off"), forState: .Normal)
        lightBtn.setTitle("开灯", forState: .Normal)
        lightBtn.setTitle("关灯", forState: .Selected)
        lightBtn.layoutButtonWithEdgesInsetsStyleWithSpace(.Top, space: 10)
        lightBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        lightBtn.addTarget(self, action: #selector(QRCodeReaderView.turnOnOrOffWigthLight(_:)), forControlEvents: .TouchUpInside)
        btnBottomView.addSubview(lightBtn)
        
        //条形码
        barCodeBtn = UIButton.init(frame: CGRectMake(width * 2, 0, width, btnBottomViewHeight))
        barCodeBtn.setImage(UIImage(named: "barcodeScan0"), forState: .Selected)
        barCodeBtn.setImage(UIImage(named: "barcodeScan1"), forState: .Normal)
        barCodeBtn.setTitle("条形码", forState: .Normal)
        barCodeBtn.layoutButtonWithEdgesInsetsStyleWithSpace(.Top, space: 10)
        barCodeBtn.addTarget(self, action: #selector(QRCodeReaderView.scanBarCode(_:)), forControlEvents: .TouchUpInside)
        barCodeBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        btnBottomView.addSubview(barCodeBtn)
    }
    
//MARK: ---点击开灯按钮的事件
    func turnOnOrOffWigthLight(sender : UIButton) {
        sender.selected = sender.selected ? false : true
        self.theLightIsON(sender.selected)
    }
//MARK: ---开灯或者关灯
    func theLightIsON(turnLight : Bool){
        if device != nil && device!.hasTorch {
            do{
                try input?.device.lockForConfiguration()
                input?.device.torchMode = turnLight ? AVCaptureTorchMode.On : AVCaptureTorchMode.Off
                input?.device.unlockForConfiguration()
            }catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
            }
        }
    }
    
//MARK: ---扫描二维码
    func scanQRCode(sender : UIButton) {
        if sender.selected {
            return
        }
        leftQRCodeBtn.selected = true
        barCodeBtn.selected = false
        self.scanType = .QRCode
        self.setNeedsDisplay()
        self.lineImageView?.hidden = false
        self.redLine?.hidden = true
    }
    
//MARK: ---扫描条形码
    func scanBarCode(sender : UIButton) {
        if sender.selected {
            return
        }
        leftQRCodeBtn.selected = false
        barCodeBtn.selected = true
        self.scanType = .BarCode
        self.setNeedsDisplay()
        self.lineImageView?.hidden = true
        self.redLine?.hidden = false
    }
    
//MARK: ---进入我的二维码试图控制器
    func pushInMineQRCode() {
        if self.puinMyCodeController != nil {
            self.puinMyCodeController!()
        }
    }
//MARK: ---创建扫描区域
    func creatScanZone(rect: CGRect) -> CGRect {
        var x = CGFloat()
        var y = CGFloat()
        var width = CGFloat()
        var height = CGFloat()
        x = (CGRectGetHeight(self.frame) - CGRectGetHeight(rect)) / 2 / CGRectGetHeight(self.frame)
        y = (CGRectGetWidth(self.frame) - CGRectGetWidth(rect)) / 2 / CGRectGetWidth(self.frame)
        width = CGRectGetHeight(rect) / CGRectGetHeight(self.frame)
        height = CGRectGetWidth(rect) / CGRectGetWidth(self.frame)
        return CGRectMake(x, y, width, height)
    }
    
//MARK: ---开始扫描
    func start() {
        self.captureSession?.startRunning()
    }
    
//MARK: ---停止
    func stop() {
        self.captureSession?.stopRunning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//MARK: ---得到扫描结果
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if self.scanType != .BarCode {
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

}
