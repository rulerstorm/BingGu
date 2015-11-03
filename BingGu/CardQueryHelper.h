//
//  CardQueryHelper.h
//  BingGu
//
//  Created by RockLu on 10/21/15.
//  Copyright © 2015 RockLu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CardQueryHelper : NSObject
+ (NSInteger)checkTicket:(NSString*)cardID;
+ (NSString*)translateCardNO:(NSString*)cardID;
+ (NSInteger)changeTicketWithOldID:(NSString*)oldID newID:(NSString*)newID;
+ (NSInteger)getMoney:(NSString*)cardID;
+ (NSInteger)updateMoney:(NSString*)ID money:(NSInteger)money;
+ (NSDictionary*)getStatistic:(NSString*)lastID;
@end
