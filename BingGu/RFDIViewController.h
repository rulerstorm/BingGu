//
//  RFDIViewController.h
//  BingGu
//
//  Created by RockLu on 10/12/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioJack/AudioJack.h"
#import "MBProgressHUD.h"
#import "OutputOfCheckTicketView.h"


@interface RFDIViewController : UIViewController <MBProgressHUDDelegate,ACRAudioJackReaderDelegate, OutputOfCheckTicketViewDelegate>

@end 