var cordova = require('cordova');
var NativeView = require('../plugin.nativeview');

var PLUGIN_NAME = 'NativeView';

function NativeViewAndroid() {

    NativeView.apply(this, arguments);

    this.getBuildVariant = function (config, success, error) {
        return new Promise(function (resolve, reject) {
            cordova.exec(success || resolve, error || reject, PLUGIN_NAME, 'show', [config]);
        });
    };
}

module.exports = new NativeViewAndroid();
