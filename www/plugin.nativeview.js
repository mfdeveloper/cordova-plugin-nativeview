
var cordova = require('cordova');

var PLUGIN_NAME = 'NativeView';

function NativeView() {
  this.show = function (packageOrClass, className, extraParams, success, error) {
    return new Promise(function (resolve, reject) {

      var params = className ? [packageOrClass, className] : [packageOrClass];
      if (extraParams) {
        if (extraParams instanceof Function) {
          error = success;
          success = extraParams;
        } else {
          params.push(JSON.stringify(extraParams));
        }
      }

      cordova.exec(success || resolve, error || reject, PLUGIN_NAME, 'show', params);
    });
  };
  this.checkIfAppInstalled = function (uriName, success, error) {
    return new Promise(function(resolve, reject) {
       cordova.exec(success || resolve, error || reject, PLUGIN_NAME, "checkIfAppInstalled", [uriName]);
    });
  };
};

module.exports = new NativeView();
