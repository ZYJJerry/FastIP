//
//  STDPingManager.m
//  Lock
//
//  Created by Jerry on 2019/1/7.
//  Copyright © 2019 周玉举. All rights reserved.
//

#import "STDPingManager.h"

@implementation STDPingManager


- (instancetype)initWith:(NSArray *)IPList andWithCount:(int)count withFastIP:(FastIPBlock)fastcallback
{
    self = [super init];
    if (self) {
        self.IPList = [IPList copy];
        self.fastIP = fastcallback;
        self.count = count;
        self.dic = [NSMutableDictionary new];
    }
    return self;
}

+ (void)getFastIPwith:(NSArray *)IPList andWithCount:(int)count withFastIP:(FastIPBlock)fastcallback{
    STDPingManager * manager = [[STDPingManager alloc]initWith:IPList andWithCount:count withFastIP:fastcallback];
    [manager start];
}

- (void)start{
    dispatch_group_t group = dispatch_group_create();
    NSMutableDictionary * avgPing = [NSMutableDictionary new];
    NSMutableArray * failArray = [NSMutableArray new];
    NSMutableArray * unexpectedArray = [NSMutableArray new];
    NSMutableArray * timeoutArray = [NSMutableArray new];
    NSMutableArray * errorArray = [NSMutableArray new];
    for (NSString * address in self.IPList) {
        dispatch_group_enter(group);
        __block double pingSum = 0;
        STDPingServices * service = [STDPingServices startPingAddress:address withCount:self.count callbackHandler:^(STDPingItem *pingItem, NSArray *pingItems) {
                
                switch (pingItem.status) {
                    case STDPingStatusDidFailToSendPacket:
                        //发送包失败
                        [failArray addObject:address];
                        break;
                    case STDPingStatusDidReceivePacket:
                        //正常接收
//                        NSLog(@"%@---%f",address,pingItem.timeMilliseconds);
                        pingSum += pingItem.timeMilliseconds;
                        break;
                    case STDPingStatusDidReceiveUnexpectedPacket:
                        //收到不正常的包
                        [unexpectedArray addObject:address];
                        break;
                    case STDPingStatusDidTimeout:
                        //超时
                        [timeoutArray addObject:address];
                        break;
                    case STDPingStatusError:
                        //错误
                        [errorArray addObject:address];
                        break;
                    case STDPingStatusFinished:
                        //完成
                        [avgPing setValue:[NSString stringWithFormat:@"%f",pingSum/self.count] forKey:address];
                        dispatch_group_leave(group);
                        break;
                        
                    default:
                        break;
                }
            }];
        [self.dic setValue:service forKey:address];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSMutableArray * list  = [NSMutableArray arrayWithArray:self.IPList];
        if (failArray.count > 0) {
            for (NSString * fail in failArray) {
                if ([list containsObject:fail]) {
                  [list removeObject:fail];
                }
            }
        }
        
        if (unexpectedArray.count > 0) {
            for (NSString * unexpect in unexpectedArray) {
                if ([list containsObject:unexpect]) {
                    [list removeObject:unexpect];
                }
            }
        }
        
        if (timeoutArray.count > 0) {
            for (NSString * timeout in timeoutArray) {
                if ([list containsObject:timeout]) {
                    [list removeObject:timeout];
                }
            }
        }
        
        if (errorArray.count > 0) {
            for (NSString * error in errorArray) {
                if ([list containsObject:error]) {
                    [list removeObject:error];
                }
            }
        }
        NSMutableString * fastIP;
        if (list.count == 0) {
            fastIP = [NSMutableString stringWithString:@"无可用IP"];
        }else if(list.count == 1){
            fastIP = [list firstObject];
        }else{
            fastIP = [list firstObject];
        for (int i = 0; i < list.count-1 ;i++) {

            double ping = [avgPing[list[i]] doubleValue];
            double nextping = [avgPing[list[i+1]] doubleValue];
            if (ping > nextping) {
                fastIP = list[i+1];
            }
        }
        }
        self.fastIP(fastIP);
        //所有正常的ip
        NSLog(@"%@",avgPing);
    });
}
@end
