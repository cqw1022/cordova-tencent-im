//
//  CDVWxpay.h
//  cordova-plugin-wxpay
//
//  Created by tong.wu on 06/30/15.
//
//

#import <Cordova/CDV.h>
#import "TIMAdapter.h"
//#import "WXApi.h"
//#import "WXApiObject.h"

@interface CDVTxim:CDVPlugin <TIMConnListener>

@property (nonatomic, strong) NSString *currentCallbackId;
@property (nonatomic, strong) TIMConversation *conversation;
@property (nonatomic, strong) IMALoginParam *_loginParam;
// @property (nonatomic, strong) IMAConversationManager *_conversationMgr;

- (void)initSdk:(CDVInvokedUrlCommand *)command;
- (void)login:(CDVInvokedUrlCommand *)command;
- (void)logout:(CDVInvokedUrlCommand *)command;
- (void)requestAddFriend:(CDVInvokedUrlCommand *)command;

// 初始化
// 登录
// 退出登录
// 消息：onNewMessage，包括添加好友请求，其他通知等

// 添加好友请求,客户端直接调用

// 同意添加好友，先向 游戏服务器请求（等第一个版本处理完再处理），然后再调用同意接口
// 私聊
// 黑名单，设置黑名单
// 获取好友，获取黑名单
// 删除好友


// - (void)getConversation:(CDVInvokedUrlCommand *)command;
// 离线消息
// 未读消息：登录后获取所有回话，然后获取漫游信息
// 获取本地存储对话，私聊存储
// 发送消息
// 新的消息
@end
