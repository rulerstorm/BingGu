//
//  MyNavigationViewController.h
//  BingGu
//
//  Created by RockLu on 10/28/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTabBarController.h"


@interface MyNavigationViewController : UINavigationController
@property(weak, nonatomic) id<MainTabBarDelegate> delegation;
- (id)initWithDelegation:(id<MainTabBarDelegate>)delegation andRootviewController:(UIViewController*)controller;
@end
