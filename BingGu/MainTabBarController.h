//
//  MainTabBarController.h
//  BingGu
//
//  Created by RockLu on 10/21/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myTabBarButton.h"

@protocol MainTabBarDelegate <NSObject>
-(void) pushing;
-(void) poping;
@end



@interface MainTabBarController : UITabBarController <MainTabBarDelegate>

@end
