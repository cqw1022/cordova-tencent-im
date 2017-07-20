var exec = require('cordova/exec');

var im = {
    login: function(id, usersig, successFn, failureFn) {
        exec(successFn, failureFn, 'IM', 'login', [id, usersig]);
    },
    logout: function(successFn, failureFn) {
        exec(successFn, failureFn, 'IM', 'logout', []);
    },
    getOfflinePushStatus: function(successFn, failureFn) {
        exec(successFn, failureFn, 'IM', 'getOfflinePushStatus', []);
    },
    setOfflinePush: function(data, successFn, failureFn) {
        exec(successFn, failureFn, 'IM', 'setOfflinePush', [data]);
    },
    onForceOffline: function() {
        cordova.fireDocumentEvent('im.onForceOffline');
    },
    onNewMessages: function(data) {
        cordova.fireDocumentEvent('im.onNewMessages', data);
    }
};

module.exports = im;
