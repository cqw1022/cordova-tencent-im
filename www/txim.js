var exec = require('cordova/exec');
    
module.exports = {

    init: function (sdkAppId, accountType, messageCallback) {
        return new Promise((resolve,reject)=>{
            exec(function(){
                if (messageCallback) {
                    var cb = function(msgStr) {
                        if (typeof msgStr === "string" && msgStr.length > 0) {
                            messageCallback(JSON.parse(msgStr))
                        }
                    }
                    exec(cb, cb, "Txim", "registerNewMessageListerner", [])
                }
                resolve({
                    isSuccess: true
                })
            }, function(errorCode){
                resolve({
                    isSuccess: false,
                    errorCode: errorCode
                })
            }, "Txim", "initSdk", [{sdkAppId: sdkAppId, accountType: accountType}]);
        })
    },

    login: function (identifier, userSig, appidAt3rd) {
        return new Promise((resolve,reject)=>{
            exec(function(){
                resolve({
                    isSuccess: true
                })
            }, function(errorInfo){
                resolve({
                    isSuccess: false,
                    errorCode: errorInfo
                })
            }, "Txim", "login", [{identifier: identifier, userSig: userSig, appidAt3rd: appidAt3rd}]);
        })
    },

    logout: function () {
        return new Promise((resolve,reject)=>{
            exec(function(){
                resolve({
                    isSuccess: true
                })
            }, function(errorCode){
                resolve({
                    isSuccess: false,
                    errorCode: errorCode
                })
            }, "Txim", "login", []);
        })
    },


    deleteFriend: function (identifier) {
        return new Promise((resolve,reject)=>{
            exec(function(){
                resolve({
                    isSuccess: true
                })
            }, function(errorCode){
                resolve({
                    isSuccess: false,
                    errorCode: errorCode
                })
            }, "Txim", "deleteFriend", [{identifier: identifier.toString()}]);
        })
    },

    addFriendReq: function (identifier, remark, addWording) {
        return new Promise((resolve,reject)=>{
            exec(function(){
                resolve({
                    isSuccess: true
                })
            }, function(errorInfo){
                if (typeof errorCode === 'string') {
                    resolve({
                        isSuccess: false,
                        errorMsg: errorInfo
                    })
                    return
                }
                resolve({
                    isSuccess: false,
                    errorCode: errorInfo
                })
            }, "Txim", "requestAddFriend", [{identifier: identifier.toString(), remark: addWording, addWording: addWording}]);
        })
    },


    agreeAddFriend: function (identifier) {
        return new Promise((resolve,reject)=>{
            exec(function(){
                resolve({
                    isSuccess: true
                })
            }, function(errorCode){
                resolve({
                    isSuccess: false,
                    errorCode: errorCode
                })
            }, "Txim", "agreeAddFriend", [{identifier: identifier.toString()}]);
        })
    },
    
    refuseAddFriend: function (identifier) {
        return new Promise((resolve,reject)=>{
            exec(function(){
                resolve({
                    isSuccess: true
                })
            }, function(errorCode){
                resolve({
                    isSuccess: false,
                    errorCode: errorCode
                })
            }, "Txim", "refuseAddFriend", [{identifier: identifier.toString()}]);
        })
    },

    setFriendBlackList: function (identifier) {
        return new Promise((resolve,reject)=>{
            exec(function(){
                resolve({
                    isSuccess: true
                })
            }, function(errorCode){
                resolve({
                    isSuccess: false,
                    errorCode: errorCode
                })
            }, "Txim", "setFriendBlackList", [{identifier: identifier.toString()}]);
        })
    },
    
    getFriendList: function (identifier) {
        return new Promise((resolve,reject)=>{
            exec(function(list){
                resolve({
                    isSuccess: true,
                    friends: JSON.parse(list)
                })
            }, function(errorCode){
                resolve({
                    isSuccess: false,
                    errorCode: errorCode
                })
            }, "Txim", "getFriendList", []);
        })
    },

    sendTextMessage: function (identifier, text) {
        return new Promise((resolve,reject)=>{
            exec(function(){
                resolve({
                    isSuccess: true
                })
            }, function(errorCode){
                resolve({
                    isSuccess: false,
                    errorCode: errorCode
                })
            }, "Txim", "sendMessageToUser", [{text: text}]);
        })
    },


    sendText: function (identifier, text, isGroup) {
        return new Promise((resolve,reject)=>{
            var msg = {text: text, identifier: identifier.toString()}
            if (isGroup) {
                msg.identifierType = 'group'
            } else {
                msg.identifierType = 'user'
            }
            exec(function(){
                resolve({
                    isSuccess: true
                })
            }, function(errorCode){
                resolve({
                    isSuccess: false,
                    errorCode: errorCode
                })
            }, "Txim", "sendMessageToUser", [msg]);
        })
    },


    sendFace: function (identifier, faceId, isGroup) {
                return new Promise((resolve,reject)=>{
                        var msg = {faceId: faceId.toString(), identifier: identifier.toString()}
                        if (isGroup) {
                        msg.identifierType = 'group'
                        } else {
                        msg.identifierType = 'user'
                        }
                        exec(function(){
                            resolve({
                                    isSuccess: true
                                    })
                            }, function(errorCode){
                            resolve({
                                    isSuccess: false,
                                    errorCode: errorCode
                                    })
                            }, "Txim", "sendMessageToUser", [msg]);
                        })
    },

        sendCustomData: function (identifier, customData, isGroup) {
        return new Promise((resolve,reject)=>{
                            var msg = {customData: customData, identifier: identifier.toString()}
                            if (isGroup) {
                            msg.identifierType = 'group'
                            } else {
                            msg.identifierType = 'user'
                            }
                            exec(function(){
                                resolve({
                                        isSuccess: true
                                        })
                                }, function(errorCode){
                                resolve({
                                        isSuccess: false,
                                        errorCode: errorCode
                                        })
                                }, "Txim", "sendMessageToUser", [msg]);
                            })
        },
        
        
        sendImage: function (identifier, imagePath, isGroup) {
        return new Promise((resolve,reject)=>{
                            var msg = {imagePath: imagePath, identifier: identifier.toString()}
                            if (isGroup) {
                            msg.identifierType = 'group'
                            } else {
                            msg.identifierType = 'user'
                            }
                            exec(function(){
                                resolve({
                                        isSuccess: true
                                        })
                                }, function(errorCode){
                                resolve({
                                        isSuccess: false,
                                        errorCode: errorCode
                                        })
                                }, "Txim", "sendMessageToUser", [msg]);
                            })
        },
        
        sendAudio: function (identifier, audioPath, length, isGroup) {
        return new Promise((resolve,reject)=>{
                            var msg = {audioPath: audioPath, length: length.toString(), identifier: identifier.toString()}
                            if (isGroup) {
                            msg.identifierType = 'group'
                            } else {
                            msg.identifierType = 'user'
                            }
                            exec(function(){
                                resolve({
                                        isSuccess: true
                                        })
                                }, function(errorCode){
                                resolve({
                                        isSuccess: false,
                                        errorCode: errorCode
                                        })
                                }, "Txim", "sendMessageToUser", [msg]);
                            })
        },

    setSelfProfile: function (profileInfo) {
        return new Promise((resolve,reject)=>{
            exec(function(list){
                resolve({
                    isSuccess: true
                })
            }, function(errorCode){
                resolve({
                    isSuccess: false,
                    errorCode: errorCode
                })
            }, "Txim", "setSelfProfile", [profileInfo]);
        })
    },

    
    getSelfProfile: function () {
    return new Promise((resolve,reject)=>{
                        exec(function(profileStr){
                            var profile = JSON.parse(profileStr)
                            profile.custom = JSON.parse(profile.custom)
                            resolve({
                                    isSuccess: true,
                                    profile: profile
                                    })
                            }, function(errorCode){
                            resolve({
                                    isSuccess: false,
                                    errorCode: errorCode
                                    })
                            }, "Txim", "getSelfProfile", []);
                        })
    }

};

    