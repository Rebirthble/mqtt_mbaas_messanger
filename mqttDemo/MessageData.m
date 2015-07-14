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

- (void)getMessageData:(void (^)(void))blk{
    
    NCMBQuery *query = [NCMBQuery queryWithClassName:@"message"];
    query.limit = 5;
    [query orderByDescending:@"createDate"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"object find error:%@", error);
        } else {
            NSString *senderId = nil;
            NSString *senderDisplayName = nil;
            NSDate *postDate = nil;
            NSString *text = nil;
            //for (NCMBObject *object in objects) {
            for (int i = (int)objects.count  - 1; i >= 0; i--){
                NCMBObject *object = objects[i];
                senderId = [object objectForKey:@"senderId"];
                senderDisplayName = [object objectForKey:@"senderDisplayName"];
                postDate = [object objectForKey:@"createDate"];
                text = [object objectForKey:@"message"];
                JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                                         senderDisplayName:senderDisplayName
                                                                      date:postDate
                                                                      text:text
                                       ];
                NSLog(@"message:%@", message.text);
                [self.messages addObject:message];
                blk();
            }
        }
    }];
}

@end
