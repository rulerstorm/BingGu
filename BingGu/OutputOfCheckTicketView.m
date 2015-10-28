//
//  OutputOfCheckTicketView.m
//  BingGu
//
//  Created by RockLu on 10/28/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "OutputOfCheckTicketView.h"






@interface OutputOfCheckTicketView()

@property (weak, nonatomic) IBOutlet UIButton *buttonConfig;
@property (weak, nonatomic) IBOutlet UILabel *labelEnterCount;
@property (weak, nonatomic) IBOutlet UILabel *labelIfSuccess;
@property (weak, nonatomic) IBOutlet UIButton *buttonPicture;

@property (weak, nonatomic) IBOutlet UIView *viewCenter;

@end



@implementation OutputOfCheckTicketView

- (void)setAsSuccess:(NSString*)count
{
    self.labelIfSuccess.text = @"检票成功";
    [self.buttonPicture setBackgroundImage:[UIImage imageNamed:@"成功"] forState:UIControlStateNormal];
    self.labelEnterCount.text = count;
    [self.buttonConfig setTitle:@"确定(3)" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
        self.viewCenter.transform = CGAffineTransformMakeTranslation(0, -540);
    }];
}


#warning 失败时的ui需要调整
- (void)setAsFailia
{
    self.labelIfSuccess.text = @"检票失败";
    [self.buttonPicture setBackgroundImage:[UIImage imageNamed:@"失败"] forState:UIControlStateNormal];
//    self.labelEnterCount.text = count;
    [self.buttonConfig setTitle:@"确定(3)" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
        self.viewCenter.transform = CGAffineTransformMakeTranslation(0, -540);
    }];
}

- (void)layoutSubviews
{
//    NSLog(@"sdfsdf");
    [super layoutSubviews];
    
    self.buttonConfig.layer.cornerRadius = 15;
    self.viewCenter.layer.cornerRadius = 10;
}

- (IBAction)buttonConfigClicked:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.viewCenter.transform = CGAffineTransformMakeTranslation(0, 0);
        self.alpha = 0;
    }];
    [self.delegate confirmNotified];
}



@end
