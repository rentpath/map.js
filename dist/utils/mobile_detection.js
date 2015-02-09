'use strict';
define(['flight/lib/component'], function(defineComponent) {
  var mobileDetection;
  mobileDetection = function() {
    this.isAndroid = function() {
      return navigator.userAgent.match(/Android/i);
    };
    this.isBlackBerry = function() {
      return navigator.userAgent.match(/BlackBerry/i);
    };
    this.isIOS = function() {
      return navigator.userAgent.match(/iPhone|iPad|iPod/i);
    };
    this.isOpera = function() {
      return navigator.userAgent.match(/Opera Mini/i);
    };
    this.isWindows = function() {
      return navigator.userAgent.match(/IEMobile/i);
    };
    return this.isMobile = function() {
      return this.isAndroid() || this.isBlackBerry() || this.isIOS() || this.isOpera() || this.isWindows();
    };
  };
  return mobileDetection;
});
