//
//  CardQueryHelper.m
//  BingGu
//
//  Created by RockLu on 10/21/15.
//  Copyright © 2015 RockLu. All rights reserved.
//


#import "CardQueryHelper.h"

@implementation CardQueryHelper

+ (NSInteger)getJSON:(NSString*)cardID
{
    NSString* trimedID = [cardID stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://120.27.54.111:8080/index.php?id=%@",trimedID];
    NSLog(@"%@",urlStr);
    
    NSURL* url = [NSURL URLWithString:urlStr];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@-----",dict);
    
    if (dict[@"enterCount"]) {
        return [dict[@"enterCount"] integerValue];
    }else{
        return -1;
    }
    
}


@end
