//
//  MyNavigationViewController.m
//  BingGu
//
//  Created by RockLu on 10/28/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "MyNavigationViewController.h"

#define MainGreen [UIColor colorWithRed:115.0/255.0 green:189.0/255.0 blue:97.0/255.0 alpha:1.0]



@interface MyNavigationViewController ()

@end

@implementation MyNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = MainGreen;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (id)initWithDelegation:(id<MainTabBarDelegate>)delegation andRootviewController:(UIViewController*)controller
{
    self.delegation = delegation;
    return [self initWithRootViewController:controller];
}


-(UIViewController *)popViewControllerAnimated:(BOOL)animated
{
//    NSLog(@"pop....");
    [self.delegation poping];
    return [super popViewControllerAnimated:animated];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    NSLog(@"push....");
    [self.delegation pushing];
    [super pushViewController:viewController animated:animated];
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
