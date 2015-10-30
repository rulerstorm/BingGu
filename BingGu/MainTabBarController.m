//
//  MainTabBarController.m
//  BingGu
//
//  Created by RockLu on 10/21/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "MainTabBarController.h"
#import "CheckTicketViewController.h"
#import "MyNavigationViewController.h"
#import "ChangeTicketViewController.h"
#import "TopUpViewController.h"
#import "RefoundViewController.h"
#import "StatisticViewController.h"


@interface MainTabBarController ()

@property(nonatomic,strong)UIView* myTabBar;
@property(nonatomic,strong)NSMutableArray* subControllers;
@property(nonatomic,strong)NSMutableArray* titles;
@property(nonatomic,strong)UIScrollView* scrollView;

@end

@implementation MainTabBarController

-(BOOL)checkIfStarted
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if ([@"yes" isEqual:[userDefaults objectForKey:@"isStarted"]]) {
        return YES;
    }else{
        [userDefaults setObject:@"yes" forKey:@"isStarted"];
        return NO;
    }
}

-(void) performWelcomePages
{
    if (![self checkIfStarted]) {
    
        //init scrollView
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat contentWidth = width * 4.0;
        CGRect frame = CGRectMake(0, 0, width, height);
        CGSize ContentSize = CGSizeMake(contentWidth, height);
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.contentSize = ContentSize;
        self.scrollView.pagingEnabled = YES;

        //add welcome image
    NSMutableArray* image = [[NSMutableArray alloc] init];
    
    if (height == 480.0) {
        image[0] = [UIImage imageNamed:@"启动页1_4s"];
        image[1] = [UIImage imageNamed:@"启动页2_4s"];
        image[2] = [UIImage imageNamed:@"启动页3_4s"];
        image[3] = [UIImage imageNamed:@"启动页4_4s"];
        
    }else{
        image[0] = [UIImage imageNamed:@"启动页1_5s"];
        image[1] = [UIImage imageNamed:@"启动页2_5s"];
        image[2] = [UIImage imageNamed:@"启动页3_5s"];
        image[3] = [UIImage imageNamed:@"启动页4_5s"];
    }

    for (size_t i = 0; i < 4; ++i) {
        UIImageView* imageView = [[UIImageView alloc] init];
        CGFloat x = i * width;
        CGFloat y = 0;
        imageView.frame = CGRectMake(x, y, width, height);
        imageView.image = image[i];
        [self.scrollView addSubview:imageView];
    }
    
    //add begin button
    CGFloat buttonH = 40;
    CGFloat buttonW = 90;
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(3.5 * width - 0.5 * buttonW, height - buttonH - 30, buttonW , buttonH)];
    button.layer.cornerRadius = 5;
    button.layer.borderColor = [[UIColor whiteColor] CGColor];
    button.layer.borderWidth = 1;
    [button setTitle:@"开始检票" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissWelcomeView) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:button];
    
    [self.view addSubview:self.scrollView];
    }
}

- (void)dismissWelcomeView
{
    [UIView animateWithDuration:1.0 animations:^{
        self.scrollView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.scrollView removeFromSuperview];
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [self performWelcomePages];
    
    //turn off auto lock screen
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //change the tabbar
    self.myTabBar = [[UIView alloc] initWithFrame:self.tabBar.frame];
    self.myTabBar.layer.borderColor = [[UIColor colorWithRed:150.0/255.0 green:150.0/255.0  blue:150.0/255.0  alpha:0.5] CGColor];
    self.myTabBar.layer.borderWidth = 1;
    [self.view addSubview:self.myTabBar];
    [self.tabBar removeFromSuperview];
    
    
    
    [self.myTabBar setBackgroundColor:[UIColor whiteColor]];
    
    [self addBarItems];
    [self addSubControllers];
    
    self.selectedIndex = 2;
    

    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyBoard)];
    tapGesture.cancelsTouchesInView = NO;  //
    [self.view addGestureRecognizer:tapGesture];
}

-(void) dismissKeyBoard
{
    [self.view endEditing:YES];
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
    
    _subControllers[0] = [[MyNavigationViewController alloc] initWithDelegation:self andRootviewController:[[TopUpViewController alloc] init]];
    
    _subControllers[1] = [[MyNavigationViewController alloc] initWithDelegation:self andRootviewController:[[RefoundViewController alloc] init]];
    _subControllers[2] = [[CheckTicketViewController alloc]init];
    _subControllers[3] = [[MyNavigationViewController alloc] initWithDelegation:self andRootviewController:[[ChangeTicketViewController alloc] init]];
    _subControllers[4] = [[MyNavigationViewController alloc] initWithDelegation:self andRootviewController:[[StatisticViewController alloc] init]];
    
    for (UIViewController* pages in _subControllers) {
        [self addChildViewController:pages];
    }
    
    [self poping];
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

#pragma delegating method
-(void)pushing
{
    [UIView animateWithDuration:0.5 animations:^{
        self.myTabBar.transform = CGAffineTransformMakeTranslation(0, 60);
        self.myTabBar.alpha = 0.3;
    }];
}

-(void)poping
{
    [UIView animateWithDuration:0.5 animations:^{
        self.myTabBar.transform = CGAffineTransformIdentity;
        self.myTabBar.alpha = 1;
    }];
}


@end
