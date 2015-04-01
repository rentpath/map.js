'use strict';
define([], function() {
  var mobileDetection;
  return mobileDetection = function() {
    this.agent = 'Foo';
    this._isAndroid = function() {
      return this.agent.match(/Android/i);
    };
    this._isBlackBerry = function() {
      return this.agent.match(/BlackBerry/i);
    };
    this._isIOS = function() {
      return this.agent.match(/iPhone|iPad|iPod/i);
    };
    this._isOpera = function() {
      return this.agent.match(/Opera Mini/i);
    };
    this._isWindows = function() {
      return this.agent.match(/IEMobile/i);
    };
    return this.isMobile = function(agent) {
      var matches;
      if (agent == null) {
        agent = navigator.userAgent;
      }
      this.agent = agent;
      matches = this._isAndroid(agent) || this._isBlackBerry(agent) || this._isIOS(agent) || this._isOpera(agent) || this._isWindows(agent);
      return (matches !== null) && (matches.length > 0);
    };
  };
});
