//
//  CDVWxpay.m
//  cordova-plugin-wxpay
//
//  Created by tong.wu on 06/30/15.
//
//

#import "CDVTxim.h"

@implementation CDVTxim

#pragma mark "API"

- (void)initSdk:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        // check arguments
//        NSDictionary *params = [command.arguments objectAtIndex:0];
//        if (!params)
//        {
//            [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
//            return ;
//        }
//
//        NSString *sdkAppId = nil;
//        NSString *accountType = nil;
//
//        // check the params
//        if (![params objectForKey:@"sdkAppId"])
//        {
//            [self failWithCallbackID:command.callbackId withMessage:@"sdkAppId参数错误"];
//            return ;
//        }
//        sdkAppId = [params objectForKey:@"sdkAppId"];
//
//        if (![params objectForKey:@"accountType"])
//        {
//            [self failWithCallbackID:command.callbackId withMessage:@"accountType参数错误"];
//            return ;
//        }
//        accountType = [params objectForKey:@"accountType"];




        TIMManager *manager = [TIMManager sharedInstance];
        TIMSdkConfig *config = [[TIMSdkConfig alloc] init];
//        config.sdkAppId = sdkAppId ;
//        config.accountType = accountType;
        config.sdkAppId = 1400082284;
        config.accountType = @"26309";
        config.disableCrashReport = NO;
        
        [manager initSdk:config];

        BOOL isAutoLogin = [IMAPlatform isAutoLogin];
        if (isAutoLogin)
        {
            self._loginParam = [IMALoginParam loadFromLocal];
        }
        else
        {
            self._loginParam = [[IMALoginParam alloc] init];
        }

        [IMAPlatform configWith:self._loginParam.config];
//
//        CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"调起成功"];
//
//        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    }];
}

// - (IMAConversationManager *)conversationMgr
// {
//     if (!_conversationMgr)
//     {
//         _conversationMgr = [[IMAConversationManager alloc] init];
//     }
//     return _conversationMgr;
// }

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
    userSig = [params objectForKey:@"appidAt3rd"];


    self._loginParam.identifier = identifier;
    self._loginParam.userSig = userSig;
    self._loginParam.tokenTime = [[NSDate date] timeIntervalSince1970];
    self._loginParam.appidAt3rd = appidAt3rd;
    

   [[IMAPlatform sharedInstance] login:self._loginParam succ:^{
       
//        DebugLog(@"登录成功:%@ tinyid:%llu sig:%@", param.identifier, [[IMSdkInt sharedInstance] getTinyId], param.userSig);
       // [IMAPlatform setAutoLogin:YES];
       //去掉此处的获取群里表，放到IMAPlatform+IMSDKCallBack 的 onRefresh中去，如果直接在这里获取群里表，第一次安装app时，会拉去不到群列表
//        [ws configGroup];
       
       [self successWithCallbackID:self.currentCallbackId];
   } fail:^(int code, NSString *msg) {
       [self failWithCallbackID:self.currentCallbackId withMessage:msg];
   }];
}

- (void)logout:(CDVInvokedUrlCommand *)command
{
    self.currentCallbackId = command.callbackId;
    [[TIMManager sharedInstance] logout:^(){
        [self successWithCallbackID:self.currentCallbackId];
    } fail:^(int code, NSString *msg) {
        [self failWithCallbackID:self.currentCallbackId withMessage:msg];
    }];
}


// - (void)requestAddFriend:(CDVInvokedUrlCommand *)command
// {
        
//     self.currentCallbackId = command.callbackId;
//     NSMutableArray * users = [[NSMutableArray alloc] init];


//     NSString *identifier = nil;
//     NSString *remark = nil;
//     NSString *addWording = nil;

//     // check the params
//     if (![params objectForKey:@"identifier"])
//     {
//         [self failWithCallbackID:command.callbackId withMessage:@"identifier 参数错误"];
//         return ;
//     }
//     identifier = [params objectForKey:@"identifier"];

//     if (![params objectForKey:@"remark"])
//     {
//         [self failWithCallbackID:command.callbackId withMessage:@"remark 参数错误"];
//         return ;
//     }
//     remark = [params objectForKey:@"remark"];

//     if (![params objectForKey:@"addWording"])
//     {
//         [self failWithCallbackID:command.callbackId withMessage:@"addWording 参数错误"];
//         return ;
//     }
//     addWording = [params objectForKey:@"addWording"];



//     TIMAddFriendRequest* req = [[TIMAddFriendRequestalloc] init];
//     // 添加好友 iOS_002
//     req.identifier = identifier;
//     // 添加备注 002Remark
//     req.remark = remark;
//     // 添加理由
//     req.addWording = addWording;
//     [users addObject:req];
//     [[TIMFriendshipManager sharedInstance] addFriend:users succ:^(NSArray * arr) {
//         for (TIMFriendResult * res in arr) {
//             if (res.status != TIM_FRIEND_STATUS_SUCC) {
//                 [self successWithCallbackID:command.callbackId];
//             }
//             else {
//                 NSLog(@"AddFriend succ: user=%@ status=%d", res.identifier, res.status);
//                 [self failWithCallbackID:command.callbackId withMessage: res.status];
//             }
//         }
//     } fail:^(int code, NSString * err) {
//         NSLog(@"add friend fail: code=%d err=%@", code, err);
//         [self failWithCallbackID:command.callbackId withError: err];
//     }];

// }

// - (void)getConversation:(CDVInvokedUrlCommand *)command
// {
//     self.currentCallbackId = command.callbackId;
//     TIMConversationType conversationType = nil;
//     NSString *receiver = nil;

//     // check the params
//     if (![params objectForKey:@"conversationType"])
//     {
//         [self failWithCallbackID:command.callbackId withMessage:@"conversationType参数错误"];
//         return ;
//     }
//     conversationType = [params objectForKey:@"conversationType"];

//     if (![params objectForKey:@"receiver"])
//     {
//         [self failWithCallbackID:command.callbackId withMessage:@"receiver参数错误"];
//         return ;
//     }
//     receiver = [params objectForKey:@"receiver"];
//     self.conversation = [[TIMManager sharedInstance] getConversation:conversationType receiver:receiver];

// }



- (void)successWithCallbackID:(NSString *)callbackID
{
    [self successWithCallbackID:callbackID withMessage:@"OK"];
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
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

@end
