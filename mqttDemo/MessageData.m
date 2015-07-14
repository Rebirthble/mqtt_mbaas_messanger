//
//  MessageData.m
//  mqttDemo
//
//  Created by SCI01433 on 2015/07/08.
//  Copyright (c) 2015年 OkawaUki. All rights reserved.
//

#import "MessageData.h"
#import <JSQMessagesViewController/JSQMessages.h>

#import <NCMB/NCMB.h>

@implementation MessageData

-(instancetype)init{
    self.messages = [NSMutableArray array];
    return self;
}

@end
