//
//  ViewController.m
//  MQTT_test
//
//  Created by 魏滨涛 on 2017/5/4.
//  Copyright © 2017年 物联利浪. All rights reserved.
//

#import "ViewController.h"
#import "MQTTClient.h"

NSString *const Topic = @"我是话题";

@interface ViewController ()<MQTTSessionDelegate>
{
    MQTTSession *_session;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _session = [[MQTTSession alloc] init];
    _session.clientId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    _session.cleanSessionFlag = NO;//是否清楚会话
    _session.userName = @"test2";
    _session.password = @"123";
    
    _session.delegate = self;
    
    [_session connectToHost:@"192.168.3.14" port:1883 usingSSL:NO];
    

    //订阅主题 一定要写在分线程中 不然订阅不成功
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [_session subscribeToTopic:Topic atLevel:MQTTQosLevelAtMostOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
            
            
            if (error) {
                NSLog(@"Subscription failed %@  连接失败", error.localizedDescription);
            } else {
                NSLog(@"Subscription sucessfull! Granted Qos: %@ 连接成功", gQoss);
            }
            
            
        }];
        
    });
    

    
}


//发送消息
- (IBAction)sendMessage:(id)sender {
    
    NSDictionary * message = @{@"name":@"张三",@"age":@"18"};
    NSData *data =    [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:nil];
    
    [_session publishAndWaitData:data
                        onTopic:Topic
                         retain:NO
                            qos:MQTTQosLevelAtLeastOnce];
}

#pragma mark - MQTTSessionDelegate
- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:dic[@"name"] message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
}

@end
