//
//  CheckTicketViewController.m
//  BingGu
//
//  Created by RockLu on 10/27/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "CheckTicketViewController.h"
#import "MBProgressHUD.h"
#import "QRCodeReaderViewController.h"
#import "RFDIViewController.h"

#define MainGreen [UIColor colorWithRed:115.0/255.0 green:189.0/255.0 blue:97.0/255.0 alpha:1.0]

@interface CheckTicketViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonRFDI;
@property (weak, nonatomic) IBOutlet UIButton *buttonQRCode;
@property (weak, nonatomic) IBOutlet UIView *viewBar;
@property (weak, nonatomic) IBOutlet UIView *viewContent;


@end

@implementation CheckTicketViewController

QRCodeReaderViewController* _QRController;
RFDIViewController* _RFDIController;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initilize];
    NSLog(@"sdfs");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initilize
{
    _RFDIController = [[RFDIViewController alloc] init];
    _QRController = [[QRCodeReaderViewController alloc] init];
    
    [self.buttonRFDI setTitleColor:[UIColor whiteColor]  forState:UIControlStateSelected];
    [self.buttonQRCode setTitleColor:[UIColor whiteColor]  forState:UIControlStateSelected];
    
    self.viewBar.layer.cornerRadius = 4;
    self.viewBar.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.viewBar.layer.borderWidth = 0.5;
    self.viewBar.layer.masksToBounds = true;
    
    self.buttonRFDI.selected = YES;
    self.buttonQRCode.selected = NO;
    self.buttonQRCode.backgroundColor = [UIColor whiteColor];
    [self.viewContent insertSubview:_QRController.view atIndex:0];
    self.buttonRFDI.backgroundColor = MainGreen;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)buttonRFDIClicked:(UIButton *)sender {
    
    MBProgressHUD* hud = [[MBProgressHUD alloc] init];
    hud.labelText = @"正在切换RFDI检票";
    [self.view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        [_QRController stopRunning];
        sleep(1);
    } completionBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        self.buttonRFDI.selected = NO;
        self.buttonQRCode.selected = YES;
        
        self.buttonRFDI.backgroundColor = [UIColor whiteColor];
        [self.viewContent insertSubview:_RFDIController.view atIndex:0];
        
        self.buttonQRCode.backgroundColor = MainGreen;
        [_QRController.view removeFromSuperview];
    }];
}


- (IBAction)buttonQRCodeClicked:(UIButton *)sender {
    
    MBProgressHUD* hud = [[MBProgressHUD alloc] init];
    hud.labelText = @"正在切换二维码检票";
    [self.view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        usleep(50000);
    } completionBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        self.buttonRFDI.selected = YES;
        self.buttonQRCode.selected = NO;
        
        self.buttonQRCode.backgroundColor = [UIColor whiteColor];

//        self.buttonQRCode.backgroundColor = [UIColor colorWithRed:115.0/255.0 green:189.0/255.0  blue:97.0/255.0  alpha:1.0];
        [self.viewContent insertSubview:_QRController.view atIndex:0];
        
        self.buttonRFDI.backgroundColor = MainGreen;
        [_RFDIController.view removeFromSuperview];
    }];
    
    
}



@end
