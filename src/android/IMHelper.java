package cordova.plugins.txim;

import android.os.Environment;
import android.util.Log;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMConnListener;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMGroupEventListener;
import com.tencent.imsdk.TIMGroupMemberInfo;
import com.tencent.imsdk.TIMGroupTipsElem;
import com.tencent.imsdk.TIMLogLevel;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMOfflinePushSettings;
import com.tencent.imsdk.TIMRefreshListener;
import com.tencent.imsdk.TIMSNSChangeInfo;
import com.tencent.imsdk.TIMSdkConfig;
import com.tencent.imsdk.TIMUserConfig;
import com.tencent.imsdk.TIMUserProfile;
import com.tencent.imsdk.TIMUserStatusListener;
import com.tencent.imsdk.ext.group.TIMGroupAssistantListener;
import com.tencent.imsdk.ext.group.TIMGroupCacheInfo;
import com.tencent.imsdk.ext.group.TIMUserConfigGroupExt;
import com.tencent.imsdk.ext.message.TIMManagerExt;
import com.tencent.imsdk.ext.message.TIMUserConfigMsgExt;
import com.tencent.imsdk.ext.sns.TIMFriendshipProxyListener;
import com.tencent.imsdk.ext.sns.TIMUserConfigSnsExt;
import com.tencent.imsdk.ext.sns.TIMFriendshipManagerExt;

import org.apache.cordova.CallbackContext;
import java.util.List;

import cordova.plugins.txim.event.MessageEvent;

import static cordova.plugins.txim.IM.instance;

/**
 * Created by hewz on 2017/7/13.
 */

class IMHelper {

    private static final String tag = "Plugin#IMHelper";

    static void initIMSdk(final int appid) {
        TIMSdkConfig config = new TIMSdkConfig(appid)
                .enableCrashReport(false)
                .enableLogPrint(true)
                .setLogLevel(TIMLogLevel.DEBUG)
                .setLogPath(Environment.getExternalStorageDirectory().getPath() + "/imLog/");

        TIMManager.getInstance().init(instance.cordova.getActivity().getApplicationContext(), config);

        TIMUserConfig userConfig = new TIMUserConfig()
                //设置用户状态变更事件监听器
                .setUserStatusListener(new TIMUserStatusListener() {
                    @Override
                    public void onForceOffline() {
                        //被其他终端踢下线
                        Log.i(tag, "onForceOffline");
                        final String js = "window.im.onForceOffline();";
                        instance.cordova.getActivity().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if (instance == null) {
                                    Log.i(tag, "instance is null");
                                    return;
                                }
                                instance.webView.loadUrl("javascript:" + js);
                            }
                        });
                    }

                    @Override
                    public void onUserSigExpired() {
                        //用户签名过期了，需要刷新userSig重新登录SDK
                        Log.i(tag, "onUserSigExpired");
                    }
                })
                //设置连接状态事件监听器
                .setConnectionListener(new TIMConnListener() {
                    @Override
                    public void onConnected() {
                        Log.i(tag, "onConnected");
                    }

                    @Override
                    public void onDisconnected(int code, String desc) {
                        Log.i(tag, "onDisconnected");
                    }

                    @Override
                    public void onWifiNeedAuth(String name) {
                        Log.i(tag, "onWifiNeedAuth");
                    }
                })
                //设置群组事件监听器
                .setGroupEventListener(new TIMGroupEventListener() {
                    @Override
                    public void onGroupTipsEvent(TIMGroupTipsElem elem) {
                        Log.i(tag, "onGroupTipsEvent, type: " + elem.getTipsType());
                    }
                })
                //设置会话刷新监听器
                .setRefreshListener(new TIMRefreshListener() {
                    @Override
                    public void onRefresh() {
                        Log.i(tag, "onRefresh");
                    }

                    @Override
                    public void onRefreshConversation(List<TIMConversation> conversations) {
                        Log.i(tag, "onRefreshConversation, conversation size: " + conversations.size());
                    }
                });

        //消息扩展用户配置
        userConfig = new TIMUserConfigMsgExt(userConfig)
                //禁用消息存储
                .enableStorage(true)
                //开启消息已读回执
                .enableReadReceipt(true);

        //资料关系链扩展用户配置
        userConfig = new TIMUserConfigSnsExt(userConfig)
                //开启资料关系链本地存储
                .enableFriendshipStorage(true)
                //设置关系链变更事件监听器
                .setFriendshipProxyListener(new TIMFriendshipProxyListener() {
                    @Override
                    public void OnAddFriends(List<TIMUserProfile> users) {
                        Log.i(tag, "OnAddFriends");
                    }

                    @Override
                    public void OnDelFriends(List<String> identifiers) {
                        Log.i(tag, "OnDelFriends");
                    }

                    @Override
                    public void OnFriendProfileUpdate(List<TIMUserProfile> profiles) {
                        Log.i(tag, "OnFriendProfileUpdate");
                    }

                    @Override
                    public void OnAddFriendReqs(List<TIMSNSChangeInfo> reqs) {
                        Log.i(tag, "OnAddFriendReqs");
                    }
                });

        //群组管理扩展用户配置
        userConfig = new TIMUserConfigGroupExt(userConfig)
                //开启群组资料本地存储
                .enableGroupStorage(true)
                //设置群组资料变更事件监听器
                .setGroupAssistantListener(new TIMGroupAssistantListener() {
                    @Override
                    public void onMemberJoin(String groupId, List<TIMGroupMemberInfo> memberInfos) {
                        Log.i(tag, "onMemberJoin");
                    }

                    @Override
                    public void onMemberQuit(String groupId, List<String> members) {
                        Log.i(tag, "onMemberQuit");
                    }

                    @Override
                    public void onMemberUpdate(String groupId, List<TIMGroupMemberInfo> memberInfos) {
                        Log.i(tag, "onMemberUpdate");
                    }

                    @Override
                    public void onGroupAdd(TIMGroupCacheInfo groupCacheInfo) {
                        Log.i(tag, "onGroupAdd");
                    }

                    @Override
                    public void onGroupDelete(String groupId) {
                        Log.i(tag, "onGroupDelete");
                    }

                    @Override
                    public void onGroupUpdate(TIMGroupCacheInfo groupCacheInfo) {
                        Log.i(tag, "onGroupUpdate");
                    }
                });

        //将用户配置与通讯管理器进行绑定
        TIMManager.getInstance().setUserConfig(userConfig);

    }

    static void login(final CallbackContext callbackContext, final String identify, final String usersig) {
        // identifier为用户名，userSig 为用户登录凭证
        TIMManager.getInstance().login(identify, usersig, new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {
                //错误码code和错误描述desc，可用于定位请求失败原因
                //错误码code列表请参见错误码表
                Log.d(tag, "login failed. code: " + code + " errmsg: " + desc);
                //初始化本地存储
                TIMManagerExt.getInstance().initStorage(identify, new TIMCallBack() {
                    @Override
                    public void onError(int code, String desc) {
                        Log.e(tag, "initStorage failed, code: " + code + "|descr: " + desc);
                        if(6208 == code)
                            login(callbackContext, identify, usersig);
                    }

                    @Override
                    public void onSuccess() {
                        Log.i(tag, "initStorage succ");
                    }
                });

                callbackContext.error("login failed. code: " + code + " errmsg: " + desc);
            }

            @Override
            public void onSuccess() {
                Log.d(tag, "login success");
                callbackContext.success("login success");
                PushUtil.getInstance();
                MessageEvent.getInstance();
                Txim.addObserver();
            }
        });
    }

    static void logout(final CallbackContext callbackContext) {
        TIMManager.getInstance().logout(new TIMCallBack() {
            @Override
            public void onError(int code, String desc) {

                //错误码code和错误描述desc，可用于定位请求失败原因
                //错误码code列表请参见错误码表
                Log.d(tag, "logout failed. code: " + code + " errmsg: " + desc);
            }

            @Override
            public void onSuccess() {
                //登出成功
            }
        });
    }

    static void setOfflinePush(boolean on) {
        TIMOfflinePushSettings settings = new TIMOfflinePushSettings();
        //开启离线推送
        settings.setEnabled(on);
        settings.setC2cMsgRemindSound(null);
        settings.setGroupMsgRemindSound(null);
        TIMManager.getInstance().setOfflinePushSettings(settings);
    }

    static void getOfflinePushStatus(final CallbackContext callbackContext) {
        TIMOfflinePushSettings settings = new TIMOfflinePushSettings();
        callbackContext.success(String.valueOf(settings.isEnabled()));
    }

    static void addFriendReq(String identifier, String remark, String addWording, CallbackContext callbackContext) {
        TIMAddFriendRequest req = new TIMAddFriendRequest(identifier);
        req.setRemark(remark);
        req.setAddWording(addWording);
        List<TIMAddFriendRequest> reqs = new List<TIMAddFriendRequest>();
        reqs.push(req)
        TIMFriendshipManagerExt.getInstance().addFriend(res, new TIMValueCallBack<List<TIMFriendResult>>() {
            @Override
            public void onError(int code, String desc){
                //错误码 code 和错误描述 desc，可用于定位请求失败原因
                //错误码 code 列表请参见错误码表
                // Log.e(tag, "addFriend failed: " + code + " desc");
                callbackContext.error(code);
            }

            @Override
            public void onSuccess(List<TIMFriendResult> result){
                // Log.e(tag, "addFriend succ");
                // for(TIMFriendResult res : result){
                //     Log.e(tag, "identifier: " + res.getIdentifer() + " status: " + res.getStatus());
                // }
                callbackContext.success('')
            }
        })
    }

    static void agreeAddFriend(String identifier, CallbackContext callbackContext) {
        TIMFriendAddResponse res = new TIMFriendAddResponse(identifier)
        res.setType(TIMFriendResponseType.AgreeAndAdd)
        TIMFriendshipManagerExt.getInstance().addFriendResponse(res,
                              , new TIMValueCallBack<List<TIMFriendResult>>() {
                @Override
                public void onError(int code, String desc){
                    //错误码 code 和错误描述 desc，可用于定位请求失败原因
                    //错误码 code 列表请参见错误码表
                    // Log.e(tag, "addFriend failed: " + code + " desc");
                    callbackContext.error(code);
                }

                @Override
                public void onSuccess(List<TIMFriendResult> result){
                    // Log.e(tag, "addFriend succ");
                    // for(TIMFriendResult res : result){
                    //     Log.e(tag, "identifier: " + res.getIdentifer() + " status: " + res.getStatus());
                    // }
                    callbackContext.success('')
                }
            }
        )
    }

    static void refuseAddFriend(String identifier, CallbackContext callbackContext) {
        TIMFriendAddResponse res = new TIMFriendAddResponse(identifier)
        res.setType(TIMFriendResponseType.Reject)
        TIMFriendshipManagerExt.getInstance().addFriendResponse(res,
                              , new TIMValueCallBack<List<TIMFriendResult>>() {
                @Override
                public void onError(int code, String desc){
                    //错误码 code 和错误描述 desc，可用于定位请求失败原因
                    //错误码 code 列表请参见错误码表
                    // Log.e(tag, "addFriend failed: " + code + " desc");
                    callbackContext.error(code);
                }

                @Override
                public void onSuccess(List<TIMFriendResult> result){
                    // Log.e(tag, "addFriend succ");
                    // for(TIMFriendResult res : result){
                    //     Log.e(tag, "identifier: " + res.getIdentifer() + " status: " + res.getStatus());
                    // }
                    callbackContext.success('')
                }
            }
        )
    }
    

    static void deleteFriend(String identifier, CallbackContext callbackContext) {
        DeleteFriendParam params = new DeleteFriendParam();
        params.setType(TIMDelFriendType.TIM_FRIEND_DEL_BOTH)
            .setUsers(Collections.singletonList(identifier));

        TIMFriendshipManagerExt.getInstance().deleteFriend(params,
                              , new TIMValueCallBack<List<TIMFriendResult>>() {
                @Override
                public void onError(int code, String desc){
                    //错误码 code 和错误描述 desc，可用于定位请求失败原因
                    //错误码 code 列表请参见错误码表
                    // Log.e(tag, "addFriend failed: " + code + " desc");
                    callbackContext.error(code);
                }

                @Override
                public void onSuccess(List<TIMFriendResult> result){
                    // Log.e(tag, "addFriend succ");
                    // for(TIMFriendResult res : result){
                    //     Log.e(tag, "identifier: " + res.getIdentifer() + " status: " + res.getStatus());
                    // }
                    callbackContext.success('')
                }
            }
        )
    }


    static void setFriendBlackList(String identifier, CallbackContext callbackContext) {
        // DeleteFriendParam params = new DeleteFriendParam();
        // params.setType(TIMDelFriendType.TIM_FRIEND_DEL_BOTH)
        //     .setUsers(Collections.singletonList("identifier"));

        TIMFriendshipManagerExt.getInstance().addBlackList(Collections.singletonList(identifier),
                              , new TIMValueCallBack<List<TIMFriendResult>>() {
                @Override
                public void onError(int code, String desc){
                    //错误码 code 和错误描述 desc，可用于定位请求失败原因
                    //错误码 code 列表请参见错误码表
                    // Log.e(tag, "addFriend failed: " + code + " desc");
                    callbackContext.error(code);
                }

                @Override
                public void onSuccess(List<TIMFriendResult> result){
                    // Log.e(tag, "addFriend succ");
                    // for(TIMFriendResult res : result){
                    //     Log.e(tag, "identifier: " + res.getIdentifer() + " status: " + res.getStatus());
                    // }
                    callbackContext.success('')
                }
            }
        )
    }

    static void getFriendList(CallbackContext callbackContext) {
        TIMFriendshipManagerExt.getInstance().getFriendList(new TIMValueCallBack<List<TIMUserProfile>>(){
            @Override
            public void onError(int code, String desc){
                //错误码 code 和错误描述 desc，可用于定位请求失败原因
                //错误码 code 列表请参见错误码表
                // Log.e(tag, "getFriendList failed: " + code + " desc");
                callbackContext.error(code)
            }

            @Override
            public void onSuccess(List<TIMUserProfile> result){
                for(TIMUserProfile res : result){
                    Log.e(tag, "identifier: " + res.getIdentifier() + " nickName: " + res.getNickName() 
                            + " remark: " + res.getRemark());
                }
            }
        });
    }

    static sendMessageToUser(JSONObject data, CallbackContext callbackContext) {
        TIMConversation conversation = null;
        String identifier = data.getString("identifier");
        String identifierType = data.getString("identifierType");
        if (identifierType.equals('group')) {
            conversation = TIMManager.getInstance().getConversation(
            TIMConversationType.Group,      //会话类型：群组
            identifier);
        } else {
            conversation = TIMManager.getInstance().getConversation(
            TIMConversationType.C2C,      //会话类型：群组
            identifier);
        }

        if (conversation == null) {
            callbackContext.error("conversation null");
            return;
        }
        
        //构造一条消息
        TIMMessage msg = new TIMMessage();
        if (data.has('text')) {
            //添加文本内容
            TIMTextElem elem = new TIMTextElem();
            elem.setText(data.getString('text'));
            //将elem添加到消息
            if(msg.addElement(elem) != 0) {
                Log.d(tag, "addElement failed");
                callbackContext.error("addElement failed");
               return;
            }
        }
        else if (data.has('customData')) {
            //添加文本内容
            TIMCustomElem elem ＝ new TIMCustomElem();
            elem.setData(data.getString('customData').getBytes());      //自定义 byte[]
            //将elem添加到消息
            if(msg.addElement(elem) != 0) {
                Log.d(tag, "addElement failed");
                callbackContext.error("addElement failed");
               return;
            }
        }
        else if (data.has('imagePath')) {
            //添加图片
            TIMImageElem elem = new TIMImageElem();
            elem.setPath(data.getString('imagePath'));

            //将elem添加到消息
            if(msg.addElement(elem) != 0) {
                Log.d(tag, "addElement failed");
                callbackContext.error("addElement failed");
               return;
            }
        }
        else if (data.has('audioPath')) {
            //添加语音
            TIMSoundElem elem = new TIMSoundElem();
            elem.setPath(data.getString('audioPath')); //填写语音文件路径
            elem.setDuration( Integer.parseInt( data.getString('length') ) );  //填写语音时长

            //将elem添加到消息
            if(msg.addElement(elem) != 0) {
                Log.d(tag, "addElement failed");
                callbackContext.error("addElement failed");
               return;
            }
        }

        //发送消息
        conversation.sendMessage(msg, new TIMValueCallBack<TIMMessage>() {//发送消息回调
            @Override
            public void onError(int code, String desc) {//发送消息失败
                //错误码 code 和错误描述 desc，可用于定位请求失败原因
                //错误码 code 含义请参见错误码表
                Log.d(tag, "send message failed. code: " + code + " errmsg: " + desc);
                callbackContext.error(code);
            }

            @Override
            public void onSuccess(TIMMessage msg) {//发送消息成功
                callbackContext.success();
            }
        });

}
