//
//  StatisticViewController.m
//  BingGu
//
//  Created by RockLu on 10/28/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "StatisticViewController.h"
#import "DeatailedStatisticalViewController.h"
#import "MBProgressHUD.h"


@interface StatisticViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textTicket;
@property (weak, nonatomic) IBOutlet UILabel *textMoney;
@property (weak, nonatomic) IBOutlet UILabel *textRefound;

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


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MBProgressHUD* hud = [[MBProgressHUD alloc] init];
    hud.labelText = @"请稍等...";
    [self.view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^{
        usleep(500000);
    }completionBlock:^{
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* tickedCount = [userDefaults objectForKey:@"tickedCount"];
        NSString* topUpCount = [userDefaults objectForKey:@"topUpCount"];
        NSString* refoundCount = [userDefaults objectForKey:@"refoundCount"];
        
        if (tickedCount) {
            self.textTicket.text = tickedCount;
        }else{
            self.textTicket.text = @"0 ";
        }
        if (topUpCount) {
            self.textMoney.text = topUpCount;
        }else{
            self.textMoney.text = @"0 ";
        }
        if (refoundCount) {
            self.textRefound.text = refoundCount;
        }else{
            self.textRefound.text = @"0 ";
        }
    }];
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
