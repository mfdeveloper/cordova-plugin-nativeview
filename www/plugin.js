
var cordova = require('cordova');

var PLUGIN_NAME = 'NativeView';

var NativeView = {
  show: function(packageOrClass, className, success, error) {
    var params = className ? [packageOrClass, className] : [packageOrClass];
    cordova.exec(success, error, PLUGIN_NAME, 'show', params);
  }
};

module.exports = NativeView;
