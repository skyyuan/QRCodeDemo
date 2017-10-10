//
//  QRCodeTool.swift
//  二维码综合案例
//
//  Created by SPARKWYY on 2017/10/10.
//  Copyright © 2017年 SKOrganization. All rights reserved.
//

import UIKit
import AVFoundation
typealias ScanResultBlock = ([String]) -> ()
class QRCodeTool: NSObject {
    
    static let shareInstance = QRCodeTool()
    
    lazy var input:AVCaptureDeviceInput? = {
        // 1. 设置输入
        // 1.1 获取摄像头设备
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // 1.2 把摄像头设备当做输入设备
        var input:AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
            return input!
        } catch  {
            print(error)
            return nil
        }
        
    }()
    
    lazy var output:AVCaptureMetadataOutput = {
        // 2. 设置输出
        let output = AVCaptureMetadataOutput()
        // 2.1 设置结果处理的代理
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        return output
    }()
    
    lazy var session:AVCaptureSession = {
        // 3. 创建会话, 连接输入和输出
        let session = AVCaptureSession()
        return session
    }()
    
    lazy var layer:AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        return layer!
    }()
    
    fileprivate var scanResultBlock:ScanResultBlock?
    fileprivate var isDrawFrame:Bool = false
    
    //var layer:AVCaptureVideoPreviewLayer?
    /// 生成二维码
    ///
    /// - Parameters:
    ///   - inputStr: 二维码输入数据
    ///   - scaleX: X方向放大倍数
    ///   - scaleY: Y方向放大倍数
    ///   - centerImage: 是否有中间图片
    ///   - centerImageSize: 如果有中间图片,中间图片大小(有 必填; 无 可空)
    /// - Returns: 生成的图片
    class func createQRCode(inputStr:String,scaleX:CGFloat,scaleY:CGFloat,centerImage:UIImage?,centerImageSize:CGSize?) -> UIImage{
        // 1. 创建一个滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        // 1.1 恢复滤镜默认设置
        filter!.setDefaults()
        // 2 设置滤镜输入数据 利用KVC
        let inputData = inputStr.data(using: String.Encoding.utf8)
        filter!.setValue(inputData, forKey: "inputMessage")
        // 2.1 设置二维码的纠错率
        filter!.setValue("M", forKey: "inputCorrectionLevel")
        
        // 3. 从滤镜里面获取结果图片
        var Image = filter!.outputImage
        
        // 图片放大处理(否则图片模糊不清)
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        Image! = Image!.applying(transform)
        // 3.1图片处理
        var resultImage = UIImage(ciImage: Image!)
        // 前景图片
        if centerImage != nil && centerImageSize != nil{
            resultImage = self.getNewImage(sourceImage: resultImage, beforeImage: centerImage!,centerSize: centerImageSize!)
        }
        // 4.返回图片
        return resultImage
    }
    
    
    /// 图片识别二维码
    ///
    /// - Parameters:
    ///   - image: 二维码图片
    ///   - isDrawQRCodeFrame: 是否需要标注 识别的二维码
    /// - Returns: 二维码含有的信息, 和 标注识别的二维码的图片
    class func detectorQRCodeImage(image:UIImage, isDrawQRCodeFrame:Bool) -> (resultsStr:[String]?, resultImage:UIImage){
        
        let ciImage = CIImage(image: image)
        // 开始识别
        // CIDetectorTypeQRCode : 二维码
        // CIDetectorTypeFace : 脸部识别
        // CIDetectorTypeRectangle : 识别一个矩形的内容
        // CIDetectorTypeText : 文本识别
        
        
        // 1.创建一个二维码探测器
        let dector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        // 2.直接探测二维码特征
        let features = dector!.features(in: ciImage!)
        var resultImage = image
        var results = [String]()
        for feature in features {
            let qrFeature = feature as! CIQRCodeFeature
            // 二维码的含有的信息
            results.append(qrFeature.messageString!)
            //print(qrFeature.bounds) // 二维码的大小
            if isDrawQRCodeFrame{
                resultImage = self.drawFrame(image: resultImage, feature: qrFeature)
            }
        }
        return (results, resultImage)
    }
    
    func scanQRCode(inView:UIView, isDrawFrame:Bool, resultBlock:@escaping ScanResultBlock){
        
        // 记录闭包
        self.scanResultBlock = resultBlock
        self.isDrawFrame = isDrawFrame
        
        if session.canAddInput(input) && session.canAddOutput(output) {
            session.addInput(input)
            session.addOutput(output)
        }else{
            return
        }
        
        // 3.1 设置二维码可以识别的码制
        // 设置是被的类型,必须要在输出添加到会话之后,才可以设置, 不然会崩溃
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        // 3.2 添加视频预览图层(让用户可以看到界面)
        
        if inView.layer.sublayers == nil{
            self.layer.frame = inView.layer.bounds
            inView.layer.insertSublayer(self.layer, at: 0)
        }else{
            let subLayers = inView.layer.sublayers
            if !subLayers!.contains(self.layer) {
                self.layer.frame = inView.layer.bounds
                inView.layer.insertSublayer(self.layer, at: 0)
            }
        }
        
        // 4. 启动会话，（让输入开始采集数据，输出对象，开始处理数据）
        session.startRunning()
        
        
    }
    
    
    func setRectInterrest(orginRect:CGRect) -> Void {
        // 设置扫描 的兴趣区域
        // CGRectMake(0, 0, 1, 1) 0.0 -> 1.0
        let bounds = UIScreen.main.bounds
        let x:CGFloat = orginRect.origin.x / bounds.size.width
        let y:CGFloat = orginRect.origin.y / bounds.size.height
        let width:CGFloat = orginRect.size.width / bounds.size.width
        let height:CGFloat = orginRect.size.height / bounds.size.height
        
        output.rectOfInterest = CGRect(x: y, y: x, width: height, height: width)
    }
    
}

// 私有方法
extension QRCodeTool {
    
    class func getNewImage(sourceImage:UIImage, beforeImage:UIImage,centerSize:CGSize) -> UIImage {
        let size = sourceImage.size
        // 1.开启图形上下文
        UIGraphicsBeginImageContext(size)
        // 2.绘制大图片
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // 3.绘制小图片
        let width:CGFloat = centerSize.width // 大小自定义
        let height:CGFloat = centerSize.height // 大小自定义
        let x:CGFloat = (size.width - width) * 0.5
        let y:CGFloat = (size.height - height) * 0.5
        beforeImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        
        // 4.取出结果图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        // 5.关闭上下文
        UIGraphicsEndImageContext()
        // 6.返回结果图片
        return resultImage!
    }
    
    class func drawFrame(image:UIImage, feature:CIQRCodeFeature) -> UIImage {
        
        let size = image.size
        // 1.开启图形上下文
        UIGraphicsBeginImageContext(size)
        // 2.绘制大图片
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let context = UIGraphicsGetCurrentContext()
        context!.scaleBy(x: 1, y: -1) // 缩放坐标系统
        context!.translateBy(x: 0, y: -size.height) // 平移坐标系统
        
        // 3.绘制路径
        let bounds = feature.bounds
        let path = UIBezierPath(rect: bounds)
        UIColor.red.setStroke()
        path.lineWidth = 6
        path.stroke()
        // 4.取出结果图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        // 5.关闭图形上线文
        UIGraphicsEndImageContext()
        // 6.返回图片
        return resultImage!
    }
    
    
}

extension QRCodeTool:AVCaptureMetadataOutputObjectsDelegate {
    
        
    
    // 扫描到结果调用
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if self.isDrawFrame{
            removeFrameLayer()
        }
        //print(metadataObjects)
        var results = [String]()
        for obj in metadataObjects {
            if((obj as AnyObject).isKind(of: AVMetadataMachineReadableCodeObject.self)){
                // 转换成为, 二维码 在预览图层上的真正坐标
                let resultObj = layer.transformedMetadataObject(for: obj as! AVMetadataObject)
                
                
                let qrCodeObj = resultObj as! AVMetadataMachineReadableCodeObject
                results.append(qrCodeObj.stringValue)
                //print(qrCodeObj.stringValue)
                if self.isDrawFrame {
                    drawFrame(qrCodeObj: qrCodeObj)
                }
                
                // qrCodeObj.corners 代表二维码的四个角, 但是,需要借助视频预览图层,转换成我们需要的
            }
        }
        if scanResultBlock != nil{
            scanResultBlock!(results)
        }
    }
    
    func drawFrame(qrCodeObj:AVMetadataMachineReadableCodeObject) -> Void {
        let corners = qrCodeObj.corners
        //1. 借助一个图形层.来绘制
        let shapLayer = CAShapeLayer()
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.strokeColor = UIColor.orange.cgColor
        shapLayer.lineWidth = 3
        // 2. 根据四个点创建一个路径
        let path = UIBezierPath()
        var index = 0
        for corner in corners! {
            let pointDic = corner as! CFDictionary
            let point = CGPoint(dictionaryRepresentation: pointDic)
            // 第一个点
            
            if index == 0{
                path.move(to: point!)
            }else{
                path.addLine(to: point!)
            }
            index += 1
        }
        path.close()
        // 3. 绘制图形土城的路径赋值, 图层展示怎样的形状
        shapLayer.path = path.cgPath
        // 4. 直接添加到图层到需要展示的图层
        self.layer.addSublayer(shapLayer)
    }
    
    
    func removeFrameLayer() -> Void {
        guard let subLayers = self.layer.sublayers else {
            return
        }
        for subLayer in subLayers {
            if subLayer.isKind(of: CAShapeLayer.self){
                subLayer.removeFromSuperlayer()
            }
        }
        
    }
    
}

