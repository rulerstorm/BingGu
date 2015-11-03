//
//  RefoundViewController.m
//  BingGu
//
//  Created by RockLu on 10/28/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "RefoundViewController.h"
#import "QRCodeReaderViewController.h"
#import "RFDIViewController.h"
#import "CardQueryHelper.h"

@interface RefoundViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldID;
@property (weak, nonatomic) IBOutlet UILabel *textFieldMoney;
@property (nonatomic) BOOL isQR;
@property (strong, nonatomic) OutputOfCheckTicketView* outputView;
@property (nonatomic) NSInteger money;
@end

@implementation RefoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialize];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initialize
{
    self.navigationItem.title = @"退款";
    
    
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

    
    if (self.textFieldID.text.length > 0) {
        self.money = [CardQueryHelper getMoney:self.textFieldID.text];
        if (-1 == self.money) {
            [self.outputView setAsFailia];
            
        }else{
            self.textFieldMoney.text = [NSString stringWithFormat:@"%ld",(long)self.money] ;
        }
    }else{
        self.textFieldMoney.text = @"---";
    }
    
}

- (IBAction)buttonRefoundClicked {
    if (self.textFieldID.text.length > 0) {
        NSInteger minusMoney = -1 * self.money;
        if (0 == [CardQueryHelper updateMoney:self.textFieldID.text money:minusMoney]) {
            [self.outputView setAsSuccessWithString:@"       退款成功!"];
        }else{
            [self.outputView setAsFailia];
        }
    }else{
        MBProgressHUD* hud = [[MBProgressHUD alloc] init];
        hud.labelText = @"卡号不能为空！";
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
