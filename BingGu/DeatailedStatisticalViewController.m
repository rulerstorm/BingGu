//
//  DeatailedStatisticalViewController.m
//  BingGu
//
//  Created by RockLu on 10/28/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import "DeatailedStatisticalViewController.h"
#import "CardQueryHelper.h"
#import "MBProgressHUD.h"

@interface DeatailedStatisticalViewController ()
@property (weak, nonatomic) IBOutlet UILabel *textA;
@property (weak, nonatomic) IBOutlet UILabel *textB;
@property (weak, nonatomic) IBOutlet UILabel *textC;
@property (weak, nonatomic) IBOutlet UILabel *textD;
@property (weak, nonatomic) IBOutlet UILabel *textE;
@property (weak, nonatomic) IBOutlet UILabel *textTotal;

@end

@implementation DeatailedStatisticalViewController

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
    self.navigationItem.title = @"详情";
    
    
    
}


- (IBAction)buttonRefreshClicked {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* lastID = [userDefaults objectForKey:@"lastID"];
    
    MBProgressHUD* hud = [[MBProgressHUD alloc] init];
    hud.labelText = @"请稍等...";
    [self.view addSubview:hud];
    
    if (lastID) {
        __block NSDictionary* dict = [[NSDictionary alloc]init];
        [hud showAnimated:YES whileExecutingBlock:^{
            dict = [CardQueryHelper getStatistic:lastID];
            sleep(1);
        } completionBlock:^{
            self.textA.text = [NSString stringWithFormat:@"%@  张", dict[@"A"]];
            self.textB.text = [NSString stringWithFormat:@"%@  张", dict[@"B"]];
            self.textC.text = [NSString stringWithFormat:@"%@  张", dict[@"C"]];
            self.textD.text = [NSString stringWithFormat:@"%@  张", dict[@"D"]];
            self.textE.text = [NSString stringWithFormat:@"%@  张", dict[@"E"]];
            NSInteger total = [dict[@"A"] integerValue] + [dict[@"B"] integerValue] + [dict[@"C"] integerValue] + [dict[@"D"] integerValue] + [dict[@"E"] integerValue];
            self.textTotal.text = [NSString stringWithFormat:@"%ld", (long)total];
        }];
    }else{
        hud.labelText = @"至少验票1张才能获取项目信息";
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        }];
    }
    
    
}






@end
