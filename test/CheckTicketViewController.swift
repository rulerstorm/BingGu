//
//  CheckTicketViewController.swift
//  test
//
//  Created by RockLu on 10/7/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

import UIKit
import MediaPlayer

class CheckTicketViewController: UIViewController {

    //change the statue bar color to white
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTwoHeadButton()
        buttonRFDISelected = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func initTwoHeadButton(){

        self.buttonRFDI.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        self.buttonQRCode.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        
        self.ViewBar.layer.cornerRadius = 4
        self.ViewBar.layer.borderColor = UIColor.whiteColor().CGColor
        self.ViewBar.layer.borderWidth = 0.5
        self.ViewBar.layer.masksToBounds = true
    }
    
    @IBOutlet weak var buttonRFDI: UIButton!
    @IBOutlet weak var buttonQRCode: UIButton!
    @IBOutlet weak var ViewBar: UIView!

    var buttonRFDISelected :Bool = false{
        didSet{
            self.buttonRFDI.selected = buttonRFDISelected
            if(buttonRFDISelected){
                self.buttonRFDI.backgroundColor = MainColor.mainGreen
                self.buttonQRCode.backgroundColor = UIColor.whiteColor()
                self.viewCenterWhite.insertSubview(RFDIController.view,atIndex: 0)
//                print(self.viewCenterWhite.subviews.count)
            }else{
                self.RFDIController.view.removeFromSuperview()
            }
        }
    }
    
    var buttonQRCodeSelected :Bool = false{
        didSet{
            self.buttonQRCode.selected = buttonQRCodeSelected
            if(buttonQRCodeSelected){
                self.buttonRFDI.backgroundColor = UIColor.whiteColor()
                self.buttonQRCode.backgroundColor = MainColor.mainGreen
                self.viewCenterWhite.insertSubview(QRController.view,atIndex: 0)
            }else{
                self.QRController.view.removeFromSuperview()
            }
        }
    }
    
    
    @IBAction func buttonRFDIClicked() {
        
        let hud = MBProgressHUD();
        hud.labelText = "正在切换RFDI检票"
        self.view.addSubview(hud)
        hud.showAnimated(true, whileExecutingBlock: { () -> Void in
            self.QRController.stopRunning()
            sleep(1)
            }) { [unowned self] () -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                self.buttonRFDISelected = true
                self.buttonQRCodeSelected = false
        }

    }
    
    @IBAction func buttonQRCodeClicked() {
        
        let hud = MBProgressHUD();
        hud.labelText = "正在切换二维码检票"
        self.view.addSubview(hud)
        hud.showAnimated(true, whileExecutingBlock: { () -> Void in
//            self.QRController.stopRunning()
            usleep(500)
            }) { [unowned self] () -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                self.buttonRFDISelected = false
                self.buttonQRCodeSelected = true
        }

    }
    
    //two inner view controlers
    let QRController = QRCodeReaderViewController()
    var RFDIController = RFDIReaderViewController()
    
    
    @IBOutlet weak var viewCenterWhite: UIView!
    
}
