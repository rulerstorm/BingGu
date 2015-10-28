//
//  StatisticViewController.m
//  BingGu
//
//  Created by RockLu on 10/28/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "StatisticViewController.h"
#import "DeatailedStatisticalViewController.h"


@interface StatisticViewController ()

@end

@implementation StatisticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) initialize
{
    self.navigationItem.title = @"统计";
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"统计";
}



- (IBAction)buttonSeeDetailedStatisticClicked:(UIButton *)sender
{
    [self.navigationController pushViewController:[[DeatailedStatisticalViewController alloc] init] animated:YES];
    
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
