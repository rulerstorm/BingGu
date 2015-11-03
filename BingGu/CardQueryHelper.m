//
//  CardQueryHelper.m
//  BingGu
//
//  Created by RockLu on 10/21/15.
//  Copyright © 2015 RockLu. All rights reserved.
//


#import "CardQueryHelper.h"

@implementation CardQueryHelper

+ (NSInteger)checkTicket:(NSString*)cardID
{
    NSString *urlStr = [NSString stringWithFormat:@"http://120.27.54.111:8080/index.php?id=%@",cardID];
//    NSLog(@"%@",urlStr);
    
    NSURL* url = [NSURL URLWithString:urlStr];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@-----",dict);
    
    if (dict[@"enterCount"]) {
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cardID forKey:@"lastID"];
        
        //only the first enter count!
        if ([dict[@"enterCount"] isEqualToString:@"0"]) {
            NSInteger tickedCount = [[userDefaults objectForKey:@"tickedCount"] integerValue];
            tickedCount++;
            [userDefaults setObject:[NSString stringWithFormat:@"%ld",(long)tickedCount] forKey:@"tickedCount"];
        }
        return [dict[@"enterCount"] integerValue];
    }else{
        return -1;
    }
    
}


+ (NSInteger)changeTicketWithOldID:(NSString*)oldID newID:(NSString*)newID
{
    NSString *urlStr = [NSString stringWithFormat:@"http://120.27.54.111:8080/changeTicket.php?id=%@&toID=%@",oldID,newID];
    NSLog(@"%@",urlStr);
    
    NSURL* url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//    NSLog(@"%@-----",dict[@"validate"]);
    
    if ([dict[@"validate"] integerValue] == 200) {
        return 0;  //success
    }else{
        return -1;
    }
}



+ (NSString*)translateCardNO:(NSString*)cardID
{
    if (!cardID.length) {
        return nil;
    }
    NSString* trueID = [cardID substringToIndex:cardID.length-6];
    if (trueID.length == 11) {
        char* tempString = malloc(12);
        tempString = [trueID UTF8String];
        char temp = 0;
        for (size_t i = 0; i< 5; ++i) {
            temp = tempString[i];
            tempString[i] = tempString[10-i];
            tempString[10-i] = temp;
        }
        
        for (size_t j = 0; j<10; j+=3) {
            temp = tempString[j];
            tempString[j] = tempString[j+1];
            tempString[j+1] = temp;
        }
        
        trueID = [[NSString alloc] initWithCString:tempString];
//        NSLog(@"%@++++++++++", trueID);
    }
    NSString* trimedID = [trueID stringByReplacingOccurrencesOfString:@" " withString:@""];
    return trimedID;
}




+ (NSInteger)getMoney:(NSString*)cardID
{
    NSString *urlStr = [NSString stringWithFormat:@"http://120.27.54.111:8080/getMoney.php?id=%@",cardID];
    //    NSLog(@"%@",urlStr);
    
    NSURL* url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@-----",dict);
    
    if (dict[@"money"]) {
        return [dict[@"money"] integerValue];
    }else{
        return -1;
    }
    
}


+ (NSInteger)updateMoney:(NSString*)ID money:(NSInteger)money
{
    NSString *urlStr = @"";
    if (money>0) {
        urlStr = [NSString stringWithFormat:@"http://120.27.54.111:8080/updateMoney.php?id=%@&money=%ld",ID,(long)money];
    }else{
        urlStr = [NSString stringWithFormat:@"http://120.27.54.111:8080/updateMoney.php?id=%@&money=-1",ID];
    }
    
    NSLog(@"%@",urlStr);
    
    NSURL* url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //    NSLog(@"%@-----",dict[@"validate"]);
    
    if ([dict[@"validate"] integerValue] == 200) {
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        if (money > 0) {
            NSInteger topUpCount = [[userDefaults objectForKey:@"topUpCount"] integerValue];
            topUpCount += money;
            [userDefaults setObject:[NSString stringWithFormat:@"%ld",(long)topUpCount] forKey:@"topUpCount"];
        }else{
            NSInteger refoundMoney = -1 * money;
            NSInteger refoundCount = [[userDefaults objectForKey:@"refoundCount"] integerValue];
            refoundCount += refoundMoney;
            [userDefaults setObject:[NSString stringWithFormat:@"%ld",(long)refoundCount] forKey:@"refoundCount"];
        }
        
        return 0;  //success
    }else{
        return -1;
    }
}



+ (NSDictionary*)getStatistic:(NSString*)lastID
{
    NSString *urlStr = [NSString stringWithFormat:@"http://120.27.54.111:8080/statistic.php?lastID=%@",lastID];
    
    NSURL* url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@-----",dict);

    return dict;
}





@end
