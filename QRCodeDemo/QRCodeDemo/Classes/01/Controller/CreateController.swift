//
//  CreateController.swift
//  二维码综合案例
//
//  Created by SPARKWYY on 2017/10/9.
//  Copyright © 2017年 SKOrganization. All rights reserved.
//

import UIKit
import CoreImage


class CreateController: UIViewController {

    
    @IBOutlet weak var qeCodeImageView: UIImageView!
    
    @IBOutlet weak var inputTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let centerImage = UIImage(named: "icon")
        let image = QRCodeTool.createQRCode(inputStr: self.inputTextView.text, scaleX: 20, scaleY: 20, centerImage: centerImage, centerImageSize: CGSize(width: 100, height: 100))
        self.qeCodeImageView.image = image
    }
    
    
    
}

















