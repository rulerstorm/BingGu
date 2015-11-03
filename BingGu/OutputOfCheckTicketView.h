//
//  OutputOfCheckTicketView.h
//  BingGu
//
//  Created by RockLu on 10/28/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OutputOfCheckTicketViewDelegate <NSObject>
-(void) confirmNotified;
@end


@interface OutputOfCheckTicketView : UIView

- (void)setAsSuccess:(NSString*)count;
- (void)setAsSuccessWithString:(NSString*)string;
- (void)setAsFailia;

@property (weak, nonatomic) id<OutputOfCheckTicketViewDelegate> delegate;
@end
