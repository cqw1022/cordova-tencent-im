
var exec = require('cordova/exec');

var im = {
    login: function(json, successFn, failureFn) {
        exec(successFn, failureFn, 'IM', 'login', [json]);
    },
    setOfflinePush: function(json, successFn, failureFn) {
        exec(successFn, failureFn, 'IM', 'setOfflinePush', [json]);
    }
}

module.exports = im;