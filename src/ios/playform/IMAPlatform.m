//
//  IMAPlatform.m
//  TIMAdapter
//
//  Created by AlexiChen on 16/2/17.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "IMAPlatform.h"

@interface IMAPlatform ()

@property (nonatomic, assign) TCQALNetwork networkType;

@end

@implementation IMAPlatform

#define kIMAPlatformConfig          @"IMAPlatformConfig"


static IMAPlatform *_sharedInstance = nil;

+ (instancetype)configWith:(IMAPlatformConfig *)cfg
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _sharedInstance = [[IMAPlatform alloc] init];
        [_sharedInstance configIMSDK:cfg];
    });
    
    return _sharedInstance;
    
}
static Class kHostClass = Nil;
+ (void)configHostClass:(Class)hostcls
{
//    if (![hostcls isSubclassOfClass:[IMAHost class]])
//    {
//        DebugLog(@"%@ 必须是IMAHost的子类型", hostcls);
//    }
//    else
//    {
//        kHostClass = hostcls;
//    }
}
+ (instancetype)sharedInstance
{
    // TODO:
    return _sharedInstance;
}

#define kIMAPlatform_AutoLogin_Key @"kIMAPlatform_AutoLogin_Key"

+ (BOOL)isAutoLogin
{
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"kIMAPlatform_AutoLogin_Key"];
    return [num boolValue];
}
+ (void)setAutoLogin:(BOOL)autologin
{
    [[NSUserDefaults standardUserDefaults] setObject:@(autologin) forKey:kIMAPlatform_AutoLogin_Key];
}

//
//- (void)initialFriendProxy:(TIMSucc)succ fail:(TIMFail)fail
//{
//    // 说明登录成功
////    _friendShipMgr = [[TIMFriendshipManager sharedInstance] getFriendshipProxy];
////    [_friendShipMgr SetProxyListener:self];
////    [_friendShipMgr SyncWithFlags:0XFF custom:nil succ:succ fail:fail];
//    
//    
//}


//- (IMAContactManager *)contactMgr
//{
//    if (!_contactMgr)
//    {
//        _contactMgr = [[IMAContactManager alloc] init];
//    }
//    return _contactMgr;
//}

//- (IMAConversationManager *)conversationMgr
//{
//    if (!_conversationMgr)
//    {
//        _conversationMgr = [[IMAConversationManager alloc] init];
//    }
//    return _conversationMgr;
//}
//
//- (IMAUser *)getReceiverOf:(IMAConversation *)conv
//{
//    NSString *receiver = [conv receiver];
//    if (conv.type == TIM_C2C)
//    {
//        return [self.contactMgr getUserByUserId:receiver];
//    }
//    else if (conv.type == TIM_GROUP)
//    {
//        // 查询群列表
//        return [self.contactMgr getUserByGroupId:receiver];
//    }
//    else
//    {
//        DebugLog(@"不支持的会话模式");
//        return nil;
//    }
//}

- (void)configIMSDK:(IMAPlatformConfig *)cfg
{
     TIMManager *manager = [TIMManager sharedInstance];
    
    // [manager setEnv:cfg.environment];
    
    // TIMSdkConfig *config = [[TIMSdkConfig alloc] init];
    // config.sdkAppId = [kSdkAppId intValue] ;
    // config.accountType = kSdkAccountType;
    // config.disableCrashReport = NO;
    // config.connListener = self;
    // [manager initSdk:config];
    
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
    userConfig.userStatusListener = self;//用户登录状态监听器
    userConfig.refreshListener = self;//会话刷新监听器（未读计数、已读同步）（加载消息扩展包有效）
//    userConfig.receiptListener = self;//消息已读回执监听器（加载消息扩展包有效）
//    userConfig.messageUpdateListener = self;//消息svr重写监听器（加载消息扩展包有效）
//    userConfig.uploadProgressListener = self;//文件上传进度监听器
//    userConfig.groupEventListener todo
    userConfig.messgeRevokeListener = self;
    userConfig.friendshipListener = self;//关系链数据本地缓存监听器（加载好友扩展包、enableFriendshipProxy有效）
    userConfig.groupListener = self;//群组据本地缓存监听器（加载群组扩展包、enableGroupAssistant有效）
    [manager setUserConfig:userConfig];
}

- (void)saveToLocal
{
    // 保存上一次联系人列表状态
//    [_contactMgr saveToLocal];
    
    // 保存Config状态
}

- (void)onLogoutCompletion
{
    [self offlineLogin];
    
//    self.offlineExitLivingBlock = nil;
    
    [IMAPlatform setAutoLogin:NO];
//    _host = nil;
    
#if kIsUseAVSDKAsLiveScene
    [TCAVSharedContext destroyContextCompletion:nil];
#endif
    
}

- (void)offlineLogin
{
    // 被踢下线，则清空单例中的数据，再登录后再重新创建
    [self saveToLocal];
    
//    _contactMgr = nil;
    
//    [[TIMManager sharedInstance] removeMessageListener:_conversationMgr];
//    _conversationMgr = nil;
}

- (void)logout:(TIMLoginSucc)succ fail:(TIMFail)fail
{
    __weak IMAPlatform *ws = self;
    
    [[TIMManager sharedInstance] logout:^{
        [ws onLogoutCompletion];
        if (succ)
        {
            succ();
        }
    } fail:^(int code, NSString *err) {
        [ws onLogoutCompletion];
        if (fail)
        {
            fail(code, err);
        }
    }];
}

//- (IMAPlatformConfig *)localConfig
//{
//    return _host.loginParm.config;
//}
//
//- (void)configHost:(TIMLoginParam *)param
//{
//    if (!_host)
//    {
//        if (kHostClass == Nil)
//        {
//            kHostClass = [IMAHost class];
//        }
//        _host = [[kHostClass alloc] init];
//    }
//    _host.loginParm = param;
//    [_host asyncProfile];
//
//#if kIsUseAVSDKAsLiveScene
//    [TCAVSharedContext configWithStartedContext:_host completion:nil];
//#endif
//}

//- (void)changeToNetwork:(TCQALNetwork)work
//{
//    if (work > EQALNetworkType_ReachableViaWWAN)
//    {
//        // 不处理这些
//        work = EQALNetworkType_ReachableViaWWAN;
//    }
//    DebugLog(@"网络切换到(-1:未知 0:无网 1:wifi 2:移动网):%d", work);
//    //    if (work != _networkType)
//    //    {
//    self.networkType = work;
//    
//    //    }
//}


//消息撤回通知
- (void)onRevokeMessage:(TIMMessageLocator*)locator
{
   // [[NSNotificationCenter defaultCenter] postNotificationName:kIMAMSG_RevokeNotification object:locator];
   // [self changeLastMsg:locator];
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
        
    }
//    for (TIMMessage *msg in msgs)
//    {
//        IMAMsg *imamsg = [IMAMsg msgWith:msg];
//
//        TIMConversation *conv = [msg getConversation];
//
//        BOOL isSystemMsg = [conv getType] == TIM_SYSTEM;
//
//        BOOL isAddGroupReq = NO;
//        BOOL isAddFriendReq = NO;
//        BOOL isContinue = YES;
//        if (isSystemMsg)
//        {
//            int elemCount = [msg elemCount];
//            for (int i = 0; i < elemCount; i++)
//            {
//                TIMElem* elem = [msg getElem:i];
//                if ([elem isKindOfClass:[TIMGroupSystemElem class]])
//                {
//                    TIMGroupSystemElem *gse = (TIMGroupSystemElem *)elem;
//                    if (gse.type == TIM_GROUP_SYSTEM_ADD_GROUP_REQUEST_TYPE)
//                    {
//                        isContinue = NO;
//                        isAddGroupReq = YES;
//                    }
//                }
//                else if ([elem isKindOfClass:[TIMSNSSystemElem class]])
//                {
//                    TIM_SNS_SYSTEM_TYPE type = ((TIMSNSSystemElem *)elem).type;
//                    if (type == TIM_SNS_SYSTEM_ADD_FRIEND_REQ)
//                    {
//                        if (!msg.isSelf)
//                        {
//                            isContinue = NO;
//                            isAddFriendReq = YES;
//                        }
//                    }
//                }
//            }
//            if (isContinue)
//            {
//                continue;
//            }
//        }
//
//        BOOL updateSucc = NO;
//
//        for (int i = 0; i < [_conversationList count]; i++)
//        {
//            IMAConversation *imaconv = [_conversationList objectAtIndex:i];
//            NSString *imaconvReceiver = [imaconv receiver];
//            if (imaconv.type == [conv getType] && ([imaconvReceiver isEqualToString:[conv getReceiver]] || [imaconvReceiver isEqualToString:[IMACustomConversation getCustomConversationID:imamsg]]))
//            {
//                if (imaconv == _chattingConversation)
//                {
//                    //如果是c2c会话，则更新“对方正在输入...”状态
//                    BOOL isInputStatus = NO;
//
//                    if (!msg.isSelf)
//                    {
//                        if ([_chattingConversation imaType] == TIM_C2C)
//                        {
//                            int elemCount = [imamsg.msg elemCount];
//                            for (int i = 0; i < elemCount; i++)
//                            {
//                                TIMElem* elem = [msg getElem:i];
//                                CustomElemCmd *elemCmd = [self isOnlineMsg:elem];
//
//                                if (elemCmd)
//                                {
//                                    isInputStatus = YES;
//                                    [[NSNotificationCenter defaultCenter] postNotificationName:kUserInputStatus object:elemCmd];
//                                }
//                            }
//                        }
//
//                        if (!isInputStatus)
//                        {
////                            [conv setReadMessage];
//                            imaconv.lastMessage = imamsg;
//                            [_chattingConversation onReceiveNewMessage:imamsg];
//                        }
//                    }
//                }
//                else
//                {
//                    TIMElem* elem = [msg getElem:0];
//                    CustomElemCmd *elemCmd = [self isOnlineMsg:elem];
//
//                    if (!elemCmd)
//                    {
//                        imaconv.lastMessage = imamsg;
//                        if (isSystemMsg)
//                        {
//                            __weak IMAConversationManager *ws = self;
//                            // 系统消息
//                            IMACustomConversation *customConv = (IMACustomConversation *)imaconv;
//                            [customConv saveMessage:imamsg succ:^(int newUnRead) {
//                                ws.unReadMessageCount += newUnRead;
//                                [ws updateOnChat:imaconv moveFromIndex:i];
//                            }];
//                        }
//                        else
//                        {
//                            //如果是自己发出去的消息，一定是已读(这里判断主要是用在多终端登录的情况下)
//                            if (![imamsg isMineMsg])
//                            {
//                                self.unReadMessageCount++;
//                            }
//                            [self updateOnChat:imaconv moveFromIndex:i];
//                        }
//                    }
//                }
//                updateSucc = YES;
//                break;
//            }
//        }
//
//        if (!updateSucc && _refreshStyle == EIMARefresh_None)
//        {
//            if (isSystemMsg)
//            {
//                NSString *receiverid = [IMACustomConversation getCustomConversationID:imamsg];
//                TIMConversation *imconv = [[TIMManager sharedInstance] getConversation:TIM_SYSTEM receiver:receiverid];
//                [imconv setReadMessage:nil succ:^{
//
//                } fail:^(int code, NSString *msg) {
//
//                }];
//                // 说明会话列表中没有该会话，新生建会话，并更新到
//                IMACustomConversation *temp = [[IMACustomConversation alloc] initWith:imconv andMsg:imamsg];
//                if (temp)
//                {
//                    __weak IMAConversationManager *ws = self;
//                    [temp saveMessage:imamsg succ:^(int newUnRead) {
//                        ws.unReadMessageCount += newUnRead;
//                    }];
//                    [_conversationList insertObject:temp atIndex:[self insertPosition]];
//                    [self updateOnNewConversation:temp];
//                }
//            }
//            else
//            {
//                // 说明会话列表中没有该会话，新生建会话，并更新到
//                IMAConversation *temp = [[IMAConversation alloc] initWith:conv];
//                temp.lastMessage = imamsg;
//                [_conversationList insertObject:temp atIndex:[self insertPosition]];
//                self.unReadMessageCount++;
//                [self updateOnNewConversation:temp];
//            }
//        }
//    }
}

@end



