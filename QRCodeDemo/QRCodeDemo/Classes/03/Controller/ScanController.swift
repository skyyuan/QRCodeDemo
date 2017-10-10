//
//  ScanController.swift
//  二维码综合案例
//
//  Created by SPARKWYY on 2017/10/9.
//  Copyright © 2017年 SKOrganization. All rights reserved.
//

import AVFoundation
import UIKit

class ScanController: UIViewController {
    
    @IBOutlet weak var chongjiboImageView: UIImageView!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var bottom: NSLayoutConstraint!
    var session:AVCaptureSession?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScanAnimation()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        removewScanAnimation()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startScan()
        // Do any additional setup after loading the view.
    }
    
    
    func startScan() -> Void {
        QRCodeTool.shareInstance.setRectInterrest(orginRect: topView.frame)
        QRCodeTool.shareInstance.scanQRCode(inView: self.view, isDrawFrame: true) { (results) in
            print(results)
        }
    }
    
    
    func startScanAnimation() -> Void {
        bottom.constant = topView.frame.size.height
        view.layoutIfNeeded()
        
        bottom.constant = -topView.frame.size.height
        
        UIView.animate(withDuration: 2.5) {
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.view.layoutIfNeeded()
        }
    }
    
    func removewScanAnimation() -> Void {
        chongjiboImageView.layer.removeAllAnimations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}





































