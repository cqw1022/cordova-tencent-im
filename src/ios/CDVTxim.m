//
//  CDVWxpay.m
//  cordova-plugin-wxpay
//
//  Created by tong.wu on 06/30/15.
//
//

#import "CDVTxim.h"
#import <IMMessageExt/IMMessageExt.h>
#import <IMFriendshipExt/IMFriendshipExt.h>

@implementation CDVTxim

#pragma mark "API"

- (void)pluginInitialize {
//    [self initSdk:NULL];
}


- (void)initSdk:(CDVInvokedUrlCommand *)command
{
    // check arguments
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    NSString *sdkAppId = nil;
    NSString *accountType = nil;
    
    // check the params
    if (![params objectForKey:@"sdkAppId"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"sdkAppId参数错误"];
        return ;
    }
    sdkAppId = [params objectForKey:@"sdkAppId"];
    
    if (![params objectForKey:@"accountType"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"accountType参数错误"];
        return ;
    }
    accountType = [params objectForKey:@"accountType"];
    
    
    TIMManager *manager = [TIMManager sharedInstance];
    TIMSdkConfig *config = [[TIMSdkConfig alloc] init];
    config.sdkAppId = [sdkAppId intValue];
    config.accountType = accountType;
    //        config.sdkAppId = 1400082284;
    //        config.accountType = @"26309";
    config.disableCrashReport = NO;
    config.connListener = self;
    
    int result = [manager initSdk:config];
    
    BOOL isAutoLogin = [IMAPlatform isAutoLogin];
    if (isAutoLogin)
    {
        self._loginParam = [IMALoginParam loadFromLocal];
    }
    else
    {
        self._loginParam = [[IMALoginParam alloc] init];
    }
    
    //        [IMAPlatform configWith:self._loginParam.config];
    TIMUserConfig *userConfig = [[TIMUserConfig alloc] init];
    //    userConfig.disableStorage = YES;//禁用本地存储（加载消息扩展包有效）
    //    userConfig.disableAutoReport = YES;//禁止自动上报（加载消息扩展包有效）
    //    userConfig.enableReadReceipt = YES;//开启C2C已读回执（加载消息扩展包有效）
    userConfig.disableRecnetContact = NO;//不开启最近联系人（加载消息扩展包有效）
    userConfig.disableRecentContactNotify = YES;//不通过onNewMessage:抛出最新联系人的最后一条消息（加载消息扩展包有效）
    userConfig.enableFriendshipProxy = YES;//开启关系链数据本地缓存功能（加载好友扩展包有效）
    userConfig.enableGroupAssistant = YES;//开启群组数据本地缓存功能（加载群组扩展包有效）
    TIMGroupInfoOption *giOption = [[TIMGroupInfoOption alloc] init];
    giOption.groupFlags = 0xffffff;//需要获取的群组信息标志（TIMGetGroupBaseInfoFlag）,默认为0xffffff
    giOption.groupCustom = nil;//需要获取群组资料的自定义信息（NSString*）列表
    userConfig.groupInfoOpt = giOption;//设置默认拉取的群组资料
    TIMGroupMemberInfoOption *gmiOption = [[TIMGroupMemberInfoOption alloc] init];
    gmiOption.memberFlags = 0xffffff;//需要获取的群成员标志（TIMGetGroupMemInfoFlag）,默认为0xffffff
    gmiOption.memberCustom = nil;//需要获取群成员资料的自定义信息（NSString*）列表
    userConfig.groupMemberInfoOpt = gmiOption;//设置默认拉取的群成员资料
    TIMFriendProfileOption *fpOption = [[TIMFriendProfileOption alloc] init];
    fpOption.friendFlags = 0xffffff;//需要获取的好友信息标志（TIMProfileFlag）,默认为0xffffff
    fpOption.friendCustom = nil;//需要获取的好友自定义信息（NSString*）列表
    fpOption.userCustom = nil;//需要获取的用户自定义信息（NSString*）列表
    userConfig.friendProfileOpt = fpOption;//设置默认拉取的好友资料
    //        userConfig.userStatusListener = self;//用户登录状态监听器
    userConfig.refreshListener = self;//会话刷新监听器（未读计数、已读同步）（加载消息扩展包有效）
    //    userConfig.receiptListener = self;//消息已读回执监听器（加载消息扩展包有效）
    //    userConfig.messageUpdateListener = self;//消息svr重写监听器（加载消息扩展包有效）
    //    userConfig.uploadProgressListener = self;//文件上传进度监听器
    //    userConfig.groupEventListener todo
    userConfig.messgeRevokeListener = self;
    //        userConfig.friendshipListener = self;//关系链数据本地缓存监听器（加载好友扩展包、enableFriendshipProxy有效）
    //        userConfig.groupListener = self;//群组据本地缓存监听器（加载群组扩展包、enableGroupAssistant有效）
    result = [manager setUserConfig:userConfig];
    [[TIMManager sharedInstance] addMessageListener:self];
    
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"调起成功"];
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}


- (void)registerNewMessageListerner:(CDVInvokedUrlCommand *) command
{
    self.commonCallbackId = command.callbackId;
}

- (void)login:(CDVInvokedUrlCommand *)command
{
    self.currentCallbackId = command.callbackId;

    
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    NSString *identifier = nil;
    NSString *userSig = nil;
    NSString *appidAt3rd = nil;

    // check the params
    if (![params objectForKey:@"identifier"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"identifier 参数错误"];
        return ;
    }
    identifier = [params objectForKey:@"identifier"];

    if (![params objectForKey:@"userSig"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"userSig 参数错误"];
        return ;
    }
    userSig = [params objectForKey:@"userSig"];

    if (![params objectForKey:@"appidAt3rd"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"appidAt3rd 参数错误"];
        return ;
    }
    appidAt3rd = [params objectForKey:@"appidAt3rd"];

    self._loginParam.identifier = identifier;
    self._loginParam.userSig = userSig;
    self._loginParam.appidAt3rd = appidAt3rd;
    
    [[TIMManager sharedInstance] login:self._loginParam succ:^{
        [self successWithCallbackID:self.currentCallbackId];
    } fail:^(int code, NSString *msg) {
        [self failWithCallbackID:self.currentCallbackId withCode:code];
    }];
}

- (void)logout:(CDVInvokedUrlCommand *)command
{
    self.currentCallbackId = command.callbackId;
    [[TIMManager sharedInstance] logout:^(){
        [self successWithCallbackID:self.currentCallbackId];
    } fail:^(int code, NSString *msg) {
        [self failWithCallbackID:self.currentCallbackId withCode:code];
    }];
}


- (void)sendText:(TIMConversation*)conversation text:(NSString *)text callbackId: (NSString *) callbackId
{
    TIMTextElem *elem = [[TIMTextElem alloc] init];
    elem.text = text;
    TIMMessage *msg = [[TIMMessage alloc] init];
    [msg addElem:elem];
    
    [conversation sendMessage:msg succ:^(){
        [self successWithCallbackID:callbackId];
    } fail:^(int code, NSString *msg) {
        [self failWithCallbackID:callbackId withCode:code];
    }];
}

- (void)sendFace:(TIMConversation*)conversation faceId:(NSString *)faceId callbackId: (NSString *) callbackId
{
    TIMFaceElem *elem = [[TIMFaceElem alloc] init];
    elem.index = [faceId intValue];
    TIMMessage *msg = [[TIMMessage alloc] init];
    [msg addElem:elem];
    
    [conversation sendMessage:msg succ:^(){
        [self successWithCallbackID:callbackId];
    } fail:^(int code, NSString *msg) {
        [self failWithCallbackID:callbackId withCode:code];
    }];
}

- (void)sendAudioRecord:(TIMConversation*)conversation soundSavePath:(NSString *)soundSavePath soundDur:(int) dur callbackId: (NSString *) callbackId
{
    TIMSoundElem *elem = [[TIMSoundElem alloc] init];
    elem.path = soundSavePath;
    elem.second = (int)dur;
    
    TIMMessage *msg = [[TIMMessage alloc] init];
    [msg addElem:elem];
    
    [conversation sendMessage:msg succ:^(){
        [self successWithCallbackID:callbackId];
    } fail:^(int code, NSString *msg) {
        [self failWithCallbackID:callbackId withCode:code];
    }];
}

- (void)sendImage:(TIMConversation*)conversation filePath:(NSString *)filePath isOrigal:(bool) origal callbackId: (NSString *) callbackId
{
    TIMImageElem *elem = [[TIMImageElem alloc] init];
    elem.path = filePath;
    
    if (origal)
    {
        elem.level = TIM_IMAGE_COMPRESS_ORIGIN;
    }
    else
    {
        elem.level = TIM_IMAGE_COMPRESS_HIGH;
    }
    
    TIMMessage *msg = [[TIMMessage alloc] init];
    [msg addElem:elem];
    
    [conversation sendMessage:msg succ:^(){
        
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:[NSString stringWithFormat:@"%d",elem.taskId] forKey:@"taskid"];
        
        [self successWithCallbackID:callbackId withMessage:[self dictionaryToJson:params]];
    } fail:^(int code, NSString *msg) {
        [self failWithCallbackID:callbackId withCode:code];
    }];
}

- (void)sendCustom:(TIMConversation*)conversation data:(NSData *)data callbackId: (NSString *) callbackId
{
    TIMCustomElem *elem = [[TIMCustomElem alloc] init];
    elem.data = data;
    TIMMessage *msg = [[TIMMessage alloc] init];
    [msg addElem:elem];
    
    [conversation sendMessage:msg succ:^(){
        [self successWithCallbackID:callbackId];
    } fail:^(int code, NSString *msg) {
        [self failWithCallbackID:callbackId withCode:code];
    }];
}


- (void)sendMessageToUser:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    NSString *identifier = nil;
    if (![params objectForKey:@"identifier"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"identifier 参数错误"];
        return ;
    }
    identifier = [params objectForKey:@"identifier"];
    
    NSString *identifierType = nil;
    if (![params objectForKey:@"identifierType"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"identifierType 参数错误"];
        return ;
    }
    identifierType = [params objectForKey:@"identifierType"];
    
    TIMConversation * conversation;
    if ([identifierType isEqualToString:@"user"]) {
        conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:identifier];
    } else {
        conversation =  [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:identifier];
    }
    
    if ([params objectForKey:@"text"])
    {
        NSString *text = [params objectForKey:@"text"];
        [self sendText:conversation text:text callbackId:command.callbackId];
        return;
    }
    
    if ([params objectForKey:@"faceId"])
    {
        NSString *text = [params objectForKey:@"faceId"];
        [self sendFace:conversation faceId:text callbackId:command.callbackId];
        return;
    }
    
    if ([params objectForKey:@"customData"])
    {
        NSString *customData = [params objectForKey:@"customData"];
        [self sendCustom:conversation data:[customData dataUsingEncoding:NSUTF8StringEncoding] callbackId:command.callbackId];
        return;
    }
    
    if ([params objectForKey:@"imagePath"])
    {
        NSString *imagePath = [params objectForKey:@"imagePath"];
        
        bool isOrigal = false;
        if ([params objectForKey:@"isOrigal"])
        {
            isOrigal = true;
        }
        
        [self sendImage:conversation filePath:imagePath isOrigal:isOrigal callbackId:command.callbackId];
        return;
    }
    
    
    if ([params objectForKey:@"audioPath"])
    {
        NSString *audioPath = [params objectForKey:@"audioPath"];
        
        NSString *lenStr = nil;
        if (![params objectForKey:@"length"])
        {
            [self failWithCallbackID:command.callbackId withMessage:@"length 参数错误"];
            return ;
        }
        lenStr = [params objectForKey:@"lenStr"];
        
        [self sendAudioRecord:conversation soundSavePath:audioPath soundDur:[lenStr intValue] callbackId:command.callbackId];
        return;
    }
    
    [self failWithCallbackID:command.callbackId withMessage:@"没有适合的类型"];
}

- (void)getFriendList:(CDVInvokedUrlCommand *)command{
    
    [[TIMFriendshipManager sharedInstance] getFriendList:^(NSArray *friends) {
        NSMutableArray *fris =[[NSMutableArray alloc] init];
        for(TIMUserProfile* friend in friends){
            //自定义code
            NSMutableDictionary* fri = [[NSMutableDictionary alloc] init];
            [fri setValue:friend.identifier forKey:@"identifier"];
            [fri setValue:friend.faceURL forKey:@"faceURL"];
            [fri setValue:friend.nickname forKey:@"nickname"];
            [fris addObject:fri];
        }
        [self successWithCallbackID:command.callbackId withMessage:[self arrayToJson:fris]];
    } fail:^(int code, NSString *err) {
        [self failWithCallbackID:command.callbackId withCode:code];
    }];
}

- (void)setFriendBlackList:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    NSString *identifier = nil;
    if (![params objectForKey:@"identifier"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"identifier 参数错误"];
        return ;
    }
    identifier = [params objectForKey:@"identifier"];
    
    [[TIMFriendshipManager sharedInstance] addBlackList:@[identifier] succ:^(NSArray *friends) {
        [self successWithCallbackID:command.callbackId];
    } fail:^(int code, NSString *err) {
        [self failWithCallbackID:command.callbackId withCode:code];
    }];
}

- (void)agreeAddFriend:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    NSString *identifier = nil;
    if (![params objectForKey:@"identifier"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"identifier 参数错误"];
        return ;
    }
    identifier = [params objectForKey:@"identifier"];
    
    TIMFriendResponse *response = [[TIMFriendResponse alloc] init];
    response.identifier = identifier;
    response.responseType = TIM_FRIEND_RESPONSE_AGREE_AND_ADD;
    [[TIMFriendshipManager sharedInstance] doResponse:@[response] succ:^(NSArray *data) {
        [self successWithCallbackID:command.callbackId];
    } fail:^(int code, NSString *err) {
        [self failWithCallbackID:command.callbackId withCode:code];
    }];
}

- (void)refuseAddFriend:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    NSString *identifier = nil;
    if (![params objectForKey:@"identifier"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"identifier 参数错误"];
        return ;
    }
    identifier = [params objectForKey:@"identifier"];
    
    TIMFriendResponse *response = [[TIMFriendResponse alloc] init];
    response.identifier = identifier;
    response.responseType = TIM_FRIEND_RESPONSE_REJECT;
    [[TIMFriendshipManager sharedInstance] doResponse:@[response] succ:^(NSArray *data) {
        [self successWithCallbackID:command.callbackId];
    } fail:^(int code, NSString *err) {
        [self failWithCallbackID:command.callbackId withCode:code];
    }];
}

- (void)deleteFriend:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    NSString *identifier = nil;
    if (![params objectForKey:@"identifier"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"identifier 参数错误"];
        return ;
    }
    identifier = [params objectForKey:@"identifier"];
    
    [[TIMFriendshipManager sharedInstance] delFriend:TIM_FRIEND_DEL_BOTH users:@[identifier] succ:^(NSArray * arr) {
        [self successWithCallbackID:command.callbackId];
    } fail:^(int code, NSString * err) {
//        NSLog(@"add friend fail: code=%d err=%@", code, err);
        [self failWithCallbackID:command.callbackId withMessage: err];
    }];
//    - (int)delFriend:(TIMDelFriendType)delType users:(NSArray*)users succ:(TIMFriendSucc)succ fail:(TIMFail)fail;
}
 - (void)requestAddFriend:(CDVInvokedUrlCommand *)command
 {
     
     NSDictionary *params = [command.arguments objectAtIndex:0];
     if (!params)
     {
         [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
         return ;
     }
//     self.currentCallbackId = command.callbackId;
     NSMutableArray * users = [[NSMutableArray alloc] init];


     NSString *identifier = nil;
     NSString *remark = nil;
     NSString *addWording = nil;

     // check the params
     if (![params objectForKey:@"identifier"])
     {
         [self failWithCallbackID:command.callbackId withMessage:@"identifier 参数错误"];
         return ;
     }
     identifier = [params objectForKey:@"identifier"];

     if (![params objectForKey:@"remark"])
     {
         [self failWithCallbackID:command.callbackId withMessage:@"remark 参数错误"];
         return ;
     }
     remark = [params objectForKey:@"remark"];

     if (![params objectForKey:@"addWording"])
     {
         [self failWithCallbackID:command.callbackId withMessage:@"addWording 参数错误"];
         return ;
     }
     addWording = [params objectForKey:@"addWording"];



     TIMAddFriendRequest* req = [[TIMAddFriendRequest alloc] init];
     // 添加好友 iOS_002
//     req.identifier = @"10515";
     req.identifier = identifier;
     // 添加备注 002Remark
     req.remark = remark;
     // 添加理由
     req.addWording = addWording;
     [users addObject:req];
     

     [[TIMFriendshipManager sharedInstance] addFriend:users succ:^(NSArray * arr) {
         for (TIMFriendResult * res in arr) {
             if (res.status != TIM_FRIEND_STATUS_SUCC) {
//                 if (res.status == TIM_ADD_FRIEND_STATUS_ALREADY_FRIEND) {
//                      [[TIMFriendshipManager sharedInstance] delFriend:TIM_FRIEND_DEL_BOTH users:@[req.identifier] succ:^(NSArray *array) {
//
//                          // 从本地好友中找到该人，并删除
//                          // 只会返回一个
//                          for (TIMFriendResult *res in array)
//                          {
//                 //             IMAUser *temp = [[IMAUser alloc] initWith:res.identifier];
//                 //             [self.contactMgr removeUser:temp];
//                          }
//
//                      } fail:^(int code, NSString * err) {
//                                   NSLog(@"add friend fail: code=%d err=%@", code, err);
//                                   [self failWithCallbackID:command.callbackId withError: err];
//                               }];
//                 }
                 [self failWithCallbackID:command.callbackId withCode: res.status];
             }
             else {
                 NSLog(@"AddFriend succ: user=%@ status=%d", res.identifier, res.status);
                 [self successWithCallbackID:command.callbackId];
             }
         }
     } fail:^(int code, NSString * err) {
         NSLog(@"add friend fail: code=%d err=%@", code, err);
         [self failWithCallbackID:command.callbackId withMessage: err];
     }];

 }


//消息撤回通知
- (void)onRevokeMessage:(TIMMessageLocator*)locator
{
    // [[NSNotificationCenter defaultCenter] postNotificationName:kIMAMSG_RevokeNotification object:locator];
    // [self changeLastMsg:locator];
}


#pragma mark -TIMRefreshListener

- (void)onRefresh
{
    // TODO:重新刷新会话列列
//    DebugLog(@"=========>>>>> 刷新会话列表");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.contactMgr asyncConfigContact];//从以前的OnProxyStatusChange里面移动过来的
//        [self.conversationMgr asyncConversationList];
//        [[TIMManager sharedInstance] addMessageListener:self.conversationMgr];
//    });
//
//
//    [self.contactMgr asyncConfigGroup];
//    [[TIMManager sharedInstance] addMessageListener:self];
//    TIMMessageListenerImpl * impl = [[TIMMessageListenerImpl alloc] init];
//    [IMAPlatform configWith:NULL];
//    dispatch_async(dispatch_get_main_queue(), ^{
////        [[TIMManager sharedInstance] addMessageListener:self];
//        [[TIMManager sharedInstance] addMessageListener:[IMAPlatform sharedInstance]];
//
//    });
//    [[TIMManager sharedInstance] addMessageListener:[IMAPlatform configWith:NULL]];
}

- (void)onRefreshConversations:(NSArray*)conversations
{
//    [self.conversationMgr asyncConversationList];
    [[IMAPlatform sharedInstance] refresh];
}

//@end


- (void)setSelfProfile:(CDVInvokedUrlCommand *)command{
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params)
    {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }
    
    
    NSString *allowFlag = nil;
    if (![params objectForKey:@"allowFlag"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"allowFlag 参数错误"];
        return ;
    }
    allowFlag = [params objectForKey:@"allowFlag"];
    
    
    NSDictionary *custom = nil;
    if (![params objectForKey:@"custom"])
    {
        [self failWithCallbackID:command.callbackId withMessage:@"custom 参数错误"];
        return ;
    }
    custom = [params objectForKey:@"custom"];
    
    TIMFriendProfileOption * option = [[TIMFriendProfileOption alloc] init];
    option.friendFlags = 0xffff;
    TIMUserProfile * profile = [[TIMUserProfile alloc] init];
    if ([allowFlag isEqualToString:@"allow"]) {
        profile.allowType = TIM_FRIEND_ALLOW_ANY;
    } else if ([allowFlag isEqualToString:@"deny"]) {
        profile.allowType = TIM_FRIEND_DENY_ANY;
    } else {
        profile.allowType = TIM_FRIEND_NEED_CONFIRM;
    }
    
//    NSString *str = @"a";
//    NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:[@"a" dataUsingEncoding:NSUTF8StringEncoding], @"init", nil];
//    [dict removeObjectForKey:@"init"];
    NSMutableDictionary *customInfo = [[NSMutableDictionary alloc] init];
//    bool isInit = false;
    for (id key in custom) {
        NSString *str = [custom objectForKey:key];
        [customInfo setValue:[str dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
    }
//    profile.customInfo =  customInfo;
    
    //    profile.selfSignature = [NSData dataWithBytes:"1234" length:4];
    //    profile.gender = TIM_GENDER_MALE;
    //    profile.birthday = 12345;
    //    profile.location = [NSData dataWithBytes:"location" length:8];
    //    profile.language = 1;
    
    [[TIMFriendshipManager sharedInstance] modifySelfProfile:option profile:profile succ:^() {
        [self successWithCallbackID:command.callbackId];
    } fail:^(int code, NSString * err) {
        [self failWithCallbackID:command.callbackId withCode:code];
    }];
}
- (void)getSelfProfile:(CDVInvokedUrlCommand *)command{
    [[TIMFriendshipManager sharedInstance] getSelfProfile:^(TIMUserProfile * profile) {
//        NSLog(@"GetSelfProfile identifier=%@ nickname=%@ allowType=%d", profile.identifier, profile.nickname, profile.allowType);
        NSMutableDictionary *profileDic = [[NSMutableDictionary alloc] init];
        if (profile.allowType == TIM_FRIEND_ALLOW_ANY) {
            [profileDic setValue:@"allow" forKey:@"allowType"];
        } else if (profile.allowType == TIM_FRIEND_DENY_ANY) {
            [profileDic setValue:@"deny" forKey:@"allowType"];
        } else {
            [profileDic setValue:@"needConfirm" forKey:@"allowType"];
        }
        [profileDic setValue:[self dictionaryToJson: profile.customInfo] forKey:@"custom"];
        [self successWithCallbackID:command.callbackId withMessage:[self dictionaryToJson:profileDic]];
    } fail:^(int code, NSString * err) {
        [self failWithCallbackID:command.callbackId withCode:code];
    }];
}
/**
 *  新消息通知
 *
 *  @param msgs 新消息列表，TIMMessage 类型数组
 */
- (void)onNewMessage:(NSArray *)msgs
{
    for (TIMMessage *msg in msgs)
    {
        TIMConversation *conv = [msg getConversation];
        BOOL isSystemMsg = [conv getType] == TIM_SYSTEM;
        BOOL isAddGroupReq = NO;
//        BOOL isAddFriendReq = NO;
//        BOOL isContinue = YES;
        if (isSystemMsg)
        {
            int elemCount = [msg elemCount];
            for (int i = 0; i < elemCount; i++)
            {
                TIMElem* elem = [msg getElem:i];
                TIMSNSSystemElem * system_elem = (TIMSNSSystemElem * )elem;
                if ([elem isKindOfClass:[TIMGroupSystemElem class]])
                {
                    TIMGroupSystemElem *gse = (TIMGroupSystemElem *)elem;
                    if (gse.type == TIM_GROUP_SYSTEM_ADD_GROUP_REQUEST_TYPE)
                    {
//                        isContinue = NO;
                        isAddGroupReq = YES;
                    }
                }
                else if ([elem isKindOfClass:[TIMSNSSystemElem class]])
                {
                    TIM_SNS_SYSTEM_TYPE type = ((TIMSNSSystemElem *)elem).type;
                    if (type == TIM_SNS_SYSTEM_ADD_FRIEND_REQ)
                    {
                        if (!msg.isSelf)
                        {
//                            isContinue = NO;
                            for (TIMSNSChangeInfo * info in [system_elem users]) {
//                                NSLog(@"user %@ request friends: reason=%@", [info identifier], [info wording]);
                                NSMutableDictionary *addFriendReq = [[NSMutableDictionary alloc] init];
                                [addFriendReq setValue:@"addFriendReq" forKey:@"type"];
                                [addFriendReq setValue:[info identifier] forKey:@"identifier"];
                                [addFriendReq setValue:[info wording] forKey:@"wording"];
                                [addFriendReq setValue:[info source] forKey:@"source"];
                                [self commanCallback:addFriendReq];
                            }

                        }
                    } else if (type == TIM_SNS_SYSTEM_ADD_FRIEND) {
//                        isContinue = NO;
                        for (TIMSNSChangeInfo * info in [system_elem users]) {
//                            NSLog(@"user %@ request friends: reason=%@", [info identifier], [info wording]);
                            NSMutableDictionary *addFriend = [[NSMutableDictionary alloc] init];
                            [addFriend setValue:@"addFriend" forKey:@"type"];
                            [addFriend setValue:[info identifier] forKey:@"identifier"];
                            [self commanCallback:addFriend];
                        }
                    } else if (type == TIM_SNS_SYSTEM_DEL_FRIEND) {
                        for (TIMSNSChangeInfo * info in [system_elem users]) {
//                            NSLog(@"user %@ request friends: reason=%@", [info identifier], [info wording]);
                            NSMutableDictionary *delFriend = [[NSMutableDictionary alloc] init];
                            [delFriend setValue:@"delFriend" forKey:@"type"];
                            [delFriend setValue:[info identifier] forKey:@"identifier"];
                            [self commanCallback:delFriend];
                        }
                    }
                }
                else {
                    //自定义消息系统消息，暂时不处理
                }
            }
            continue;
        }

        if (!msg.isSelf) {
            NSString *receiver = [conv getReceiver];

            int elemCount = [msg elemCount];
            for (int i = 0; i < elemCount; i++)
            {
                TIMElem* elem = [msg getElem:i];
                NSMutableDictionary *chat = [[NSMutableDictionary alloc] init];
                [chat setValue:@"chat" forKey:@"type"];
                [chat setValue:receiver forKey:@"receiver"];

                if ([conv getType] == TIM_C2C ) {
                    [chat setValue:@"private" forKey:@"chatType"];
                } else {
                    [chat setValue:@"group" forKey:@"chatType"];
                }
                if ([elem isKindOfClass:[TIMTextElem class]]) {
                    TIMTextElem *textElem = (TIMTextElem *)elem;
                    [chat setValue:[textElem text] forKey:@"text"];
                } else if ([elem isKindOfClass:[TIMImageElem class]]) {
                    TIMImageElem *imgElem = (TIMImageElem *)elem;
                    [chat setValue:[imgElem path] forKey:@"imgUrl"];
                    if (imgElem.imageList.count > 0)
                    {
                        for (TIMImage *timImage in imgElem.imageList)
                        {
                            if (timImage.type == TIM_IMAGE_TYPE_THUMB)
                            {
                                [chat setValue:[timImage url] forKey:@"thumbUrl"];
                            } else if (timImage.type == TIM_IMAGE_TYPE_LARGE) {
                                [chat setValue:[timImage url] forKey:@"largeUrl"];
                            } else {
                                [chat setValue:[timImage url] forKey:@"originUrl"];
                            }
                        }
                    }
                } else if ([elem isKindOfClass:[TIMFaceElem class]]) {
                    TIMFaceElem *faceElem = (TIMFaceElem *)elem;
                    [chat setValue:[NSNumber numberWithInteger: [faceElem index]] forKey:@"faceId"];
                } else if ([elem isKindOfClass:[TIMSoundElem class]]) {
                    TIMSoundElem *soundElem = (TIMSoundElem *)elem;
                    [chat setValue:[soundElem path] forKey:@"sound"];
                } else if ([elem isKindOfClass:[TIMLocationElem class]]) {
                    TIMLocationElem *localElem = (TIMLocationElem *)elem;
                    [chat setValue:[NSNumber numberWithDouble: [localElem latitude]] forKey:@"latitude"];
                    [chat setValue:[NSNumber numberWithDouble: [localElem longitude]]  forKey:@"longitude"];
                    [chat setValue:[localElem desc] forKey:@"locateDesc"];
                } else if ([elem isKindOfClass:[TIMFileElem class]]) {
                    TIMFileElem *fileElem = (TIMFileElem *)elem;
                    [chat setValue:[fileElem path] forKey:@"filePath"];
                    [chat setValue:[fileElem uuid]  forKey:@"uuid"];
                    [chat setValue:[NSNumber numberWithInt: [fileElem fileSize]] forKey:@"fileSize"];
                    [chat setValue:[fileElem filename] forKey:@"fileName"];
                } else if ([elem isKindOfClass:[TIMCustomElem class]]) {
                    TIMCustomElem *cusElem = (TIMCustomElem *)elem;
                    [chat setValue:[cusElem data] forKey:@"data"];
                }

                [self commanCallback:chat];
            }
        }
    }
}

- (NSString*) dictionaryToJson:(NSMutableDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return str;
}

- (NSString*) arrayToJson:(NSArray *)array{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)commanCallback:(NSDictionary *) params
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self dictionaryToJson:params]];
    [commandResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:commandResult callbackId:self.commonCallbackId];
}

- (void)successWithCallbackID:(NSString *)callbackID
{
    [self successWithCallbackID:callbackID withMessage:@"OK"];
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withCode:(int) code
{
    [self failWithCallbackID:callbackID withMessage:[NSString stringWithFormat:@"%d",code]];
}


- (void)failWithCallbackID:(NSString *)callbackID withError:(NSError *)error
{
    [self failWithCallbackID:callbackID withMessage:[error localizedDescription]];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}



/**
 *  网络连接成功
 */
- (void)onConnSucc {
    
}

/**
 *  网络连接失败
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onConnFailed:(int)code err:(NSString*)err {
    
}

/**
 *  网络连接断开（断线只是通知用户，不需要重新登陆，重连以后会自动上线）
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onDisconnect:(int)code err:(NSString*)err{
    
}


/**
 *  连接中
 */
- (void)onConnecting{
    
}

@end
