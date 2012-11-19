/*
 * Evernote
 * core.js - Core definition and name space of the Evernote client side framework.
 * 
 * Created by Pavel Skaldin on 2/24/11
 * Copyright 2011 Evernote Corp. All rights reserved.
 */

/**
 * Base name-space
 */
var Evernote = {};

/**
 * Class-like inheritance.
 */
Evernote.inherit = function(childClass, parentClassOrObject,
    includeConstructorDefs) {
  if (typeof parentClassOrObject.constructor == 'function') {
    // Normal Inheritance
    childClass.prototype = new parentClassOrObject;
    childClass.prototype.constructor = childClass;
    childClass.parent = parentClassOrObject.prototype;
    // childClass.prototype.constructor.parent = parentClassOrObject;
  } else {
    // Pure Virtual Inheritance
    childClass.prototype = parentClassOrObject;
    childClass.prototype.constructor = childClass;
    childClass.parent = parentClassOrObject;
    // childClass.constructor.parent = parentClassOrObject;
  }
  if (includeConstructorDefs) {
    for ( var i in parentClassOrObject.prototype.constructor) {
      if (i != "parent"
          && i != "prototype"
          && i != "javaClass"
          && parentClassOrObject.constructor[i] != parentClassOrObject.prototype.constructor[i]) {
        childClass.prototype.constructor[i] = parentClassOrObject.prototype.constructor[i];
      }
    }
  }
  if (typeof childClass.prototype.handleInheritance == 'function') {
    childClass.prototype.handleInheritance.apply(childClass, [ childClass,
        parentClassOrObject, includeConstructorDefs ]);
  }
  // return childClass;
};

/**
 * Tests whether childClass inherits from parentClass in a class-like manner
 * (see Evernote.inherit())
 */
Evernote.inherits = function(childClass, parentClass) {
  var cur = childClass;
  while (cur && typeof cur.parent != 'undefined') {
    if (cur.parent.constructor == parentClass) {
      return true;
    } else {
      cur = cur.parent.constructor;
    }
  }
  return false;
  // return (typeof childClass.parent != 'undefined' &&
  // childClass.parent.constructor == parentClass);
};

Evernote.mixin = function(classOrObject, mixin, map) {
  var target = (typeof classOrObject == 'function') ? classOrObject.prototype
      : classOrObject;
  for ( var i in mixin.prototype) {
    var from = to = i;
    if (typeof map == 'object' && map && typeof map[i] != 'undefined') {
      to = map[i];
    }
    target[to] = mixin.prototype[from];
  }
};

Evernote.extendObject = function(obj, extObj, deep) {
  if (typeof extObj == 'object' && extObj != null) {
    for ( var i in extObj) {
      if (deep && typeof extObj[i] == 'object' && extObj[i] != null
          && typeof obj[i] == 'object' && obj[i] != null) {
        Evernote.extendObject(obj[i], extObj[i], deep);
      } else {
        obj[i] = extObj[i];
      }
    }
  }
};

/*
 * Evernote.Logger
 * Evernote
 * 
 * Created by Pavel Skaldin on 8/4/09
 * Copyright 2010 Evernote Corp. All rights reserved.
 */
/**
 * Generic Evernote.Logger. Uses various specific implementations. See
 * Evernote.LoggerImpl for details on implementing specific implementations. Use
 * Evernote.LoggerImplFactory to get specific implementations...
 * 
 * @param level
 * @param logImplementor
 * @return
 */
Evernote.Logger = function Logger(scope, level, logImplementor) {
  this.__defineGetter__("level", this.getLevel);
  this.__defineSetter__("level", this.setLevel);
  this.__defineGetter__("scope", this.getScope);
  this.__defineSetter__("scope", this.setScope);
  this.__defineGetter__("scopeName", this.getScopeName);
  this.__defineGetter__("scopeNameAsPrefix", this.getScopeNameAsPrefix);
  this.__defineGetter__("useTimestamp", this.isUseTimestamp);
  this.__defineSetter__("useTimestamp", this.setUseTimestamp);
  this.__defineGetter__("usePrefix", this.isUsePrefix);
  this.__defineSetter__("usePrefix", this.setUsePrefix);
  this.__defineGetter__("enabled", this.isEnabled);
  this.__defineSetter__("enabled", this.setEnabled);
  this.scope = scope || arguments.callee.caller;
  this.level = level;
  if (typeof logImplementor != 'undefined'
      && logImplementor instanceof Evernote.LoggerImpl) {
    this.impl = logImplementor;
  } else {
    var _impl = Evernote.LoggerImplFactory.getImplementationFor(navigator);
    if (_impl instanceof Array) {
      this.impl = new Evernote.LoggerChainImpl(this, _impl);
    } else {
      this.impl = new _impl(this);
    }
  }
};

// Evernote.Logger levels.
Evernote.Logger.LOG_LEVEL_DEBUG = 0;
Evernote.Logger.LOG_LEVEL_INFO = 1;
Evernote.Logger.LOG_LEVEL_WARN = 2;
Evernote.Logger.LOG_LEVEL_ERROR = 3;
Evernote.Logger.LOG_LEVEL_EXCEPTION = 4;
Evernote.Logger.LOG_LEVEL_OFF = 5;
Evernote.Logger.GLOBAL_LEVEL = Evernote.Logger.LOG_LEVEL_ERROR;

Evernote.Logger.DEBUG_PREFIX = "[DEBUG] ";
Evernote.Logger.INFO_PREFIX = "[INFO] ";
Evernote.Logger.WARN_PREFIX = "[WARN] ";
Evernote.Logger.ERROR_PREFIX = "[ERROR] ";
Evernote.Logger.EXCEPTION_PREFIX = "[EXCEPTION] ";

Evernote.Logger._instances = {};

Evernote.Logger.getInstance = function(scope) {
  scope = scope || arguments.callee.caller;
  var scopeName = (typeof scope == 'function') ? scope.name
      : scope.constructor.name;
  if (typeof this._instances[scopeName] == 'undefined') {
    this._instances[scopeName] = new Evernote.Logger(scope);
  }
  return this._instances[scopeName];
};
Evernote.Logger.setInstance = function(logger) {
  this._instance = logger;
};
Evernote.Logger.destroyInstance = function(scope) {
  scope = scope || arguments.callee.caller;
  var scopeName = (typeof scope == 'function') ? scope.name
      : scope.constructor.name;
  delete this._instances[scopeName];
  // Evernote.Logger._instance = null;
};
Evernote.Logger.setGlobalLevel = function(level) {
  var l = parseInt(level);
  if (isNaN(l)) {
    return;
  }
  Evernote.Logger.GLOBAL_LEVEL = l;
  if (this._instances) {
    for ( var i in this._instances) {
      this._instances[i].setLevel(l);
    }
  }
};
Evernote.Logger.setLevel = function(level) {
  if (this._instances) {
    for ( var i in this._instances) {
      this._instances[i].setLevel(level);
    }
  }
};
Evernote.Logger.enableImplementor = function(clazz) {
  if (this._instances) {
    for ( var i in this._instances) {
      this._instances[i].enableImplementor(clazz);
    }
  }
  if (clazz) {
    clazz.protoEnabled = true;
  }
};
Evernote.Logger.disableImplementor = function(clazz) {
  if (this._instances) {
    for ( var i in this._instances) {
      this._instances[i].disableImplementor(clazz);
    }
  }
  if (clazz) {
    clazz.protoEnabled = false;
  }
};

Evernote.Logger.prototype._level = 0;
Evernote.Logger.prototype._scope = null;
Evernote.Logger.prototype._usePrefix = true;
Evernote.Logger.prototype._useTimestamp = true;
Evernote.Logger.prototype._enabled = true;

Evernote.Logger.prototype.getImplementor = function(clazz) {
  if (clazz) {
    return this.impl.answerImplementorInstance(clazz);
  } else {
    return this.impl;
  }
};
Evernote.Logger.prototype.enableImplementor = function(clazz) {
  if (clazz) {
    var i = this.getImplementor(clazz);
    if (i) {
      i.enabled = true;
    }
  } else {
    this.impl.enabled = true;
  }
};
Evernote.Logger.prototype.disableImplementor = function(clazz) {
  if (clazz) {
    var i = this.getImplementor(clazz);
    if (i) {
      i.enabled = false;
    }
  } else {
    this.impl.enabled = false;
  }
};

Evernote.Logger.prototype.setLevel = function(level) {
  this._level = parseInt(level);
  if (isNaN(this._level)) {
    this._level = Evernote.Logger.GLOBAL_LEVEL;
  }
};

Evernote.Logger.prototype.getLevel = function() {
  return this._level;
};

Evernote.Logger.prototype.setScope = function(fnOrObj) {
  if (typeof fnOrObj == 'function') {
    this._scope = fnOrObj;
  } else if (typeof fnOrObj == 'object' && fnOrObj != null) {
    this._scope = fnOrObj.constructor;
  }
};

Evernote.Logger.prototype.getScope = function() {
  return this._scope;
};

Evernote.Logger.prototype.getScopeName = function() {
  if (this.scope) {
    return this.scope.name;
  } else {
    return "";
  }
};

Evernote.Logger.prototype.getScopeNameAsPrefix = function() {
  var scopeName = this.scopeName;
  return (scopeName) ? "[" + scopeName + "] " : "";
};

Evernote.Logger.prototype._padNumber = function(num, len) {
  var padStr = "0";
  num = parseInt(num);
  if (isNaN(num)) {
    num = 0;
  }
  var isPositive = (num >= 0) ? true : false;
  var numStr = "" + Math.abs(num);
  while (numStr.length < len) {
    numStr = padStr + numStr;
  }
  if (!isPositive) {
    numStr = "-" + numStr;
  }
  return numStr;
};

Evernote.Logger.prototype.getPrefix = function(pfx) {
  var str = "";
  if (this.useTimestamp) {
    var d = new Date();
    var mo = this._padNumber((d.getMonth() + 1), 2);
    var dd = this._padNumber(d.getDate(), 2);
    var h = this._padNumber(d.getHours(), 2);
    var m = this._padNumber(d.getMinutes(), 2);
    var s = this._padNumber(d.getSeconds(), 2);
    var tz = this._padNumber((0 - (d.getTimezoneOffset() / 60) * 100), 4);
    str += mo + "/" + dd + "/" + d.getFullYear() + " " + h + ":" + m + ":" + s
        + "." + d.getMilliseconds() + " " + tz + " ";
  }
  if (this.usePrefix) {
    str += pfx;
  }
  str += this.scopeNameAsPrefix;
  return str;
};

Evernote.Logger.prototype.isUsePrefix = function() {
  return this._usePrefix;
};
Evernote.Logger.prototype.setUsePrefix = function(bool) {
  this._usePrefix = (bool) ? true : false;
};

Evernote.Logger.prototype.isUseTimestamp = function() {
  return this._useTimestamp;
};
Evernote.Logger.prototype.setUseTimestamp = function(bool) {
  this._useTimestamp = (bool) ? true : false;
};

Evernote.Logger.prototype.isEnabled = function() {
  return this._enabled;
};
Evernote.Logger.prototype.setEnabled = function(bool) {
  this._enabled = (bool) ? true : false;
};

Evernote.Logger.prototype.isDebugEnabled = function() {
  return (this.enabled && this.level <= Evernote.Logger.LOG_LEVEL_DEBUG);
};

// Dumps an objects properties and methods to the console.
Evernote.Logger.prototype.dump = function(obj) {
  if (this.enabled && this.impl.enabled) {
    this.impl.dir(obj);
  }
};

// Same as dump
Evernote.Logger.prototype.dir = function(obj) {
  if (this.enabled && this.impl.enabled) {
    this.impl.dir(obj);
  }
};

// Dumps a stracktrace to the console.
Evernote.Logger.prototype.trace = function() {
  if (this.enabled && this.impl.enabled) {
    this.impl.trace();
  }
};

// Prints a debug message to the console.
Evernote.Logger.prototype.debug = function(str) {
  if (this.enabled && this.impl.enabled
      && this.level <= Evernote.Logger.LOG_LEVEL_DEBUG) {
    this.impl.debug(this.getPrefix(this.constructor.DEBUG_PREFIX) + str);
  }
};

// Prints an info message to the console.
Evernote.Logger.prototype.info = function(str) {
  if (this.enabled && this.impl.enabled
      && this.level <= Evernote.Logger.LOG_LEVEL_INFO) {
    this.impl.info(this.getPrefix(this.constructor.INFO_PREFIX) + str);
  }
};

// Prints a warning message to the console.
Evernote.Logger.prototype.warn = function(str) {
  if (this.enabled && this.impl.enabled
      && this.level <= Evernote.Logger.LOG_LEVEL_WARN) {
    this.impl.warn(this.getPrefix(this.constructor.WARN_PREFIX) + str);
  }
};

// Prints an error message to the console.
Evernote.Logger.prototype.error = function(str) {
  if (this.enabled && this.impl.enabled
      && this.level <= Evernote.Logger.LOG_LEVEL_ERROR) {
    this.impl.error(this.getPrefix(this.constructor.ERROR_PREFIX) + str);
  }
};

Evernote.Logger.prototype.exception = function(str) {
  if (this.enabled && this.impl.enabled
      && this.level <= Evernote.Logger.LOG_LEVEL_EXCEPTION) {
    this.impl
        .exception(this.getPrefix(this.constructor.EXCEPTION_PREFIX) + str);
  }
};

Evernote.Logger.prototype.alert = function(str) {
  if (this.enabled && this.impl.enabled) {
    this.impl.alert(str);
  }
};

Evernote.Logger.prototype.clear = function() {
  this.impl.clear();
};

/**
 * Abstract for variuos logger implementations
 * 
 * @author pasha
 */
Evernote.LoggerImpl = function LoggerImpl(logger) {
  this.__defineGetter__("logger", this.getLogger);
  this.__defineSetter__("logger", this.setLogger);
  this.__defineGetter__("enabled", this.isEnabled);
  this.__defineSetter__("enabled", this.setEnabled);
  this.__defineGetter__("protoEnabled", this.isProtoEnabled);
  this.__defineSetter__("protoEnabled", this.setProtoEnabled);
  this.initialize(logger);
};
Evernote.LoggerImpl.ClassRegistry = new Array();
Evernote.LoggerImpl.isResponsibleFor = function(navigator) {
  return false;
};

Evernote.LoggerImpl.prototype.handleInheritance = function(child, parent) {
  Evernote.LoggerImpl.ClassRegistry.push(child);
};

Evernote.LoggerImpl.prototype._logger = null;
Evernote.LoggerImpl.prototype._enabled = false;

Evernote.LoggerImpl.prototype.initialize = function(logger) {
  this.logger = logger;
};
Evernote.LoggerImpl.prototype.answerImplementorInstance = function(clazz) {
  if (this.constructor == clazz) {
    return this;
  }
};
Evernote.LoggerImpl.prototype.isEnabled = function() {
  return this._enabled;
};
Evernote.LoggerImpl.prototype.setEnabled = function(bool) {
  this._enabled = (bool) ? true : false;
};
Evernote.LoggerImpl.prototype.isProtoEnabled = function() {
  return this.constructor.prototype._enabled;
};
Evernote.LoggerImpl.prototype.setProtoEnabled = function(bool) {
  this.constructor.prototype._enabled = (bool) ? true : false;
};
Evernote.LoggerImpl.prototype.getLogger = function() {
  return this._logger;
};
Evernote.LoggerImpl.prototype.setLogger = function(logger) {
  if (logger instanceof Evernote.Logger) {
    this._logger = logger;
  }
};
Evernote.LoggerImpl.prototype.dir = function(obj) {
};
Evernote.LoggerImpl.prototype.trace = function() {
};
Evernote.LoggerImpl.prototype.debug = function(str) {
};
Evernote.LoggerImpl.prototype.info = function(str) {
};
Evernote.LoggerImpl.prototype.warn = function(str) {
};
Evernote.LoggerImpl.prototype.error = function(str) {
};
Evernote.LoggerImpl.prototype.exception = function(str) {
};
Evernote.LoggerImpl.prototype.alert = function(str) {
};
Evernote.LoggerImpl.prototype.clear = function() {
};

/**
 * Simple Chain implementation
 * 
 * @param logger
 * @param impls
 */
Evernote.LoggerChainImpl = function LoggerChainImpl(logger, impls) {
  this.initialize(logger, impls);
};
Evernote.inherit(Evernote.LoggerChainImpl, Evernote.LoggerImpl, true);

Evernote.LoggerChainImpl.prototype._impls = null;
Evernote.LoggerChainImpl.prototype._enabled = true;

Evernote.LoggerChainImpl.prototype.initialize = function(logger, impls) {
  Evernote.LoggerChainImpl.parent.initialize.apply(this, [ logger ]);
  var _impls = [].concat(impls);
  this._impls = [];
  for ( var i = 0; i < _impls.length; i++) {
    var _i = _impls[i];
    this._impls.push(new _i(logger));
  }
};
Evernote.LoggerChainImpl.prototype.answerImplementorInstance = function(clazz) {
  for ( var i = 0; i < this._impls.length; i++) {
    var ii = this._impls[i].answerImplementorInstance(clazz);
    if (ii) {
      return ii;
    }
  }
};
Evernote.LoggerChainImpl.prototype.dir = function(obj) {
  for ( var i = 0; i < this._impls.length; i++) {
    if (this._impls[i].enabled) {
      this._impls[i].dir(obj);
    }
  }
};
Evernote.LoggerChainImpl.prototype.trace = function() {
  for ( var i = 0; i < this._impls.length; i++) {
    if (this._impls[i].enabled) {
      this._impls[i].trace(obj);
    }
  }
};
Evernote.LoggerChainImpl.prototype.debug = function(str) {
  for ( var i = 0; i < this._impls.length; i++) {
    if (this._impls[i].enabled) {
      this._impls[i].debug(str);
    }
  }
};
Evernote.LoggerChainImpl.prototype.info = function(str) {
  for ( var i = 0; i < this._impls.length; i++) {
    if (this._impls[i].enabled) {
      this._impls[i].info(str);
    }
  }
};
Evernote.LoggerChainImpl.prototype.warn = function(str) {
  for ( var i = 0; i < this._impls.length; i++) {
    if (this._impls[i].enabled) {
      this._impls[i].warn(str);
    }
  }
};
Evernote.LoggerChainImpl.prototype.error = function(str) {
  for ( var i = 0; i < this._impls.length; i++) {
    if (this._impls[i].enabled) {
      this._impls[i].error(str);
    }
  }
};
Evernote.LoggerChainImpl.prototype.exception = function(str) {
  for ( var i = 0; i < this._impls.length; i++) {
    if (this._impls[i].enabled) {
      this._impls[i].exception(str);
    }
  }
};
Evernote.LoggerChainImpl.prototype.alert = function(str) {
  for ( var i = 0; i < this._impls.length; i++) {
    if (this._impls[i].enabled) {
      this._impls[i].alert(str);
    }
  }
};
Evernote.LoggerChainImpl.prototype.clear = function() {
  for ( var i = 0; i < this._impls.length; i++) {
    if (this._impls[i].enabled) {
      this._impls[i].clear();
    }
  }
};

/**
 * Factory of Logger implementations
 * 
 * @author pasha
 */
Evernote.LoggerImplFactory = {
  getImplementationFor : function(navigator) {
    var reg = Evernote.LoggerImpl.ClassRegistry;
    var impls = [];
    for ( var i = 0; i < reg.length; i++) {
      if (typeof reg[i] == 'function'
          && typeof reg[i].isResponsibleFor == 'function'
          && reg[i].isResponsibleFor(navigator)) {
        impls.push(reg[i]);
      }
    }
    if (impls.length == 0) {
      return Evernote.LoggerImpl;
    } else if (impls.length == 1) {
      return impls[0];
    }
    return impls;
  }
};

/**
 * WebKit specific logger implementation to be used with WRT's logger
 * 
 * @author pasha
 */
Evernote.WebKitLoggerImpl = function WebKitLoggerImpl(logger) {
  this.initialize(logger);
};
Evernote.inherit(Evernote.WebKitLoggerImpl, Evernote.LoggerImpl, true);
Evernote.WebKitLoggerImpl.isResponsibleFor = function(navigator) {
  return navigator.userAgent.toLowerCase().indexOf("AppleWebKit/") > 0;
};
Evernote.WebKitLoggerImpl.prototype._enabled = true;

Evernote.WebKitLoggerImpl.prototype.dir = function(obj) {
  console.group(this.logger.scopeName);
  console.dir(obj);
  console.groupEnd();
};
Evernote.WebKitLoggerImpl.prototype.trace = function() {
  console.group(this.logger.scopeName);
  console.trace();
  console.groupEnd();
};
Evernote.WebKitLoggerImpl.prototype.debug = function(str) {
  console.debug(str);
};
Evernote.WebKitLoggerImpl.prototype.info = function(str) {
  console.info(str);
};
Evernote.WebKitLoggerImpl.prototype.warn = function(str) {
  console.warn(str);
};
Evernote.WebKitLoggerImpl.prototype.error = function(str) {
  console.error(str);
};
Evernote.WebKitLoggerImpl.prototype.exception = function(str) {
  console.error(str);
  this.trace();
};
Evernote.WebKitLoggerImpl.prototype.alert = function(str) {
  alert(str);
};


/*
 * Constants
 * Evernote
 * 
 * Created by Pavel Skaldin on 3/1/10
 * Copyright 2010 Evernote Corp. All rights reserved.
 */
Evernote.Constants = Evernote.Constants || {};

/**
 * Lists typeof of requests the extension makes. Lower codes (below 100) are
 * strictly for basic functionality of the extension. Higher codes are for
 * particular applications of the extension - such as content clipping,
 * simSearch etc. It is customary for higher codes to utilize odd numbers for
 * error codes and even numbers otherwise.
 */

Evernote.Constants.RequestType = {
  UNKNOWN : 0,
  // used to signal logout
  LOGOUT : 1,
  // used to signal login
  LOGIN : 2,
  // used to signal authentication error
  AUTH_ERROR : 3,
  // used to signal successful authentication
  AUTH_SUCCESS : 4,
  // used to signal when the client was updated with user-data
  DATA_UPDATED : 6,
  // used to signal that user has reached his quota
  QUOTA_REACHED : 7,
  // used to indicate that there was a problem allocating clipProcessor
  CLIP_PROCESSOR_INIT_ERROR : 11,
  // used to indicate that there was a problem allocating autosaveProcessor
  AUTOSAVE_PROCESSOR_INIT_ERROR : 13,
  // used to request failed payloads from clipProcessor
  GET_MANAGED_PAYLOAD : 14,
  // used to request a re-trial of a failed payload
  RETRY_MANAGED_PAYLOAD : 15,
  // used to request cancellation of a failed payload
  CANCEL_MANAGED_PAYLOAD : 16,
  // used to request reivisting of failed payload
  REVISIT_MANAGED_PAYLOAD : 17,
  // used to request viewing of processed payload's clip
  VIEW_MANAGED_PAYLOAD_DATA : 18,
  // used to request editing of processed payload's clip
  EDIT_MANAGED_PAYLOAD_DATA : 19,
  // used to signal when the client receives new data from the server
  SYNC_DATA : 20,
  // used to signal client's failure to process data during sync
  SYNC_DATA_FAILURE : 21,
  // used to signal upon removal of log files
  LOG_FILE_REMOVED : 30,
  // used to signal swapping of log file
  LOG_FILE_SWAPPED : 32,
  // indicates that a clip was made from a page
  PAGE_CLIP_SUCCESS : 100,
  // indicates that a clip failed to be created from a page
  PAGE_CLIP_FAILURE : 101,
  // indicates that a clip with content was made from a page
  PAGE_CLIP_CONTENT_SUCCESS : 102,
  // indicates that a clip with content failed to be created from a page
  PAGE_CLIP_CONTENT_FAILURE : 103,
  // indicates that a clip is too big in size
  PAGE_CLIP_CONTENT_TOO_BIG : 105,
  // indicates that clip was synchronized with the server
  CLIP_SUCCESS : 110,
  // indicates that clip failed to synchronize with the server
  CLIP_FAILURE : 111,
  // indicates that there was an HTTP transport error while syncing page clip
  // to the server
  CLIP_HTTP_FAILURE : 113,
  // indicates that clip was filed on the server
  CLIP_FILE_SUCCESS : 120,
  // indicates that clip failed to fil on the server
  CLIP_FILE_FAILURE : 121,
  // indicates that there was an HTTP transport error while filing a note on the
  // server
  CLIP_FILE_HTTP_FAILURE : 123,
  // used to signal listener to cancel a timer that's waiting on page clip
  CANCEL_PAGE_CLIP_TIMER : 200,
  CLEAR_AUTOSAVE : 210,
  AUTOSAVE : 212,
  // used to signal that options have been updated
  OPTIONS_UPDATED : 320,
  // used to signal that search-helper needs to be disabled
  SEARCH_HELPER_DISABLE : 340,
  // used to signal that a timeout waiting for the content script to be loaded
  // needs to be cancelled
  CONTENT_SCRIPT_LOAD_TIMEOUT_CANCEL : 400,
  // used to signal that content script loading timed out
  CONTENT_SCRIPT_LOAD_TIMEOUT : 401,
  // indicates that a clip was made from a page
  POPUP_PAGE_CLIP_SUCCESS : 1100,
  // indicates that a clip failed to be created from a page
  POPUP_PAGE_CLIP_FAILURE : 1101,
  // indicates that a clip with content was made from a page
  POPUP_PAGE_CLIP_CONTENT_SUCCESS : 1102,
  // indicates that a clip with content failed to be created from a page
  POPUP_PAGE_CLIP_CONTENT_FAILURE : 1103,
  // indicates that a clip is too big in size
  POPUP_PAGE_CLIP_CONTENT_TOO_BIG : 1105,
  // indicates that a clip was made from a page
  CONTEXT_PAGE_CLIP_SUCCESS : 2100,
  // indicates that a clip failed to be created from a page
  CONTEXT_PAGE_CLIP_FAILURE : 2101,
  // indicates that a clip with content was made from a page
  CONTEXT_PAGE_CLIP_CONTENT_SUCCESS : 2102,
  // indicates that a clip with content failed to be created from a page
  CONTEXT_PAGE_CLIP_CONTENT_FAILURE : 2103,
  // indicates that a clip is too big in size
  CONTEXT_PAGE_CLIP_CONTENT_TOO_BIG : 2105
};

Evernote.Constants.Limits = {
  EDAM_USER_USERNAME_LEN_MIN : 1,
  EDAM_USER_USERNAME_LEN_MAX : 64,
  EDAM_USER_USERNAME_REGEX : "^[a-z0-9]([a-z0-9_-]{0,62}[a-z0-9])?$",

  EDAM_USER_PASSWORD_LEN_MIN : 6,
  EDAM_USER_PASSWORD_LEN_MAX : 64,
  EDAM_USER_PASSWORD_REGEX : "^[A-Za-z0-9!#$%&'()*+,./:;<=>?@^_`{|}~\\[\\]\\\\-]{6,64}$",

  EDAM_NOTE_TITLE_LEN_MIN : 1,
  EDAM_NOTE_TITLE_LEN_MAX : 255,
  EDAM_NOTE_TITLE_REGEX : "^[^\\s\\r\\n\\t]([^\\n\\r\\t]{0,253}[^\\s\\r\\n\\t])?$",

  EDAM_TAG_NAME_LEN_MIN : 1,
  EDAM_TAG_NAME_LEN_MAX : 100,
  EDAM_TAG_NAME_REGEX : "^[^,\\s\\r\\n\\t]([^,\\n\\r\\t]{0,98}[^,\\s\\r\\n\\t])?$",

  EDAM_NOTE_TAGS_MIN : 0,
  EDAM_NOTE_TAGS_MAX : 100,

  SERVICE_DOMAIN_LEN_MIN : 1,
  SERVICE_DOMAIN_LEN_MAX : 256,

  CLIP_NOTE_CONTENT_LEN_MAX : 5242880,

  EDAM_USER_RECENT_MAILED_ADDRESSES_MAX : 10,
  EDAM_EMAIL_LEN_MIN : 6,
  EDAM_EMAIL_LEN_MAX : 255,
  EDAM_EMAIL_REGEX : "^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.([A-Za-z]{2,})$"
};

/**
 * Chrome specific logger implementation to be used with Chrome extensions
 * 
 * @author pasha
 */
Evernote.ChromeExtensionLoggerImpl = function ChromeExtensionLoggerImpl(logger) {
  this.initialize(logger);
};
Evernote.inherit(Evernote.ChromeExtensionLoggerImpl, Evernote.WebKitLoggerImpl,
    true);

Evernote.ChromeExtensionLoggerImpl.isResponsibleFor = function(navigator) {
  return (navigator.userAgent.toLowerCase().indexOf("chrome/") > 0);
};

Evernote.ChromeExtensionLoggerImpl.prototype._enabled = true;

(function() {
  var LOG = null;
  Evernote.SearchHelperContentScript = function SearchHelperContentScript() {
    LOG = Evernote.Logger.getInstance();
    var style = document.createElement("link");
    style.setAttribute("rel", "stylesheet");
    style.setAttribute("type", "text/css");
    style.setAttribute("href", "chrome-extension://"
        + chrome.i18n.getMessage("@@extension_id") + "/css/searchhelper.css");
    document.head.appendChild(style);
  };
  Evernote.SearchHelperContentScript._instance = null;
  Evernote.SearchHelperContentScript.getInstance = function() {
    if (!this._instance) {
      this._instance = new Evernote.SearchHelperContentScript();
    }
    return this._instance;
  };
  Evernote.SearchHelperContentScript.prototype.EVERNOTE_RESULT_STATS_ID = "evernoteResultStats";
  Evernote.SearchHelperContentScript.prototype.EVERNOTE_RESULT_STATS_MESSAGE_ID = "evernoteResultStatsMessage";
  Evernote.SearchHelperContentScript.prototype.EVERNOTE_RESULT_STATS_ERROR_MESSAGE_ID = "evernoteResultStatsErrorMessage";
  Evernote.SearchHelperContentScript.prototype.EVERNOTE_RESULT_STATS_FOOTER_ID = "evernoteResultStatsFooter";
  Evernote.SearchHelperContentScript.prototype.EVERNOTE_LINKED_URL_CONTAINER_CLASS = "evernoteLinkedUrl";
  Evernote.SearchHelperContentScript.prototype.LINKED_URL_PARENT_MARK = "evernoteMarkedLinkedUrl";

  Evernote.SearchHelperContentScript.prototype.getElement = function(el) {
    var id = el.getAttribute("id");
    if (id) {
      return this.getMessageBlock(id);
    }
    return null;
  };

  Evernote.SearchHelperContentScript.prototype.appendReplaceElement = function(
      element, parent) {
    LOG.debug("SearchHelperContentScript.appendReplaceElement");
    var old = this.getElement(element);
    if (old) {
      old.parentNode.replaceChild(element, old);
    } else {
      parent.appendChild(element);
    }
  };

  Evernote.SearchHelperContentScript.prototype.prependMessageBlock = function(
      element, message, footer, creatorFn) {
    LOG.debug("SearchHelperContentScript.prependMessageBlock");
    var el = this.findTargetElement(element);
    if (el) {
      var stats = this.getResultStats();
      if (!stats) {
        stats = this.createResultStats(message);
        el.parentNode.insertBefore(stats, el);
      }
      if (message) {
        this.appendReplaceElement(creatorFn.apply(this, [ message ]), stats);
      }
      if (footer) {
        this.appendReplaceElement(this.createMessageFooter(footer), stats);
      }
    }
    this.bindMessageElements();
  };

  Evernote.SearchHelperContentScript.prototype.appendMessageBlock = function(
      element, message, footer, creatorFn) {
    LOG.debug("SearchHelperContentScript.appendMessageBlock");
    var el = this.findTargetElement(element);
    if (el) {
      var stats = this.getResultStats();
      if (!stats) {
        stats = this.createResultStats(message);
        el.parentNode.appendChild(stats);
      }
      var stats = this.createResultStats();
      if (message) {
        this.appendReplaceElement(creatorFn.apply(this, [ message ]), stats);
      }
      if (footer) {
        this.appendReplaceElement(this.createMessageFooter(footer), stats);
      }
    }
    this.bindMessageElements();
  };

  Evernote.SearchHelperContentScript.prototype.prependMessage = function(
      element, message, footer) {
    LOG.debug("SearchHelperContentScript.prependMessage");
    this.prependMessageBlock(element, message, footer, this.createMessage);
  };

  Evernote.SearchHelperContentScript.prototype.appendMessage = function(
      element, message, footer) {
    LOG.debug("SearchHelperContentScript.appendMessage");
    this.appendMessageBlock(element, message, footer, this.createMessage);
  };

  Evernote.SearchHelperContentScript.prototype.prependErrorMessage = function(
      element, message, footer) {
    LOG.debug("SearchHelperContentScript.prependErrorMessage");
    this.prependMessageBlock(element, message, footer, this.createErrorMessage);
  };

  Evernote.SearchHelperContentScript.prototype.appendErrorMessage = function(
      element, message, footer) {
    LOG.debug("SearchHelperContentScript.appendErrorMessage");
    this.appendMessageBlock(element, message, footer, this.createErrorMessage);
  };

  Evernote.SearchHelperContentScript.prototype.createResultStats = function() {
    LOG.debug("SearchHelperContentScript.createResultStats");
    var el = document.createElement("DIV");
    el.setAttribute("id", this.EVERNOTE_RESULT_STATS_ID);
    return el;
  };

  Evernote.SearchHelperContentScript.prototype.removeResultStats = function() {
    LOG.debug("SearchHelperContentScript.removeResultStats");
    var el = this.getResultStats();
    if (el) {
      el.parentNode.removeChild(el);
    }
  };

  Evernote.SearchHelperContentScript.prototype.getResultStats = function() {
    return document.getElementById(this.EVERNOTE_RESULT_STATS_ID);
  };

  Evernote.SearchHelperContentScript.prototype.createMessageBlock = function(
      message, attrs) {
    LOG.debug("SearchHelperContentScript.createMessageBlock");
    var el = document.createElement("DIV");
    if (typeof attrs == 'object' && attrs != null) {
      for ( var attrName in attrs) {
        el.setAttribute(attrName, attrs[attrName]);
      }
    }
    if (message) {
      el.innerHTML = message;
    }
    return el;
  };

  Evernote.SearchHelperContentScript.prototype.removeMessageBlock = function(id) {
    LOG.debug("SearchHelperContentScript.removeMessageBlock");
    var el = this.getMessageBlock(id);
    if (el) {
      el.parentNode.removeChild(el);
    }
  };

  Evernote.SearchHelperContentScript.prototype.getMessageBlock = function(id) {
    LOG.debug("SearchHelperContentScript.getMessageBlock " + id);
    return document.getElementById(id);
  };

  Evernote.SearchHelperContentScript.prototype.createMessage = function(message) {
    LOG.debug("SearchHelperContentScript.createMessage");
    return this.createMessageBlock(message, {
      id : this.EVERNOTE_RESULT_STATS_MESSAGE_ID
    });
  };

  Evernote.SearchHelperContentScript.prototype.removeMessage = function() {
    LOG.debug("SearchHelperContentScript.removeMessage");
    this.removeMessageBlock(this.EVERNOTE_RESULT_STATS_MESSAGE_ID);
  };

  Evernote.SearchHelperContentScript.prototype.getMessage = function() {
    LOG.debug("SearchHelperContentScript.getMessage");
    return this.getMessageBlock(this.EVERNOTE_RESULT_STATS_MESSAGE_ID);
  };

  Evernote.SearchHelperContentScript.prototype.createErrorMessage = function(
      message) {
    LOG.debug("SearchHelperContentScript.createErrorMessage");
    return this.createMessageBlock(message, {
      id : this.EVERNOTE_RESULT_STATS_ERROR_MESSAGE_ID
    });
  };

  Evernote.SearchHelperContentScript.prototype.removeErrorMessage = function() {
    LOG.debug("SearchHelperContentScript.removeErrorMessage");
    this.removeMessageBlock(this.EVERNOTE_RESULT_STATS_ERROR_MESSAGE_ID);
  };

  Evernote.SearchHelperContentScript.prototype.getErrorMessage = function() {
    LOG.debug("SearchHelperContentScript.getErrorMessage");
    return this.getMessageBlock(this.EVERNOTE_RESULT_STATS_ERROR_MESSAGE_ID);
  };

  Evernote.SearchHelperContentScript.prototype.createMessageFooter = function(
      message) {
    LOG.debug("SearchHelperContentScript.createMessageFooter");
    return this.createMessageBlock(message, {
      id : this.EVERNOTE_RESULT_STATS_FOOTER_ID
    });
  };

  Evernote.SearchHelperContentScript.prototype.removeMessageFooter = function() {
    LOG.debug("SearchHelperContentScript.removeMessageFooter");
    this.removeMessageBlock(this.EVERNOTE_RESULT_STATS_FOOTER_ID);
  };

  Evernote.SearchHelperContentScript.prototype.getMessageFooter = function() {
    LOG.debug("SearchHelperContentScript.getMessageFooter");
    return this.getMessageBlock(this.EVERNOTE_RESULT_STATS_FOOTER_ID);
  };

  Evernote.SearchHelperContentScript.prototype.prependLinkedUrls = function(
      selector, linkedUrls) {
    LOG.debug("SearchHelperContentScript.prependLinkedUrls");
    this.markLinkedUrls(selector, linkedUrls, true);
  };

  Evernote.SearchHelperContentScript.prototype.appendLinkedUrls = function(
      selector, linkedUrls) {
    LOG.debug("SearchHelperContentScript.appendLinkedUrls");
    this.markLinkedUrls(selector, linkedUrls, false);
  };

  Evernote.SearchHelperContentScript.prototype.createLinkedUrlElement = function(
      msg) {
    LOG.debug("SearchHelperContentScript.createLinkedUrlElement");
    var e = document.createElement("div");
    e.className = this.EVERNOTE_LINKED_URL_CONTAINER_CLASS;
    if (msg) {
      e.innerHTML = msg;
    }
    return e;
  };

  Evernote.SearchHelperContentScript.prototype.markLinkedUrls = function(
      selector, linkedUrls, prepend) {
    LOG.debug("SearchHelperContentScript.markLinkedUrls");
    if (typeof linkedUrls == 'object' && linkedUrls != null) {
      LOG.dir(linkedUrls);
      var allLinks = document.getElementsByTagName("a");
      var thisDomain = document.location.href.replace(
          /^https?:\/\/([^\/]+).*$/, "$1");
      for ( var i = 0; i < allLinks.length; i++) {
        var urls = this.extractUrls(allLinks[i].href);
        LOG.debug("Extracted URLs: " + urls);
        for ( var u = 0; u < urls.length; u++) {
          var url = urls[u].replace(/^.*:\/\//, "");
          LOG.debug(">>>>> URL: " + url);
          var domain = url.replace(/^([^\/]+).*$/, "$1");
          if (domain == thisDomain) {
            LOG.debug("Ignoring URL because it's of the same origin: " + url);
            continue;
          }
          if (typeof linkedUrls.domains[domain] != 'undefined'
              || typeof linkedUrls.urls[url] != 'undefined') {
            var parent = this.findParentSimpleSelector(allLinks[i], selector);
            if (!parent || parent[this.LINKED_URL_PARENT_MARK]) {
              LOG.debug("Skipping URL because we cannot find parent "
                  + selector + ": " + url);
              continue;
            }
            parent[this.LINKED_URL_PARENT_MARK] = true;
            var msg = "";
            if (typeof linkedUrls.urls[url] != 'undefined') {
              msg += linkedUrls.urls[url];
            }
            if (typeof linkedUrls.domains[domain] != 'undefined') {
              msg += ((msg) ? " - " : "") + linkedUrls.domains[domain];
            }
            var msgElement = this.createLinkedUrlElement(msg);
            if (prepend && parent.children.length > 0) {
              LOG.debug("Inserting message before");
              parent.insertBefore(msgElement, parent.children[0]);
            } else {
              LOG.debug("Appending message after");
              parent.appendChild(msgElement);
            }
            break;
          }
        }
      }
    }
  };

  Evernote.SearchHelperContentScript.prototype.findParentSimpleSelector = function(
      e, sel) {
    LOG.debug("SearchHelperContentScript.findParentSimpleSelector: " + sel);
    var parent = e;
    while (parent && parent != document.body
        && !this.isSimpleSelectorElement(parent, sel)) {
      parent = parent.parentElement;
    }
    return (!parent || (parent == document.body && !this
        .isSimpleSelectorElement(parent, sel))) ? undefined : parent;
  };

  Evernote.SearchHelperContentScript.prototype.isSimpleSelectorElement = function(
      e, sel) {
    var selObj = (typeof sel == 'string') ? this.simpleSelectorObj(sel) : sel;
    if (selObj.tagName && selObj.tagName != e.nodeName) {
      return selObj.tagName == "*";
    }
    if (selObj.id && selObj.id != e.getAttribute("id")) {
      return false;
    }
    if (selObj.classList) {
      var classList = e.classList;
      for ( var c = 0; c < selObj.classList.length; c++) {
        if (!classList.contains(selObj.classList[c])) {
          return false;
        }
      }
    }
    return true;
  };

  Evernote.SearchHelperContentScript.prototype.simpleSelectorObj = function(
      selectorText) {
    LOG.debug("SearchHelperContentScript.simpleSelectorObj: " + selectorText);
    var obj = {
      tagName : null,
      id : null,
      classList : null
    };
    if (selectorText.charAt(0) == "#") {
      obj.id = selectorText.substring(1);
    }
    var tagName = selectorText.replace(/\..*$/, "");
    if (tagName) {
      obj.tagName = tagName.toUpperCase();
    }
    var classParts = selectorText.replace(/^[^\.]+/, "").split(".");
    if (classParts) {
      for ( var i = 0; i < classParts.length; i++) {
        if (classParts[i]) {
          if (!(obj.classList instanceof Array)) {
            obj.classList = [];
          }
          obj.classList.push(classParts[i]);
        }
      }
    }
    return obj;
  };

  Evernote.SearchHelperContentScript.prototype.findElements = function(selector) {
    LOG.debug("SearchHelperContentScript.findElements: " + selector);
    var ret = [];
    if (selector.charAt(0) == "#") {
      var e = document.getElementById(selector.substring(1));
      if (e) {
        ret.push(e);
      }
    } else if (selector.charAt(0) == ".") {
      var e = document.getElementsByClassName(selector.substring(1));
      if (e) {
        for ( var i = 0; i < e.length; i++) {
          ret.push(e);
        }
      }
    } else {
      var tagName = selector.split(".");
      var e = document.getElementsByTagName(tagName[0]);
      if (e.length >= 1 && tagName.length >= 1) {
        for ( var i = 0; i < e.length; i++) {
          var classList = e[i].classList;
          var found = true;
          for ( var c = 1; c < tagName.length; c++) {
            if (!classList.contains(tagName[c])) {
              found = false;
              break;
            }
          }
          if (found) {
            ret.push(e[i]);
          }
        }
      } else if (e) {
        ret.concat(e);
      }
    }
    return ret;
  };

  Evernote.SearchHelperContentScript.prototype.extractUrls = function(u) {
    LOG.debug("SearchHelperContentScript.extractUrls: " + u);
    var urlParts = [];
    var urls = [];
    var str = u;
    while (str && str.indexOf("?") > 0) {
      var parts = str.split(/\?+/, 2);
      urlParts.push(str);
      str = (typeof parts[1] == 'string') ? unescape(parts[1]) : null;
    }
    if (str && str.match(/^https?:\/\//)) {
      urlParts.push(str);
    }
    for ( var i = 0; i < urlParts.length; i++) {
      if (!urlParts[i].match(/^https?:\/\//) && urlParts[i].indexOf("&") > 0) {
        var parts = urlParts[i].split("&");
        for ( var p = 0; p < parts.length; p++) {
          var v = parts[p].split("=")[1];
          if (typeof v == 'string' && v.match("^https?:\/\/")) {
            urls.push(v);
          }
        }
      } else {
        urls.push(urlParts[i]);
      }
    }
    return urls;
  };

  Evernote.SearchHelperContentScript.prototype.extractDomains = function(u) {
    LOG.debug("SearchHelperContentScript.extractDomains: " + u);
    var urls = extractUrls(u);
    var domains = [];
    for ( var i = 0; i < urls.length; i++) {
      var d = urls[i].replace(/^https?:\/\/([^\/]+).*$/, "$1");
      if (d && domains.indexOf(d) < 0) {
        domains.push(d);
      }
    }
    return domains;
  };

  Evernote.SearchHelperContentScript.prototype.findTargetElement = function(
      element) {
    LOG.debug("SearchHelperContentScript.findTargetElement");
    if (typeof element == 'string') {
      var x = element.charAt(0);
      if (x == "#") {
        return document.getElementById(element.substring(1));
      } else if (x == ".") {
        return document.getElementsByClassName(element.substring(1))[0];
      }
    } else if (element instanceof Element) {
      return element;
    }
    return null;
  };

  Evernote.SearchHelperContentScript.prototype.disableSearchHelper = function() {
    LOG.debug("SearchHelperContentScript.disableSearchHelper");
    var o = {
      code : Evernote.Constants.RequestType.SEARCH_HELPER_DISABLE
    };
    chrome.extension.sendRequest(o);
  };

  Evernote.SearchHelperContentScript.prototype.findChildren = function(anchor,
      fn, recursive) {
    LOG.debug("SearchHelperContentScript.findChildren");
    var children = new Array();
    if (typeof anchor == 'object' && anchor != null
        && typeof anchor["nodeType"] == 'number' && anchor.nodeType == 1) {
      var childNodes = anchor.childNodes;
      for ( var i = 0; i < childNodes.length; i++) {
        if (typeof fn == 'function' && fn(childNodes[i])) {
          children.push(childNodes[i]);
        } else if (typeof fn != 'function') {
          children.push(childNodes[i]);
        }
        if (recursive && childNodes[i].childElementCount > 0) {
          var otherChildren = arguments.callee(childNodes[i], fn);
          if (otherChildren && otherChildren.length > 0) {
            children = children.concat(otherChildren);
          }
        }
      }
    }
    return children;
  };

  Evernote.SearchHelperContentScript.prototype.bindMessageElements = function() {
    LOG.debug("SearchHelperContentScript.bindMessageElements");
    var nodes = this.findChildren(this.getResultStats(), function(el) {
      try {
        for ( var i = 0; i < el.attributes.length; i++) {
          if (el.attributes[i].name.toLowerCase().indexOf("en-bind") == 0) {
            return true;
          }
        }
      } catch (e) {
      }
      return false;
    }, true);
    if (nodes && nodes.length > 0) {
      for ( var i = 0; i < nodes.length; i++) {
        var node = nodes[i];
        for ( var a = 0; a < node.attributes.length; a++) {
          if (node.attributes[a].name.toLowerCase().indexOf("en-bind") == 0) {
            var eventName = node.attributes[a].name.split("-", 3)[2];
            var methName = node.attributes[a].value;
            if (eventName
                && methName
                && (typeof this[methName] == 'function' || typeof window[methName] == 'function')) {
              var t = (typeof this[methName] == 'function') ? this[methName]
                  : window[methName];
              node.removeEventListener(eventName, t, false);
              node.addEventListener(eventName, t, false);
            }
          }
        }
      }
    }
  };
})();

