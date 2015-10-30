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
@property (weak, nonatomic) IBOutlet UILabel *labelTextMain;

@end



@implementation OutputOfCheckTicketView

- (void)setAsSuccess:(NSString*)count
{
    self.labelIfSuccess.text = @"检票成功";
    [self.buttonPicture setBackgroundImage:[UIImage imageNamed:@"成功"] forState:UIControlStateNormal];
    self.labelEnterCount.text = count;
    self.labelTextMain.text = @"入场次数：";
    [self.buttonConfig setTitle:@"确定(3)" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;

        if ([UIScreen mainScreen].bounds.size.height == 480.0) {
            self.viewCenter.center = self.center;
        }else{
            self.viewCenter.transform = CGAffineTransformMakeTranslation(0, -540);
        }
    }];
}



- (void)setAsFailia
{
    self.labelIfSuccess.text = @"ID号不存在";
    [self.buttonPicture setBackgroundImage:[UIImage imageNamed:@"失败"] forState:UIControlStateNormal];
    self.labelEnterCount.text = @"";
    self.labelTextMain.text = @"请与工作人员联系";
    [self.buttonConfig setTitle:@"确定" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;

        if ([UIScreen mainScreen].bounds.size.height == 480.0) {
            self.viewCenter.center = self.center;
        }else{
            self.viewCenter.transform = CGAffineTransformMakeTranslation(0, -540);
        }
    }];
}

- (void)layoutSubviews
{
//    NSLog(@"sdfsdf");
    [super layoutSubviews];
    
    self.buttonConfig.layer.cornerRadius = 15;
    self.viewCenter.layer.cornerRadius = 10;
    
//    self.viewCenter.frame = 
}

- (IBAction)buttonConfigClicked:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.viewCenter.transform = CGAffineTransformMakeTranslation(0, 0);
        self.alpha = 0;
    }];
    [self.delegate confirmNotified];
}


@end
