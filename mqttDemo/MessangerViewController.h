//
//  MessangerViewController.h
//  mqttDemo
//
//  Created by SCI01433 on 2015/07/08.
//  Copyright (c) 2015年 OkawaUki. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "MessageData.h"

#import <MQTTKit.h>
#import <JSQMessagesViewController/JSQMessages.h>

@interface MessangerViewController : JSQMessagesViewController<UIActionSheetDelegate>

@property (nonatomic) MQTTClient *client;
@property (nonatomic) MessageData *messageData;
@property (nonatomic) JSQMessagesBubbleImage *incomingBubble;
@property (nonatomic) JSQMessagesBubbleImage *outgoingBubble;
@property (nonatomic) NSDictionary *mqttSetting;

@end
