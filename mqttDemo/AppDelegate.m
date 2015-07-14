//
//  AppDelegate.m
//  mqttDemo
//
//  Created by SCI01433 on 2015/06/24.
//  Copyright (c) 2015年 OkawaUki. All rights reserved.
//

#import "AppDelegate.h"
#import <NCMB/NCMB.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //SDKの初期化
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* path = [bundle pathForResource:@"NCMBSetting" ofType:@"plist"];
    NSDictionary *keyDic = [NSDictionary dictionaryWithContentsOfFile:path];
    [NCMB setApplicationKey:keyDic[@"applicationKey"]
                  clientKey:keyDic[@"clientKey"]];
    
    //プッシュ通知の許可画面を表示させる
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound |
    UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    //リモートプッシュ通知を受信するためのdeviceTokenを要求
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

-(void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"register device token");
    //NCMBInstallation作成
    NCMBInstallation *installation = [NCMBInstallation currentInstallation];
    
    //デバイストークンをセット
    [installation setDeviceTokenFromData:deviceToken];
    
    //ニフティクラウド mobile  backendのデータストアに登録
    [installation saveInBackgroundWithBlock:^(NSError *error) {
        if(!error){
            //端末情報の登録が成功した場合の処理
            NSLog(@"installation is saved.");
        } else {
            //端末情報の登録が失敗した場合の処理
            NSLog(@"installation save error:%@", error);
        }
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
