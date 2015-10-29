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
#define MainGreen [UIColor colorWithRed:115.0/255.0 green:189.0/255.0 blue:97.0/255.0 alpha:1.0]




@interface ChangeTicketViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldID;
@property (nonatomic) BOOL isQR;
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
}











@end
