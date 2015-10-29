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

@interface RefoundViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldID;
@property (nonatomic) BOOL isQR;
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
