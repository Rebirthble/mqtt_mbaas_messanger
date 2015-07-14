//
//  MessangerViewController.m
//  mqttDemo
//
//  Created by SCI01433 on 2015/07/08.
//  Copyright (c) 2015年 OkawaUki. All rights reserved.
//

#import "MessangerViewController.h"

#import <NCMB/NCMB.h>

@implementation MessangerViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //MQTTの設定を読み込む
    
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* path = [bundle pathForResource:@"MQTTSetting" ofType:@"plist"];
    self.mqttSetting = [NSDictionary dictionaryWithContentsOfFile:path];
    
    //self.mqttSetting = nil;
    
    //メッセージを格納するプロパティを初期化
    self.messageData = [[MessageData alloc] init];
    
    //メッセージの取得
    [self.messageData getMessageData:^{
        [self finishReceivingMessageAnimated:YES];
    }];
    
    //senderIdにUUIDを設定する
    self.senderId = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    //メッセージの背景を設定
    JSQMessagesBubbleImageFactory *bubbleFactory = [JSQMessagesBubbleImageFactory new];
    self.incomingBubble = [bubbleFactory  incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.outgoingBubble = [bubbleFactory  outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    //メッセージ画面のアバター設定
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    //MQTTクライアントの初期化
    NSString *clientID = self.senderId;
    self.client = [[MQTTClient alloc] initWithClientId:clientID];
    self.client.username = self.mqttSetting[@"username"];
    self.client.password = self.mqttSetting[@"password"];
    self.client.port = (unsigned short)[self.mqttSetting[@"port"] integerValue];
    
    //メッセージ受信時の処理
    __weak typeof(self) weakself = self;
    [self.client setMessageHandler:^(MQTTMessage *message) {
        
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:message.payload
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        if (error){
            NSLog(@"JSON Parse error.");
        } else {
            //ペイロードの内容からJSQMessageを作成する
            JSQMessage *newMessage = [JSQMessage messageWithSenderId:[json objectForKey:@"senderId"]
                                                         displayName:[json objectForKey:@"senderDisplayName"]
                                                                text:[json objectForKey:@"message"]];
            
            //受信したメッセージが自分のものではない場合に、messageDataに追加する
            //自分が発信したメッセージは発信が完了したタイミングで格納されているため
            if (![[json objectForKey:@"senderId"] isEqualToString:weakself.senderId]){
                [weakself.messageData.messages addObject:newMessage];
                
            }
            
            //messageDataの表示内容を更新する
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself finishReceivingMessageAnimated:YES];
            });
        }
    }];
    
    //MQTTサーバーへの接続を行う
    [self.client connectToHost:self.mqttSetting[@"endpoint"]
             completionHandler:^(MQTTConnectionReturnCode code) {
                 if (code == ConnectionAccepted) {
                     // when the client is connected, subscribe to the topic to receive message.
                     
                     NSString *topicName = self.mqttSetting[@"topic"];
                     [self.client subscribe:topicName
                      withCompletionHandler:^(NSArray *grantedQos) {
                          
                          //端末情報のchannelsにトピックを追加して保存
                          NCMBInstallation *installation = [NCMBInstallation currentInstallation];
                          [installation setChannels:[NSMutableArray arrayWithArray:@[topicName]]];
                          [installation saveInBackgroundWithBlock:^(NSError *error) {
                              if (error){
                                  NSLog(@"installation update error:%@", error);
                              }
                          }];
                      }];
                 } else {
                     NSLog(@"connection error...");
                 }
             }];
    
    self.inputToolbar.contentView.rightBarButtonItem = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
}

- (void)viewWillAppear:(BOOL)animated {
    
    //最近のメッセージを取得
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.client disconnectWithCompletionHandler:^(NSUInteger code) {
        NSLog(@"disconnect");
    }];
}

#pragma mark UICollectionView protocol

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messageData.messages.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messageData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}

#pragma mark action sheet


#pragma mark JSQMessagesViewController protcol

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messageData.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messageData.messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubble;
    }
    return self.incomingBubble;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

//sendボタンがタップされた場合に呼び出されるメソッド
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    //[JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    NSDictionary *payload = @{@"senderId":senderId,
                              @"senderDisplayName":senderDisplayName,
                              @"message":text
                              };
    NSError *error = nil;
    NSData *payloadData = [NSJSONSerialization dataWithJSONObject:payload
                                                       options:0
                                                         error:&error];
    if (error){
        NSLog(@"JSON parse error.");
    } else {
        //Publishing MQTT message
        [self.client publishString:[[NSString alloc] initWithData:payloadData
                                                         encoding:NSUTF8StringEncoding]
                           toTopic:self.mqttSetting[@"topic"]
                           withQos:ExactlyOnce
                            retain:NO
                 completionHandler:^(int mid) {
                     
                     NCMBQuery *query = [NCMBInstallation query];
                     [query whereKey:@"channels" containedInArray:@[@"mbaas/test"]];
                     
                     NCMBPush *push = [NCMBPush push];
                     [push setSearchCondition:query];
                     [push setMessage:@"メッセージを受信!"];
                     [push setPushToIOS:YES];
                     [push setImmediateDeliveryFlag:YES];
                     [push sendPushInBackgroundWithBlock:^(NSError *error) {
                         if (error){
                             NSLog(@"send notificaiton error:%@", error);
                         }
                     }];
                     
                     JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                                              senderDisplayName:senderDisplayName
                                                                           date:date
                                                                           text:text];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.messageData.messages addObject:message];
                         [self finishSendingMessageAnimated:YES];
                         NSLog(@"message has been delivered");
                     });
                     
                 }];
    }
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messageData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messageData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

@end
