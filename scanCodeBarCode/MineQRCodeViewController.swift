//
//  MineQRCodeViewController.swift
//  QRCodeScan
//
//  Created by haohao on 16/8/12.
//  Copyright © 2016年 haohao. All rights reserved.
//

import UIKit

class MineQRCodeViewController: UIViewController {

    @IBOutlet weak var codeImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.codeImageView.image = self.creatQRCodeOfMine(codeUrl: "www.baidu.com", width: 200, height: 200, baseColor: UIColor.whiteColor(), codeColor: UIColor.blackColor())
        
        //设置中心的图像
        self.setCenterImageView(UIImage(named: "QrDefault"))
    }

    func creatQRCodeOfMine(codeUrl codeUrl : String, width : CGFloat, height : CGFloat, baseColor : UIColor, codeColor : UIColor) -> UIImage {
        
        let data = codeUrl.dataUsingEncoding(NSUTF8StringEncoding)
        //系统自带的
        //        CIAztecCodeGenerator
        //        CICode128BarcodeGenerator
        //        CIPDF417BarcodeGenerator
        //        CIQRCodeGenerator
        //实例化二维码滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
//        //恢复滤镜的默认属性
//        filter?.setDefaults()
         //通过KVO设置滤镜inputMessage数据
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        //上色（设置二维码的底色和码色，input0是码色，input1是底色）
        let colorFilter = CIFilter(name: "CIFalseColor", withInputParameters: ["inputImage":filter!.outputImage!,"inputColor0":CIColor(CGColor: codeColor.CGColor),"inputColor1":CIColor(CGColor: baseColor.CGColor)])
        
        
        //获得滤镜输出的图像
        let qrCodeImage = colorFilter!.outputImage
        let scaleX = width / (qrCodeImage?.extent.size.width)!
        let scaleY = height / (qrCodeImage?.extent.size.height)!
        let transformedImage = qrCodeImage?.imageByApplyingTransform(CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY))
        return UIImage.init(CIImage: transformedImage!)
    }
    
    func setCenterImageView(centerImage : UIImage?) {
        let centerImageView = UIImageView()
        centerImageView.center = CGPointMake(self.codeImageView.frame.size.width / 2, self.codeImageView.frame.size.height / 2)
        centerImageView.bounds = CGRectMake(0, 0, 30, 30)
        centerImageView.layer.cornerRadius = 15
        self.codeImageView.addSubview(centerImageView)
        if centerImage != nil {
            centerImageView.image = centerImage
        }else{
            centerImageView.image = UIImage(named: "QrDefault")
        }
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
