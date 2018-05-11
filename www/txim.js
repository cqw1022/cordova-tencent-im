var exec = require('cordova/exec');

module.exports = {

    init: function (sdkAppId, accountType, messageCallback) {
        return new Promise((resolve,reject)=>{
            exec(function(){
                if (messageCallback) {
                    exec(messageCallback, messageCallback, "Txim", "registerNewMessageListerner", [])
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
            }, "Txim", "login", [{identifier: identifier, userSig: userSig, appidAt3rd: appidAt3rd}]);
        })
    },

    
    addFriendReq: function (identifier) {
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
            }, "Txim", "requestAddFriend", [{identifier: identifier.toString(), remark: "remark", addWording: "addWording"}]);
        })
    }
};