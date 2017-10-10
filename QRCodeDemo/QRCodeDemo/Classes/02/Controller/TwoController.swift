//
//  TwoController.swift
//  二维码综合案例
//
//  Created by SPARKWYY on 2017/10/9.
//  Copyright © 2017年 SKOrganization. All rights reserved.
//

import UIKit
import CoreGraphics

class TwoController: UIViewController {
    
    
    @IBOutlet weak var sourceImage: UIImageView!
    
    
    
    @IBAction func showImage(_ sender: Any) {
        
        // 1. 获取需要识别的图片
        let image = sourceImage.image
        
        let result = QRCodeTool.detectorQRCodeImage(image: image!, isDrawQRCodeFrame: true)
        
        print(result.resultsStr)
        self.sourceImage.image = result.resultImage
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}













