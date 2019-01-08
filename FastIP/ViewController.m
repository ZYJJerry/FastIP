//
//  ViewController.m
//  FastIP
//
//  Created by Jerry on 2019/1/8.
//  Copyright © 2019 周玉举. All rights reserved.
//

#import "ViewController.h"
#import "STDPing/STDPingManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [STDPingManager getFastIPwith:@[@"www.baidu.com",@"www.qq.com",@"www.jainshu.com"] andWithCount:6 withFastIP:^(NSString *ipAddress) {
        NSLog(@"最快的IP:%@",ipAddress);
    }];
    // Do any additional setup after loading the view, typically from a nib.
}


@end
