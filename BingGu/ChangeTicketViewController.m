//
//  ChangeTicketViewController.m
//  BingGu
//
//  Created by RockLu on 10/28/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "ChangeTicketViewController.h"
#import "QRCodeReaderViewController.h"
#import "RFDIViewController.h"
#import "CardQueryHelper.h"

#define MainGreen [UIColor colorWithRed:115.0/255.0 green:189.0/255.0 blue:97.0/255.0 alpha:1.0]




@interface ChangeTicketViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldID;
@property (weak, nonatomic) IBOutlet UITextField *textFieldOldID;
@property (nonatomic) BOOL isQR;
@property (strong, nonatomic) OutputOfCheckTicketView* outputView;

@end

@implementation ChangeTicketViewController

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
    self.navigationItem.title = @"门票更换";
    
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

- (IBAction)buttonChangeClicked {
    
    NSInteger length = self.textFieldOldID.text.length;
    if ((length == 0) || (self.textFieldID.text.length == 0)) {
        MBProgressHUD* hud = [[MBProgressHUD alloc] init];
        hud.labelText = @"新旧ID不能为空！";
        [self.view addSubview:hud];
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        }];
    }else{
        if ((length == 8) || (length == 14) || (length == 7)) {
            if ([CardQueryHelper changeTicketWithOldID:self.textFieldOldID.text newID:self.textFieldID.text] == 0) {
                [self.outputView setAsSuccessWithString:@"       换票成功！"];
            }else{
                [self.outputView setAsFailia];
            }
        }else{
            MBProgressHUD* hud = [[MBProgressHUD alloc] init];
            hud.labelText = @"原ID长度不正确！请检查。";
            [self.view addSubview:hud];
            [hud showAnimated:YES whileExecutingBlock:^{
                sleep(2);
            }];
        }
    }
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





#pragma OutputOfCheckTickerViewDelegation
- (void)confirmNotified
{
 
}






@end
