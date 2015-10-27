//
//  MainTabBarController.m
//  BingGu
//
//  Created by RockLu on 10/21/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "MainTabBarController.h"
#import "CheckTicketViewController.h"

@interface MainTabBarController ()

@property(nonatomic,strong)UIView* myTabBar;
@property(nonatomic,strong)NSMutableArray* subControllers;
@property(nonatomic,strong)NSMutableArray* titles;

@end

@implementation MainTabBarController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    //change the tabbar
    self.myTabBar = [[UIView alloc] initWithFrame:self.tabBar.frame];
    [self.view addSubview:self.myTabBar];
    [self.tabBar removeFromSuperview];
    
    
    
    [self.myTabBar setBackgroundColor:[UIColor whiteColor]];
    
    [self addBarItems];
    [self addSubControllers];
    
    self.selectedIndex = 2;
}

- (void)addBarItems
{
    self.titles = [[NSMutableArray alloc] initWithObjects:@"充值",@"退款",@"检票",@"换票",@"统计", nil];
    
    CGFloat screenWidth = self.myTabBar.frame.size.width;
    CGFloat tabBarHeight = self.myTabBar.frame.size.height;
    CGFloat buttonWidth = screenWidth / _titles.count ;
    
    
    for (int i = 0; i < _titles.count; ++i) {
        myTabBarButton* aButton = [[myTabBarButton alloc]init];
        aButton.myIndex = i;
        aButton.myTitle = _titles[i];

        aButton.frame = CGRectMake(i * buttonWidth, 0, buttonWidth, tabBarHeight);
        [self.myTabBar addSubview:aButton];
        
        [aButton addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
        
        //select the middle one as default
        if (i == 2) {
            aButton.selected = YES;
            aButton.backgroundColor = [UIColor colorWithRed:117.0/255.0 green:117.0/255.0  blue:117.0/255.0  alpha:1.0];
        }
        
    }
    
}

- (void)addSubControllers
{
    self.subControllers = [[NSMutableArray alloc]init];
    
    _subControllers[0] = [[UIViewController alloc]init];
    _subControllers[1] = [[UIViewController alloc]init];
    _subControllers[2] = [[CheckTicketViewController alloc]init];
    _subControllers[3] = [[UIViewController alloc]init];
    _subControllers[4] = [[UIViewController alloc]init];
    
    for (UIViewController* pages in _subControllers) {
        [self addChildViewController:pages];
    }
}


- (void)changeView:(myTabBarButton*)caller
{

    for (UIButton* subView in _myTabBar.subviews) {
        subView.selected = NO;
        subView.backgroundColor = [UIColor whiteColor];
    }
    caller.selected = YES;
    caller.backgroundColor = [UIColor colorWithRed:117.0/255.0 green:117.0/255.0  blue:117.0/255.0  alpha:1.0];
    
    
    self.selectedIndex = caller.myIndex;
    
}


@end
