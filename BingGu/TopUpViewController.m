//
//  TopUpViewController.m
//  BingGu
//
//  Created by RockLu on 10/28/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "TopUpViewController.h"
#import "QRCodeReaderViewController.h"
#import "RFDIViewController.h"
#import "CardQueryHelper.h"

@interface TopUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldID;
@property (weak, nonatomic) IBOutlet UITextField *textFieldMoney;
@property (strong, nonatomic) OutputOfCheckTicketView* outputView;

@property (nonatomic) BOOL isQR;
@end

@implementation TopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) initialize
{
    self.navigationItem.title = @"充值";
    
    
    
    UINib* nib = [UINib nibWithNibName:@"OutputOfCheckTicketView" bundle:nil];
    self.outputView = [nib instantiateWithOwner:nil options:nil][0];
    self.outputView.alpha = 0;
    self.outputView.delegate = self;
    [self.view addSubview:self.outputView];
    
}




- (IBAction)buttonQRCodeClicked {
    self.isQR = YES;
    QRCodeReaderViewController * qr = [QRCodeReaderViewController getInstanceWithOption:YES];
    [self.navigationController pushViewController: qr animated:YES];
}

- (IBAction)buttonRFDICilcked {
    self.isQR = NO;
    RFDIViewController * qr = [RFDIViewController getInstanceWithOption:YES];
    [self.navigationController pushViewController: qr animated:YES];
}


- (void)viewDidAppear:(BOOL)animated
{
    if (self.isQR) {
        self.textFieldID.text = [QRCodeReaderViewController getInstanceWithOption:YES].cardCode;
    }else{
        self.textFieldID.text = [RFDIViewController getInstanceWithOption:YES].cardCode;
    }
    [QRCodeReaderViewController getInstanceWithOption:YES].cardCode = @"";

}

- (IBAction)buttonTopUpClicked {
    if (self.textFieldID.text.length > 0 && self.textFieldMoney.text.length > 0) {
        if (0 == [CardQueryHelper updateMoney:self.textFieldID.text money:[self.textFieldMoney.text integerValue]]) {
            [self.outputView setAsSuccessWithString:@"       充值成功!"];
        }else{
            [self.outputView setAsFailia];
        }
    }else{
        MBProgressHUD* hud = [[MBProgressHUD alloc] init];
        hud.labelText = @"卡号或金额不能为空！";
        [self.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        }];
    }
    
    
    
}


#pragma OutputOfCheckTickerViewDelegation
- (void)confirmNotified
{
    
}


@end
