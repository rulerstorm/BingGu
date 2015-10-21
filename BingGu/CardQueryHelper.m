//
//  CardQueryHelper.m
//  BingGu
//
//  Created by RockLu on 10/21/15.
//  Copyright © 2015 RockLu. All rights reserved.
//


#import "CardQueryHelper.h"
#import "AFHTTPRequestOperationManager.h"


#define MAINURL @"http://120.27.54.111:8080/index.php"


@implementation CardQueryHelper

/**
 *  利用AFN发送一个GET请求，服务器返回的JSON数据
 */
+ (void)getJSON:(NSString*)cardID
{
    // 1.创建一个请求操作管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
//    // 声明一下：服务器返回的是JSON数据
//    //    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
//    // responseObject的类型是NSDictionary或者NSArray
//    
//    // 2.请求参数
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"id"] = cardID;
////    params[@"pwd"] = @"123";
//    
//    // 3.发送一个GET请求
//    NSString *url = MAINURL;
//    [mgr GET:url parameters:params
//     success:^(AFHTTPRequestOperation *operation, id responseObject) {
//         // 请求成功的时候调用这个block
//         NSLog(@"请求成功---%@", responseObject);
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         // 请求失败的时候调用调用这个block
//         NSLog(@"请求失败");
//     }];
}


@end
