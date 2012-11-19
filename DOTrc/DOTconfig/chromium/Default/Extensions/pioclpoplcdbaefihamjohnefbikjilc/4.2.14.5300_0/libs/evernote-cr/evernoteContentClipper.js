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


Evernote.Semaphore = function(signals) {
  this.initialize(signals);
};

Evernote.inherit(Evernote.Semaphore, Array);

Evernote.Semaphore.mutex = function() {
  var sema = new Evernote.Semaphore();
  sema.signal();
  return sema;
};

Evernote.Semaphore.prototype._excessSignals = 0;
Evernote.Semaphore.prototype.initialize = function(signals) {
  this._excessSignals = parseInt(signals);
  if (isNaN(this._excessSignals)) {
    this._excessSignals = 0;
  }
};
Evernote.Semaphore.prototype.signal = function() {
  if (this.length == 0) {
    this._excessSignals++;
  } else {
    this._processNext();
  }
};
Evernote.Semaphore.prototype.wait = function() {
  if (this._excessSignals > 0) {
    this._excessSignals--;
    this._processNext();
  }
};
Evernote.Semaphore.prototype.critical = function(fn) {
  var self = this;
  this.push(function() {
    try {
      fn();
    } catch (e) {
      self.signal();
      throw (e);
    }
  });
  this.wait();
};
Evernote.Semaphore.prototype._processNext = function() {
  if (this.length > 0) {
    var fn = this.shift();
    if (typeof fn == 'function') {
      fn();
    }
  }
};
Evernote.Semaphore.prototype.toString = function() {
  return this._excessSignals + ":[" + this.join(",") + "]";
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
  var logEnabled = false;
  Evernote.Clip = function Clip(aWindow, stylingStrategy, maxSize) {
    LOG = Evernote.Logger.getInstance();
    if (LOG.level == Evernote.Logger.LOG_LEVEL_DEBUG) {
      logEnabled = true;
    }
    this.__defineGetter__("fullPage", this.isFullPage);
    this.__defineGetter__("length", this.getLength);
    this.__defineGetter__("stylingStrategy", this.getStylingStrategy);
    this.__defineSetter__("stylingStrategy", this.setStylingStrategy);
    this.__defineGetter__("documentBase", this.getDocumentBase);
    this.__defineSetter__("documentBase", this.setDocumentBase);
    this.__defineGetter__("maxSize", this.getMaxSize);
    this.__defineSetter__("maxSize", this.setMaxSize);
    this.__defineGetter__("sizeExceeded", this.isSizeExceeded);
    this.__defineSetter__("sizeExceeded", this.setSizeExceeded);
    this.__defineGetter__("url", this.getUrl);
    this.__defineSetter__("url", this.setUrl);
    this.initialize(aWindow, stylingStrategy, maxSize);
  };

  Evernote.Clip.NOKEEP_NODE_ATTRIBUTES = {
    "style" : null,
    "class" : null,
    "id" : null
  };
  Evernote.Clip.NODE_NAME_TRANSLATIONS = {
    "HTML" : "DIV",
    "BODY" : "DIV",
    "FORM" : "DIV",
    "*" : "DIV"
  };
  Evernote.Clip.SUPPORTED_NODES = {
    "A" : null,
    "ABBR" : null,
    "ACRONYM" : null,
    "ADDRESS" : null,
    "AREA" : null,
    "B" : null,
    "BASE" : null,
    "BASEFONT" : null,
    "BDO" : null,
    "BIG" : null,
    "BLOCKQUOTE" : null,
    "BR" : null,
    "BUTTON" : null,
    "CAPTION" : null,
    "CENTER" : null,
    "CITE" : null,
    "CODE" : null,
    "COL" : null,
    "COLGROUP" : null,
    "DD" : null,
    "DEL" : null,
    "DFN" : null,
    "DIR" : null,
    "DIV" : null,
    "DL" : null,
    "DT" : null,
    "EM" : null,
    "FIELDSET" : null,
    "FONT" : null,
    "FORM" : null,
    "FRAME" : null,
    "FRAMESET" : null,
    "H1" : null,
    "H2" : null,
    "H3" : null,
    "H4" : null,
    "H5" : null,
    "H6" : null,
    "HEAD" : null,
    "HR" : null,
    "HTML" : null,
    "I" : null,
    "IFRAME" : null,
    "IMG" : null,
    "INPUT" : null,
    "INS" : null,
    "KBD" : null,
    "LABEL" : null,
    "LEGEND" : null,
    "LI" : null,
    "LINK" : null,
    "MAP" : null,
    "MENU" : null,
    "META" : null,
    "NOBR" : null,
    "NOFRAMES" : null,
    "NOSCRIPT" : null,
    "OBJECT" : null,
    "OL" : null,
    "OPTGROUP" : null,
    "OPTION" : null,
    "P" : null,
    "PARAM" : null,
    "PRE" : null,
    "Q" : null,
    "QUOTE" : null,
    "S" : null,
    "SAMP" : null,
    "SCRIPT" : null,
    "SELECT" : null,
    "SMALL" : null,
    "SPAN" : null,
    "STRIKE" : null,
    "STRONG" : null,
    "STYLE" : null,
    "SUB" : null,
    "SUP" : null,
    "TABLE" : null,
    "TBODY" : null,
    "TD" : null,
    "TEXTAREA" : null,
    "TFOOT" : null,
    "TH" : null,
    "THEAD" : null,
    "TITLE" : null,
    "TR" : null,
    "TT" : null,
    "U" : null,
    "UL" : null,
    "VAR" : null
  };
  Evernote.Clip.REJECT_NODES = {
    "SCRIPT" : null,
    "STYLE" : null,
    "FRAME" : null,
    "FRAMESET" : null,
    "IFRAME" : null,
    "INPUT" : null,
    "SELECT" : null,
    "OPTION" : null,
    "OPTGROUP" : null,
    "TEXTAREA" : null,
    "NOSCRIPT" : null,
    "OBJECT" : null,
    "PARAM" : null,
    "CANVAS" : null,
    "HEAD" : null,
    "EVERNOTEDIV" : null
  };
  Evernote.Clip.NOKEEP_ATTRS = {
    "id" : null,
    "class" : null,
    "style" : null
  };
  Evernote.Clip.NON_ANCESTOR_NODES = {
    "OL" : null,
    "UL" : null,
    "LI" : null
  };
  Evernote.Clip.SELF_CLOSING_NODES = {
    "IMG" : null,
    "INPUT" : null,
    "BR" : null
  };

  Evernote.Clip.HTMLEncode = function(str) {
    var result = "";
    for ( var i = 0; i < str.length; i++) {
      var charcode = str.charCodeAt(i);
      var aChar = str[i];
      if (charcode > 0x7f) {
        result += "&#" + charcode + ";";
      } else if (aChar == '>') {
        result += "&gt;";
      } else if (aChar == '<') {
        result += "&lt;";
      } else if (aChar == '&') {
        result += "&amp;";
      } else {
        result += str[i];
      }
    }
    return result;
  };

  // Evernote.Clip.prototype.fullPage = false;
  Evernote.Clip.prototype.title = null;
  Evernote.Clip.prototype.location = null;
  Evernote.Clip.prototype.window = null;
  Evernote.Clip.prototype.selectionFinder = null;
  Evernote.Clip.prototype.deep = true;
  Evernote.Clip.prototype._stylingStrategy = null;
  Evernote.Clip.prototype._documentBase = null;
  Evernote.Clip.prototype._maxSize = 0;
  Evernote.Clip.prototype._sizeExceeded = false;
  Evernote.Clip.prototype._includeFontFaceDescriptions = false;

  // Declares the content and source of a web clip
  Evernote.Clip.prototype.initialize = function(aWindow, stylingStrategy,
      maxSize) {
    this.title = aWindow.document.title;
    this.location = aWindow.location;
    this.window = aWindow;
    this.selectionFinder = new Evernote.SelectionFinder(aWindow.document);
    this.range = null;
    if (stylingStrategy) {
      this.stylingStrategy = stylingStrategy;
    }
    this.maxSize = maxSize;
  };

  /**
   * Override with a function to have that function called when the clip's
   * serialized string exceeds maxSize property.
   */
  Evernote.Clip.prototype.onsizeexceed = null;

  Evernote.Clip.prototype.isFullPage = function() {
    return !this.hasSelection();
  };

  Evernote.Clip.prototype.hasSelection = function() {
    if (this.selectionFinder.hasSelection()) {
      return true;
    } else {
      this.findSelection();
      return this.selectionFinder.hasSelection();
    }
  };
  Evernote.Clip.prototype.findSelection = function() {
    this.selectionFinder.find(this.deep);
  };
  Evernote.Clip.prototype.getSelection = function() {
    if (this.hasSelection()) {
      return this.selectionFinder.selection;
    }
    return null;
  };
  Evernote.Clip.prototype.getRange = function() {
    if (this.hasSelection()) {
      return this.selectionFinder.getRange();
    }
    return null;
  };
  Evernote.Clip.prototype.hasBody = function() {
    return (this.window && this.window.document && this.window.document.body && this.window.document.body.tagName
        .toLowerCase() == "body");
  };
  Evernote.Clip.prototype.hasContentToClip = function() {
    return (this.hasBody() || this.hasSelection());
  };
  Evernote.Clip.prototype.getDocumentBase = function() {
    if (this._documentBase == null) {
      var baseTags = this.window.document.getElementsByTagName("base");
      if (baseTags.length > 0) {
        for ( var i = 0; i < baseTags.length; i++) {
          this.setDocumentBase(baseTags[i].href);
          if (this._documentBase) {
            break;
          }
        }
      }
      if (!this._documentBase) {
        this._documentBase = this.location.origin
            + this.location.pathname.replace(/[^\/]+$/, "");
      }
    }
    return this._documentBase;
  };
  Evernote.Clip.prototype.setDocumentBase = function(url) {
    if (typeof url == 'string' && url.indexOf("http") == 0) {
      this._documentBase = url;
    } else {
      this._documentBase = null;
    }
  };
  Evernote.Clip.prototype.getMaxSize = function() {
    return this._maxSize;
  };
  Evernote.Clip.prototype.setMaxSize = function(num) {
    this._maxSize = parseInt(num);
    if (isNaN(this._maxSize) || num < 0) {
      this._maxSize = 0;
    }
  };
  Evernote.Clip.prototype.isSizeExceeded = function() {
    return this._sizeExceeded;
  };
  Evernote.Clip.prototype.setSizeExceeded = function(bool) {
    this._sizeExceeded = (bool) ? true : false;
  };
  Evernote.Clip.prototype.getUrl = function() {
    if (!this._url) {
      this._url = this.location.href;
    }
    return this._url;
  };
  Evernote.Clip.prototype.setUrl = function(url) {
    if (typeof url == 'string' || url == null) {
      this._url = url;
    }
  };

  /**
   * Captures all the content of the document
   */
  Evernote.Clip.prototype.clipBody = function() {
    if (!this.hasBody()) {
      if (logEnabled)
        LOG.debug("Document has no body...");
      return false;
    }
    if (this.stylingStrategy) {
      this.stylingStrategy.cleanUp();
    }
    var s = 0;
    var e = 0;
    if (logEnabled) {
      LOG.debug("Getting body text: " + this);
      s = new Date().getTime();
    }
    this.content = this
        .serializeDOMNode(this.window.document.body.parentElement
            || this.window.document.body);
    if (logEnabled) {
      e = new Date().getTime();
      LOG.debug("Clipped body in " + (e - s) + " milliseconds");
    }
    if (typeof this.content != 'string') {
      return false;
    }
    return true;
  };

  /**
   * Captures selection in the document
   */
  Evernote.Clip.prototype.clipSelection = function() {
    if (!this.hasSelection()) {
      if (logEnabled)
        LOG.debug("No selection to clip");
      return false;
    }
    if (this.stylingStrategy) {
      this.stylingStrategy.cleanUp();
    }
    var s = 0;
    var e = 0;
    this.range = this.getRange();
    if (this.range) {
      if (logEnabled)
        var s = new Date().getTime();
      var ancestor = (this.stylingStrategy
          && this.range.commonAncestorContainer.nodeType == Node.TEXT_NODE && this.range.commonAncestorContainer.parentNode) ? this.range.commonAncestorContainer.parentNode
          : this.range.commonAncestorContainer;
      while (typeof Evernote.Clip.NON_ANCESTOR_NODES[ancestor.nodeName] != 'undefined'
          && ancestor.parentNode) {
        if (ancestor.nodeName == "BODY") {
          break;
        }
        ancestor = ancestor.parentNode;
      }
      this.content = this.serializeDOMNode(ancestor);
      if (logEnabled) {
        var e = new Date().getTime();
      }
      this.range = null;
      if (logEnabled) {
        LOG.debug("Success...");
        LOG.debug("Clipped selection in " + (e - s) + " seconds");
      }
      return true;
    }
    this.range = null;
    if (logEnabled)
      LOG.debug("Failure");
    return false;
  };

  Evernote.Clip.prototype.serializeDOMNode = function(root) {
    var str = "";
    // oh yeah, if we ever decide to keep <style> crap, setting
    // _includeFontFaceDescriptions
    // will allow to include font face descriptions inside <style> tags =)
    if (this._includeFontFaceDescriptions && this.stylingStrategy) {
      var ffRules = this.stylingStrategy.getFontFaceRules();
      if (ffRules) {
        str += "<style>\n";
        for ( var ffrx = 0; ffrx < ffRules.length; ffrx++) {
          str += ffRules[ffrx].cssText + "\n";
        }
        str += "</style>\n";
      }
    }
    var node = root;
    while (node) {
      if (this.maxSize > 0 && str.length > this.maxSize) {
        LOG.debug("Length of serialized content exceeds " + this.maxSize);
        this.sizeExceeded = true;
        if (typeof this.onsizeexceed == 'function') {
          this.onsizeexceed();
        }
        break;
      }
      var inRange = (!this.range || this.range.intersectsNode(node)) ? true
          : false;
      if (inRange && node.nodeType == Node.TEXT_NODE) {
        if (this.range) {
          if (this.range.startContainer == node
              && this.range.startContainer == this.range.endContainer) {
            str += this.constructor.HTMLEncode(node.nodeValue.substring(
                this.range.startOffset, this.range.endOffset));
          } else if (this.range.startContainer == node) {
            str += this.constructor.HTMLEncode(node.nodeValue
                .substring(this.range.startOffset));
          } else if (this.range.endContainer == node) {
            str += this.constructor.HTMLEncode(node.nodeValue.substring(0,
                this.range.endOffset));
          } else if (this.range.commonAncestorContainer != node) {
            str += this.constructor.HTMLEncode(node.nodeValue);
          }
        } else {
          str += this.constructor.HTMLEncode(node.nodeValue);
        }
      } else if (inRange && node.nodeType == Node.ELEMENT_NODE
          && typeof Evernote.Clip.REJECT_NODES[node.nodeName] == 'undefined') {
        var s = window.getComputedStyle(node);
        var sDisplay = s.getPropertyValue("display");
        var sVisibility = s.getPropertyValue("visibility");
        var sPosition = s.getPropertyValue("position");
        if (sDisplay != "none"
            && !(sVisibility == "hidden" && sPosition == "absolute")) {
          var attrs = node.attributes;
          var attrStr = "";
          for ( var i = 0; i < attrs.length; i++) {
            if (typeof Evernote.Clip.NOKEEP_NODE_ATTRIBUTES[attrs[i].name] == 'undefined'
                && attrs[i].name.substring(0, 2).toLowerCase() != "on"
                && attrs[i].value
                && !(attrs[i].name == "href" && attrs[i].value.substring(0, 11) == "javascript:")) {
              var v = attrs[i].value.replace(/\"/g, "\\\"");
              if ((attrs[i].name == "src" || attrs[i].name == "href")
                  && v.toLowerCase().indexOf("http") != 0) {
                var docBase = this.getDocumentBase();
                if (v.indexOf("/") == 0) {
                  v = docBase.replace(/^(.*:\/\/[^\/]+).*$/, "$1") + v;
                } else {
                  v = (docBase.charAt(docBase.length - 1) == "/") ? docBase + v
                      : docBase + "/" + v;
                }
              }
              attrStr += " " + attrs[i].name + "=\"" + v + "\"";
            }
          }
          if (this.stylingStrategy) {
            var nodeStyle = this.stylingStrategy.styleForNode(node,
                (node == root));
            if (nodeStyle instanceof Evernote.ClipStyle && nodeStyle.length > 0) {
              attrStr += " style=\""
                  + nodeStyle.toString().replace(/\"/g, "\\\"") + "\"";
            } else if (typeof nodeStyle == 'string') {
              attrStr += " style=\"" + nodeStyle.replace(/\"/g, "\\\"") + "\"";
            }
          }
          var nodeName = Evernote.Clip.NODE_NAME_TRANSLATIONS[node.nodeName]
              || node.nodeName;
          nodeName = (typeof Evernote.Clip.SUPPORTED_NODES[nodeName] != 'undefined') ? nodeName
              : Evernote.Clip.NODE_NAME_TRANSLATIONS["*"];
          str += "<" + nodeName + attrStr;
          if (sVisibility != "hidden" && node.hasChildNodes()) {
            str += ">";
            node = node.childNodes[0];
            continue;
          } else if (typeof Evernote.Clip.SELF_CLOSING_NODES[nodeName] == 'undefined') {
            // The standards are great when no one follows them...
            // in the case of a BUTTON tag, make sure we fucking close it since
            // it's not a self-closing tag
            // and having a self-closing button will often result in the
            // siblings becoming its children
            // e.g. <button/><div>...</div> would become
            // <button><div>...</div></button>
            str += ">" + "</" + nodeName + ">";
          } else {
            str += "/>";
          }
        }
      }
      if (node.nextSibling) {
        node = node.nextSibling;
      } else if (node != root) {
        while (node.parentNode) {
          node = node.parentNode;
          var nodeName = Evernote.Clip.NODE_NAME_TRANSLATIONS[node.nodeName]
              || node.nodeName;
          nodeName = (typeof Evernote.Clip.SUPPORTED_NODES[nodeName] != 'undefined') ? nodeName
              : Evernote.Clip.NODE_NAME_TRANSLATIONS["*"];
          str += "</" + nodeName + ">";
          if (node == root) {
            break;
          } else if (node.nextSibling) {
            node = node.nextSibling;
            break;
          }
        }
        if (node == root) {
          break;
        }
      } else {
        break;
      }
    }
    return str;
  };

  Evernote.Clip.prototype.setStylingStrategy = function(strategy) {
    if (typeof strategy == 'function'
        && Evernote.inherits(strategy, Evernote.ClipStylingStrategy)) {
      this._stylingStrategy = new strategy(this.window);
    } else if (strategy instanceof Evernote.ClipStylingStrategy) {
      this._stylingStrategy = strategy;
    } else if (strategy == null) {
      this._stylingStrategy = null;
    }
  };
  Evernote.Clip.prototype.getStylingStrategy = function() {
    return this._stylingStrategy;
  };

  Evernote.Clip.prototype.toString = function() {
    return "Evernote.Clip[" + this.location + "] " + this.title;
  };

  // return POSTable length of this Evernote.Clip
  Evernote.Clip.prototype.getLength = function() {
    var total = 0;
    var o = this.toDataObject();
    for ( var i in o) {
      total += ("" + o[i]).length + i.length + 2;
    }
    total -= 1;
    return total;
  };

  Evernote.Clip.prototype.toDataObject = function() {
    return {
      "content" : this.content,
      "title" : this.title,
      "url" : this.url,
      "fullPage" : this.fullPage,
      "sizeExceeded" : this.sizeExceeded
    };
  };

  Evernote.Clip.prototype.toLOG = function() {
    return {
      title : this.title,
      url : this.url,
      fullPage : this.fullPage,
      sizeExceeded : this.sizeExceeded,
      contentLength : this.content.length
    };
  };
})();

/** ************** Evernote.ClipStyle *************** */
/**
 * Evernote.ClipStyle is a container for CSS styles. It is able to add and
 * remove CSSStyleRules (and parse CSSRuleList's for rules), as well as
 * CSSStyleDeclaration's and instances of itself.
 * 
 * Evernote.ClipStyle provides a mechanism to serialize itself via toString(),
 * and reports its length via length property. It also provides a method to
 * clone itself and expects to be manipulated via addStyle and removeStyle.
 */
Evernote.ClipStyle = function ClipStyle(css, filter) {
  this.__defineGetter__("styleFilter", this.getFilter);
  this.__defineSetter__("styleFilter", this.setFilter);
  this.initialize(css, filter);
};
Evernote.ClipStyle.stylePrefix = function(style) {
  if (typeof style == 'string') {
    var i = 0;
    if ((i = style.indexOf("-")) > 0) {
      return style.substring(0, i);
    }
  }
  return style;
};
Evernote.ClipStyle.findFontFaceRules = function(doc) {
  var d = doc || document;
  var sheets = d.styleSheets;
  var fontFaceRules = [];
  for ( var i = 0; i < sheets.length; i++) {
    var sheet = sheets[i];
    if (sheet.cssRules) {
      for ( var r = 0; r < sheet.cssRules.length; r++) {
        var rule = sheet.cssRules[r];
        if (rule instanceof CSSFontFaceRule) {
          fontFaceRules.push(rule);
        }
      }
    }
  }
  return fontFaceRules;
};
Evernote.ClipStyle.PERIMETERS = [ "top", "right", "bottom", "left" ];
Evernote.ClipStyle.PERIMETER_PROPS = {
  "margin" : null,
  "padding" : null
};
Evernote.ClipStyle.PERIMETER_EXTRA_PROPS = {
  "border" : [ "width", "style", "color" ],
  "border-top" : [ "width", "style", "color" ],
  "border-right" : [ "width", "style", "color" ],
  "border-bottom" : [ "width", "style", "color" ],
  "border-left" : [ "width", "style", "color" ],
  "outline" : [ "width", "style", "color" ]
};
Evernote.ClipStyle.prototype.length = 0;
Evernote.ClipStyle.prototype._filter = null;
Evernote.ClipStyle.prototype.initialize = function(css, filter) {
  this.styleFilter = filter;
  if (css instanceof CSSRuleList || css instanceof Array) {
    if (css.length > 0) {
      for ( var i = 0; i < css.length; i++) {
        this.addStyle(css[i].style);
      }
    }
  } else if (css instanceof CSSStyleRule) {
    this.addStyle(css.style);
  } else if (css instanceof CSSStyleDeclaration) {
    this.addStyle(css);
  } else if (typeof css == 'object' && css != null) {
    this.addStyle(css);
  }
};
Evernote.ClipStyle.prototype._addPerimeterStyle = function(prop, val) {
  var valParts = val.replace(/\s+/, " ").split(" ");
  if (valParts.length == 1) {
    valParts = valParts.concat(valParts, valParts, valParts);
  } else if (valParts.length == 2) {
    valParts = valParts.concat(valParts[0], valParts[1]);
  } else if (valParts.length == 3) {
    valParts = valParts.concat(valParts[1]);
  } else if (valParts.length == 0) {
    valParts = [ "auto", "auto", "auto", "auto" ];
  }
  for ( var i = 0; i < Evernote.ClipStyle.PERIMETERS.length; i++) {
    var p = prop + "-" + Evernote.ClipStyle.PERIMETERS[i];
    this._addSimpleStyle(p, valParts[i]);
  }
};
Evernote.ClipStyle.prototype._addPerimeterExtraStyle = function(prop, val) {
  var extras = Evernote.ClipStyle.PERIMETER_EXTRA_PROPS[prop];
  if (extras instanceof Array) {
    var valParts = val.replace(/\s+/g, " ").split(" ");
    var re = new RegExp(Evernote.ClipStyle.PERIMETERS.join("|"), "i");
    var perimetered = (prop.match(re)) ? true : false;
    for ( var i = 0; i < Evernote.ClipStyle.PERIMETERS.length; i++) {
      for ( var e = 0; e < extras.length; e++) {
        var p = prop
            + ((perimetered) ? "" : "-" + Evernote.ClipStyle.PERIMETERS[i])
            + "-" + extras[e];
        if (valParts[e]) {
          this._addSimpleStyle(p, valParts[e]);
        }
      }
      if (perimetered) {
        break;
      }
    }
  }
};
Evernote.ClipStyle.prototype._addSimpleStyle = function(prop, val) {
  if (typeof this[prop] == 'undefined') {
    this.length++;
  }
  this[prop] = val;
};
Evernote.ClipStyle.prototype.addStyle = function(style) {
  if (style instanceof CSSStyleDeclaration && style.length > 0) {
    for ( var i = 0; i < style.length; i++) {
      var prop = style[i];
      if (this.styleFilter
          && !this.styleFilter(prop, style.getPropertyValue(prop))) {
        continue;
      }
      var val = style.getPropertyValue(prop);
      if (typeof Evernote.ClipStyle.PERIMETER_PROPS[prop] != 'undefined') {
        this._addPerimeterStyle(prop, val);
      } else if (typeof Evernote.ClipStyle.PERIMETER_EXTRA_PROPS[prop] != 'undefined') {
        this._addPerimeterExtraStyle(prop, val);
      } else {
        this._addSimpleStyle(prop, val);
      }
    }
  } else if (style instanceof Evernote.ClipStyle) {
    for ( var prop in style) {
      if (typeof this.constructor.prototype[prop] == 'undefined') {
        if (this.styleFilter && !this.styleFilter(prop, style[prop])) {
          continue;
        }
        var val = style[prop];
        if (typeof Evernote.ClipStyle.PERIMETER_PROPS[prop] != 'undefined') {
          this._addPerimeterStyle(prop, val);
        } else if (typeof Evernote.ClipStyle.PERIMETER_EXTRA_PROPS[prop] != 'undefined') {
          this._addPerimeterExtraStyle(prop, val);
        } else {
          this._addSimpleStyle(prop, val);
        }
      }
    }
  } else if (typeof style == 'object' && style != null) {
    for ( var prop in style) {
      if (this.styleFilter && !this.styleFilter(prop, style[prop])) {
        continue;
      }
      if (typeof style[prop] != 'function'
          && typeof this.constructor.prototype[prop] == 'undefined') {
        var val = style[prop];
        if (typeof Evernote.ClipStyle.PERIMETER_PROPS[prop] != 'undefined') {
          this._addPerimeterStyle(prop, val);
        } else if (typeof Evernote.ClipStyle.PERIMETER_EXTRA_PROPS[prop] != 'undefined') {
          this._addPerimeterExtraStyle(prop, val);
        } else {
          this._addSimpleStyle(prop, val);
        }
      }
    }
  }
};
Evernote.ClipStyle.prototype.removeStyle = function(style, fn) {
  var self = this;
  function rem(prop, value) {
    if (typeof self[prop] != 'undefined'
        && typeof self.constructor.prototype[prop] == 'undefined'
        && (typeof fn == 'function' || self[prop] == value)) {
      if (typeof fn != 'function'
          || (typeof fn == 'function' && fn(prop, self[prop], value))) {
        if (delete (self[prop]))
          self.length--;
      }
    }
  }
  if (style instanceof CSSStyleDeclaration && style.length > 0) {
    for ( var i = 0; i < style.length; i++) {
      var prop = style[i];
      rem(prop, style.getPropertyValue(prop));
    }
  } else if (style instanceof Evernote.ClipStyle && style.length > 0) {
    for ( var prop in style) {
      rem(prop, style[prop]);
    }
  } else if (style instanceof Array) {
    for ( var i = 0; i < style.length; i++) {
      rem(style[i], this[style[i]]);
    }
  } else if (typeof style == 'string') {
    rem(style, this[style]);
  }
};
Evernote.ClipStyle.prototype.removeStyleIgnoreValue = function(style) {
  this.removeStyle(style, function(prop, propValue, value) {
    return true;
  });
};
Evernote.ClipStyle.styleInArray = function(style, styleArray) {
  if (typeof style != 'string' || !(styleArray instanceof Array))
    return false;
  var i = -1;
  var style = style.toLowerCase();
  var styleType = ((i = style.indexOf("-")) > 0) ? style.substring(0, i)
      .toLowerCase() : style.toLowerCase();
  for ( var i = 0; i < styleArray.length; i++) {
    if (styleArray[i] == style || styleArray[i] == styleType)
      return true;
  }
  return false;
};
/**
 * Derives to smaller set of style attributes by comparing differences with
 * given style and makes sure that style attributes in matchSyle are preserved.
 * This is useful for removing style attributes that are present in the parent
 * node. In that case, the instance will contain combined style attributes, and
 * the first argument to this function will be combined style attributes of the
 * parent node. The second argument will contain matched style attributes. The
 * result will contain only attributes that are free of duplicates while
 * preserving uniqueness of the style represented by this instance.
 */
Evernote.ClipStyle.prototype.deriveStyle = function(style, matchStyle,
    keepArray) {
  this.removeStyle(style, function(prop, propValue, value) {
    if (keepArray instanceof Array
        && Evernote.ClipStyle.styleInArray(prop, keepArray))
      return false;
    return (typeof matchStyle[prop] == 'undefined' && propValue == value);
  });
};
Evernote.ClipStyle.prototype.setFilter = function(filter) {
  if (typeof filter == 'function') {
    this._filter = filter;
  } else if (filter == null) {
    this._filter = null;
  }
};
Evernote.ClipStyle.prototype.getFilter = function() {
  return this._filter;
};
Evernote.ClipStyle.prototype.mergeStyle = function(style, override) {
  if (style instanceof Evernote.ClipStyle && style.length > 0) {
    var undef = true;
    for ( var i in style) {
      if (typeof this.constructor.prototype[i] != 'undefined'
          || typeof this.__lookupSetter__(i) != 'undefined') {
        continue;
      }
      if ((undef = (typeof this[i] == 'undefined')) || override) {
        this[i] = style[i];
        if (undef) {
          this.length++;
        }
      }
    }
  }
};
Evernote.ClipStyle.prototype.clone = function() {
  var clone = new Evernote.ClipStyle();
  for ( var prop in this) {
    if (typeof this.constructor.prototype[prop] == 'undefined') {
      clone[prop] = this[prop];
    }
  }
  clone.length = this.length;
  return clone;
};
Evernote.ClipStyle.prototype.toString_background = function(skipObj) {
  var str = "";
  if (typeof this["background-color"] != 'undefined'
      && this["background-color"] != "rgba(0, 0, 0, 0)") {
    str += "background: " + this["background-color"];
  }
  if (typeof this["background-image"] != 'undefined') {
    if (this["background-image"] != "none") {
      str += " " + this["background-image"];
      if (typeof this["background-position"] != 'undefined') {
        str += " " + this["background-position"];
      }
      if (typeof this["background-repeat"] != 'undefined') {
        str += " " + this["background-repeat"];
      }
    }
  }
  if (skipObj) {
    skipObj["background-color"] = null;
    skipObj["background-image"] = null;
    skipObj["background-position"] = null;
    skipObj["background-repeat"] = null;
  }
  if (str.length == 0) {
    str += "background:none;";
  } else if (str.length > 0 && str.charAt(str.length - 1) != ";") {
    str += ";";
  }
  return str;
};
Evernote.ClipStyle.prototype.toString_outline = function(skipObj) {
  var str = this._toPerimeterExtraString("outline");
  if (skipObj) {
    skipObj["outline-style"] = null;
    skipObj["outline-width"] = null;
    skipObj["outline-color"] = null;
  }
  if (str.length > 0 && str.charAt(str.length - 1) != ";") {
    str += ";";
  } else if (str.length == 0) {
    str = "outline:none;";
  }
  return str;
};
Evernote.ClipStyle.prototype.toString_margin = function(skipObj) {
  var str = this._toPerimeterString("margin");
  if (skipObj) {
    skipObj["margin-top"] = null;
    skipObj["margin-right"] = null;
    skipObj["margin-bottom"] = null;
    skipObj["margin-left"] = null;
  }
  if (str.length > 0 && str.charAt(str.length - 1) != ";") {
    str += ";";
  } else if (str.length == 0) {
    str = "margin:none;";
  }
  return str;
};
Evernote.ClipStyle.prototype.toString_padding = function(skipObj) {
  var str = this._toPerimeterString("padding");
  if (skipObj) {
    skipObj["padding-top"] = null;
    skipObj["padding-right"] = null;
    skipObj["padding-bottom"] = null;
    skipObj["padding-left"] = null;
  }
  if (str.length > 0 && str.charAt(str.length - 1) != ";") {
    str += ";";
  } else if (str.length == 0) {
    str = "padding:none;";
  }
  return str;
};
Evernote.ClipStyle.prototype.toString_border = function(skipObj) {
  var str = this._toPerimeterExtraString("border");
  if (skipObj) {
    skipObj["border-top-width"] = null;
    skipObj["border-top-style"] = null;
    skipObj["border-top-color"] = null;
    skipObj["border-right-width"] = null;
    skipObj["border-right-style"] = null;
    skipObj["border-right-color"] = null;
    skipObj["border-bottom-width"] = null;
    skipObj["border-bottom-style"] = null;
    skipObj["border-bottom-color"] = null;
    skipObj["border-left-width"] = null;
    skipObj["border-left-style"] = null;
    skipObj["border-left-color"] = null;
  }
  if (str.length > 0 && str.charAt(str.length - 1) != ";") {
    str += ";";
  }
  if (str.length == 0 || str.indexOf("none") >= 0) {
    str = "border:none;";
  }
  return str;
};
Evernote.ClipStyle.prototype.toString = function(shorten) {
  var str = "";
  var skip = {};
  if (shorten) {
    str += this.toString_background(skip);
    str += this.toString_border(skip);
    str += this.toString_margin(skip);
    str += this.toString_outline(skip);
    str += this.toString_padding(skip);
  }
  if (this.length > 0) {
    for ( var i in this) {
      if (typeof this[i] != 'string'
          || typeof this.constructor.prototype[i] != 'undefined'
          || this[i].length == 0 || typeof skip[i] != 'undefined')
        continue;
      str += i + ":" + this[i] + ";";
    }
  }
  return str;
};
Evernote.ClipStyle.prototype._toPerimeterString = function(prop) {
  var valParts = [];
  var allEqual = true;
  var missing = false;
  var str = "";
  for ( var i = 0; i < Evernote.ClipStyle.PERIMETERS.length; i++) {
    valParts[i] = this[prop + "-" + Evernote.ClipStyle.PERIMETERS[i]];
    if (valParts[i]) {
      str += prop + "-" + Evernote.ClipStyle.PERIMETERS[i] + ":" + valParts[i]
          + ";";
    } else {
      missing = true;
    }
    if (i > 0 && allEqual && valParts[i] != valParts[i - 1]) {
      allEqual = false;
    }
  }
  if (missing) {
    return str;
  } else if (allEqual) {
    valParts = [ valParts[0] ];
  } else if (valParts[0] == valParts[2] && valParts[1] == valParts[3]) {
    valParts = [ valParts[0], valParts[1] ];
  }
  return prop + ":" + valParts.join(" ") + ";";
};
Evernote.ClipStyle.prototype._toPerimeterExtraString = function(prop) {
  var perimParts = [];
  var allEqual = true;
  var str = "";
  for ( var i = 0; i < Evernote.ClipStyle.PERIMETERS.length; i++) {
    var pPrefix = prop + "-" + Evernote.ClipStyle.PERIMETERS[i];
    var extras = Evernote.ClipStyle.PERIMETER_EXTRA_PROPS[pPrefix]
        || Evernote.ClipStyle.PERIMETER_EXTRA_PROPS[prop];
    if (extras instanceof Array) {
      var part = "";
      var partStr = "";
      var missing = false;
      for ( var e = 0; e < extras.length; e++) {
        var fullProp = pPrefix + "-" + extras[e];
        if (this[fullProp]) {
          part += this[fullProp] + ((e == extras.length - 1) ? "" : " ");
          partStr += fullProp + ":" + this[fullProp] + ";";
        } else {
          missing = true;
          allEqual = false;
        }
      }
      if (!missing) {
        perimParts[i] = part;
        str += pPrefix + ":" + part + ";";
      } else {
        str += partStr;
      }
    }
    if (i > 0 && allEqual
        && (!perimParts[i] || perimParts[i] != perimParts[i - 1])) {
      allEqual = false;
    }
  }
  if (allEqual) {
    return prop + ":" + perimParts[0] + ";";
  } else {
    return str;
  }
};
Evernote.ClipStyle.prototype.toJSON = function() {
  var obj = {};
  if (this.length > 0) {
    for ( var i in this) {
      if (typeof this[i] != 'string'
          || typeof this.constructor.prototype[i] != 'undefined'
          || this[i].length == 0)
        continue;
      obj[i] = this[i];
    }
  }
  return obj;
};

/** ************** Evernote.SelectionFinder *************** */
/**
 * Evernote.SelectionFinder provides mechanism for finding selection on the page
 * via find(). It is able to traverse frames in order to find a selection. It
 * will report whether there's a selection via hasSelection(). After doing
 * find(), the selection is stored in the selection property, and the document
 * property will contain the document in which the selection was found. Find
 * method will only recurse documents if it was invoked as find(true),
 * specifying to do recursive search. You can use reset() to undo find().
 */
(function() {
  var LOG = null;
  var logEnabled = false;

  Evernote.SelectionFinder = function SelectionFinder(document) {
    this.initDocument = document;
    this.document = document;
    LOG = Evernote.Logger.getInstance();
    if (LOG.level == Evernote.Logger.LOG_LEVEL_DEBUG) {
      logEnabled = true;
    }
  };
  Evernote.SelectionFinder.prototype.initDocument = null;
  Evernote.SelectionFinder.prototype.document = null;
  Evernote.SelectionFinder.prototype.selection = null;

  Evernote.SelectionFinder.prototype.findNestedDocuments = function(doc) {
    var documents = new Array();
    var frames = doc.getElementsByTagName("frame");
    if (frames.length > 0) {
      for ( var i = 0; i < frames.length; i++) {
        documents.push(frames[i].contentDocument);
      }
    }
    var iframes = doc.getElementsByTagName("iframe");
    try {
      if (iframes.length > 0) {
        for ( var i = 0; i < iframes.length; i++) {
          var doc = iframes[i].contentDocument;
          if (doc) {
            documents.push(doc);
          }
        }
      }
    } catch (e) {
    }
    return documents;
  };
  Evernote.SelectionFinder.prototype.reset = function() {
    this.document = this.initDocument;
    this.selection = null;
  };
  Evernote.SelectionFinder.prototype.hasSelection = function() {
    var range = this.getRange();
    if (range
        && (range.startContainer != range.endContainer || (range.startContainer == range.endContainer && range.startOffset != range.endOffset))) {
      return true;
    }
    return false;
  };
  Evernote.SelectionFinder.prototype.find = function(deep) {
    var sel = this._findSelectionInDocument(this.document, deep);
    this.document = sel.document;
    this.selection = sel.selection;
  };
  Evernote.SelectionFinder.prototype.getRange = function() {
    if (!this.selection || this.selection.rangeCount == 0) {
      return null;
    }
    if (typeof this.selection.getRangeAt == 'function') {
      return this.selection.getRangeAt(0);
    } else {
      var range = this.document.createRange();
      range.setStart(this.selection.anchorNode, this.selection.anchorOffset);
      range.setEnd(this.selection.focusNode, this.selection.focusOffset);
      return range;
    }
    return null;
  };
  Evernote.SelectionFinder.prototype._findSelectionInDocument = function(doc,
      deep) {
    var sel = null;
    if (typeof doc.getSelection == 'function') {
      sel = doc.getSelection();
    } else if (doc.selection && typeof doc.selection.createRange == 'function') {
      sel = doc.selection.createRange();
    }
    if (sel && sel.rangeCount == 0 && deep) {
      if (logEnabled)
        console.log("Empty range, trying frames");
      var nestedDocs = this.findNestedDocuments(doc);
      if (logEnabled)
        console.log("# of nested docs: " + nestedDocs.length);
      if (nestedDocs.length > 0) {
        for ( var i = 0; i < nestedDocs.length; i++) {
          if (nestedDocs[i]) {
            if (logEnabled)
              console.log("Trying nested doc: " + nestedDocs[i]);
            var framedSel = this._findSelectionInDocument(nestedDocs[i], deep);
            if (framedSel.selection.rangeCount > 0) {
              return framedSel;
            }
          }
        }
      }
    }
    return {
      document : doc,
      selection : sel
    };
  };
})();

Evernote.ClipStylingStrategy = function ClipStylingStrategy(window) {
    this.initialize(window);
};
Evernote.ClipStylingStrategy.DEFAULT_FILTER = function(prop, val) {
    return (val && prop != "orphans" && prop != "widows" && prop != "speak"
    && prop.indexOf("page-break") != 0
    && prop.indexOf("pointer-events") != 0);
};
Evernote.ClipStylingStrategy.prototype.initialize = function(window) {
    this.window = window;
};
Evernote.ClipStylingStrategy.prototype.styleForNode = function(node, isRoot) {
    return null;
};
Evernote.ClipStylingStrategy.prototype.getNodeStyle = function(node, computed, filter) {
    var thisFilter = (typeof filter == 'function') ? filter: Evernote.ClipStylingStrategy.DEFAULT_FILTER;
    if (node && typeof node.nodeType == 'number' && node.nodeType == 1) {
        var doc = node.ownerDocument;
        var view = (doc.defaultView) ? doc.defaultView: this.window;
        var matchedRulesDefined = (typeof view["getMatchedCSSRules"] == 'function') ? true: false;
        if (computed) {
            return style = new Evernote.ClipStyle(view.getComputedStyle(node, ''), thisFilter);
        } else if (matchedRulesDefined) {
            return style = new Evernote.ClipStyle(view.getMatchedCSSRules(node, ''), thisFilter);
        }
    }
    var s = new Evernote.ClipStyle();
    s.setFilter(thisFilter);
    return s;
};
Evernote.ClipStylingStrategy.prototype.getFontFaceRules = function() {
    return Evernote.ClipStyle.findFontFaceRules();
};
Evernote.ClipStylingStrategy.prototype.cleanUp = function() {
    return true;
};


Evernote.ClipTextStylingStrategy = function ClipTextStylingStrategy(window) {
    this.initialize(window);
};
Evernote.inherit(Evernote.ClipTextStylingStrategy, Evernote.ClipStylingStrategy);
Evernote.ClipTextStylingStrategy.FORMAT_NODE_NAMES = {
    "b": null,
    "big": null,
    "em": null,
    "i": null,
    "small": null,
    "strong": null,
    "sub": null,
    "sup": null,
    "ins": null,
    "del": null,
    "s": null,
    "strike": null,
    "u": null,
    "code": null,
    "kbd": null,
    "samp": null,
    "tt": null,
    "var": null,
    "pre": null,
    "listing": null,
    "plaintext": null,
    "xmp": null,
    "abbr": null,
    "acronym": null,
    "address": null,
    "bdo": null,
    "blockquote": null,
    "q": null,
    "cite": null,
    "dfn": null
};
Evernote.ClipTextStylingStrategy.STYLE_ATTRS = {
    "font": null,
    "text": null,
    "color": null
};
Evernote.ClipTextStylingStrategy.COLOR_THRESH = 50;
Evernote.ClipTextStylingStrategy.prototype.isFormatNode = function(node) {
    return (node && node.nodeType == 1 && typeof Evernote.ClipTextStylingStrategy.FORMAT_NODE_NAMES[node.nodeName
    .toLowerCase()] != 'undefined');
};
Evernote.ClipTextStylingStrategy.prototype.hasTextNodes = function(node) {
    if (node && node.nodeType == 1 && node.childNodes.length > 0) {
        for (var i = 0; i < node.childNodes.length; i++) {
            if (node.childNodes[i].nodeType == 3) {
                return true;
            }
        }
    }
    return false;
};
Evernote.ClipTextStylingStrategy.prototype.styleFilter = function(style) {
    var s = Evernote.ClipStyle.stylePrefix(style.toLowerCase());
    if (typeof Evernote.ClipTextStylingStrategy.STYLE_ATTRS[s] != 'undefined') {
        return true;
    }
};
Evernote.ClipTextStylingStrategy.prototype.styleForNode = function(node, isRoot) {
    var nodeStyle = null;
    if (this.isFormatNode(node) || this.hasTextNodes(node)) {
        nodeStyle = this.getNodeStyle(node, true, this.styleFilter);
    }
    if (nodeStyle && nodeStyle["color"]){
      var color = nodeStyle["color"];
      var a = "";
      var colorParts = color.replace(/[^0-9,\s]+/g, "").replace(/[,\s]+/g, " ").split(/\s+/);
      var r = parseInt(colorParts[0]);
      r = (isNaN(r)) ? 0 : r;
      var g = parseInt(colorParts[1]);
      g = (isNaN(g)) ? 0 : r;
      var b = parseInt(colorParts[2]);
      b = (isNaN(b)) ? 0 : b;
      if ((r + g + b) > (255 - Evernote.ClipTextStylingStrategy.COLOR_THRESH)*3) {
        r = Math.max(0, r - Evernote.ClipTextStylingStrategy.COLOR_THRESH);
        g = Math.max(0, g - Evernote.ClipTextStylingStrategy.COLOR_THRESH);
        b = Math.max(0, b - Evernote.ClipTextStylingStrategy.COLOR_THRESH);
      }
      nodeStyle["color"] = (colorParts.length == 4) ? "rgba("+[r, g, b, 1].join(", ")+")" : "rgb("+[r, g, b].join(", ")+")";
    }
    return nodeStyle;
};

Evernote.ClipFullStylingStrategy = function ClipFullStylingStrategy(window) {
  this.initialize(window);
};
Evernote
    .inherit(Evernote.ClipFullStylingStrategy, Evernote.ClipStylingStrategy);
Evernote.ClipFullStylingStrategy.SKIP_UNDEFINED_PROPS = {
  "widows" : null,
  "orphans" : null,
  "pointer-events" : null,
  "speak" : null
};
Evernote.ClipFullStylingStrategy.SKIP_NONINHERENT_AUTO_PROPS = {
  "left" : "auto",
  "right" : "auto",
  "float" : "auto",
  "clear" : "auto",
  "image-rendering" : "auto",
  "z-index" : "auto",
  "color-rendering" : "auto",
  "shapre-rendering" : "auto",
  "page-break-before" : "auto",
  "page-break-after" : "auto",
  "page-break-inside" : "auto"
};
Evernote.ClipFullStylingStrategy.LIST_NODES = {
  "UL" : null,
  "OL" : null,
  "LI" : null
};
Evernote.ClipFullStylingStrategy.NODE_PROPS = {
  "BR" : [ "clear", "padding", "margin", "line-height", "border", "white-space" ]
};
Evernote.ClipFullStylingStrategy.prototype.styleForNode = function(node, isRoot) {
  var matchedStyle = this.getNodeStyle(node, false);
  var nodeStyle = this
      .getNodeStyle(
          node,
          true,
          function(p, v) {
            if (typeof Evernote.ClipFullStylingStrategy.NODE_PROPS[node.nodeName] != 'undefined') {
              if (Evernote.ClipFullStylingStrategy.NODE_PROPS[node.nodeName]
                  .indexOf(p) >= 0) {
                return true;
              } else {
                return false;
              }
            }
            if (p
                && (p.indexOf("-webkit-") == 0 || p.indexOf("-moz-") == 0 || typeof Evernote.ClipFullStylingStrategy.SKIP_UNDEFINED_PROPS[p] != 'undefined')) {
              if (matchedStyle.length == 0
                  || typeof matchedStyle[p] == 'undefined') {
                return false;
              } else {
                return true;
              }
            } else if (p && p.indexOf("list-style") == 0) {
              if (node
                  && node.nodeName
                  && typeof Evernote.ClipFullStylingStrategy.LIST_NODES[node.nodeName] != 'undefined') {
                return true;
              } else {
                if (matchedStyle.length == 0
                    || typeof matchedStyle[p] == 'undefined') {
                  return false;
                } else {
                  return true;
                }
              }
            } else if (p
                && p == "height"
                && typeof Evernote.ClipFullStylingStrategy.LIST_NODES[node.nodeName] != 'undefined') {
              return false;
            } else if (p
                && typeof Evernote.ClipFullStylingStrategy.SKIP_NONINHERENT_AUTO_PROPS[p] != 'undefined') {
              if (v == Evernote.ClipFullStylingStrategy.SKIP_NONINHERENT_AUTO_PROPS[p]
                  && (matchedStyle.length == 0 || typeof matchedStyle[p] == 'undefined')) {
                return false;
              } else {
                return true;
              }
            }
            return true;
          });
  if (isRoot && typeof nodeStyle["width"] != 'undefined') {
    nodeStyle._addSimpleStyle("min-width", nodeStyle.width);
    var children = node.children;
    var childrenFloat = false;
    var childrenBoundingRect = null;
    if (children && children.length > 0) {
      for ( var c = 0; c < children.length; c++) {
        var childStyle = this.getNodeStyle(children[c], true);
        var childBoundingRect = children[c].getBoundingClientRect();
        if (!childrenBoundingRect) {
          childrenBoundingRect = childBoundingRect;
        } else {
          this._mergeBoundingRects(childrenBoundingRect, childBoundingRect);
        }
        if (childStyle["float"] && childStyle["float"] != "none"
            && childStyle["float"] != "auto") {
          childrenFloat = true;
        }
      }
    }
    if (!childrenFloat || !childrenBoundingRect) {
      nodeStyle.removeStyle("height");
    } else {
      nodeStyle._addSimpleStyle("height", childrenBoundingRect.height);
    }
    nodeStyle
        .removeStyle( [ "position", "left", "right", "top", "bottom",
            "margin-left", "margin-right", "margin-top", "margin-bottom",
            "float" ]);
    var bgStyle = this._inhBackgroundForNode(node, true);
    if (bgStyle["background-color"]) {
      nodeStyle["background-color"] = bgStyle["background-color"];
    }
    if (bgStyle["background-image"]) {
      nodeStyle["background-image"] = bgStyle["background-image"];
      var coords = node.getBoundingClientRect();
      if (coords) {
        nodeStyle["background-position-x"] = (0 - coords.left) + "px";
        nodeStyle["background-position-y"] = (0 - coords.top) + "px";
        nodeStyle["background-position"] = nodeStyle["background-position-x"]
            + " " + nodeStyle["background-position-y"];
      }
      if (bgStyle["opacity"]) {
        nodeStyle["opacity"] = bgStyle["opacity"];
      }
      if (bgStyle["filter"]) {
        nodeStyle["filter"] = bgStyle["filter"];
      }
    }
  }
  if (node.nodeName == "BODY") {
    var w = this.window.document.documentElement.scrollWidth;
    var h = this.window.document.documentElement.scrollHeight;
    nodeStyle._addSimpleStyle("width", w + "px");
    nodeStyle._addSimpleStyle("height", h + "px");
  }
  return nodeStyle;
};
Evernote.ClipFullStylingStrategy.prototype._mergeBoundingRects = function(a, b) {
  a.left = Math.min(a.left, b.left);
  a.right = Math.max(a.right, b.right);
  a.top = Math.min(a.top, b.top);
  a.bottom = Math.max(a.bottom, b.bottom);
  a.width = a.right - a.left;
  a.height = a.bottom - a.top;
};
Evernote.ClipFullStylingStrategy.prototype._inhBackgroundForNode = function(
    node, recur) {
  var parent = node.parentNode;
  var styles = [];
  var bgExtraAttrs = [ "background-repeat-x", "background-repeat-y",
      "background-position-x", "background-position-y", "background-origin",
      "background-size" ];
  while (parent) {
    styles.push(this.getNodeStyle(parent, true,
        function(p, v) {
          if ((p == "background-color" && v != "rgba(0, 0, 0, 0)")
              || (p == "background-image" && v != "none")
              || (bgExtraAttrs.indexOf(p) >= 0) || p == "opacity"
              || p == "filter") {
            return true;
          }
          return false;
        }));
    if (!recur || parent == this.window.document.body) {
      break;
    } else {
      parent = parent.parentElement;
    }
  }
  // styles.reverse();
  var bgStyle = new Evernote.ClipStyle();
  var _bgColorSet = 0;
  for ( var i = 0; i < styles.length; i++) {
    var s = styles[i];
    if (s["background-color"] && !bgStyle["background-color"]) {
      _bgColorSet = i;
      bgStyle._addSimpleStyle("background-color", s["background-color"]);
    }
    // set background image only if it hasn't been set already and the bg color
    // wasn't set previously
    if (s["background-image"] && !bgStyle["background-image"]
        && (i == _bgColorSet || !bgStyle["background-color"])) {
      bgStyle._addSimpleStyle("background-image", s["background-image"]);
      for ( var i = 0; i < bgExtraAttrs.length; i++) {
        var bgAttr = bgExtraAttrs[i];
        if (s[bgAttr]) {
          bgStyle._addSimpleStyle(bgAttr, s[bgAttr]);
        }
      }
    }
    if (s["opacity"]
        && !bgStyle["opacity"]
        && !isNaN(parseFloat(s["opacity"]))
        && (typeof bgStyle["opacity"] == 'undefined' || parseFloat(s["opacity"]) < parseFloat(bgStyle["opacity"]))) {
      bgStyle._addSimpleStyle("opacity", s["opacity"]);
    }
    if (s["filter"]
        && !bgStyle["filter"]
        && (typeof bgStyle["filter"] == 'undefined' || parseFloat(s["filter"]
            .replace(/[^0-9]+/g, "")) < parseFloat(bgStyle["filter"].replace(
            /[^0-9]+/g, "")))) {
      bgStyle._addSimpleStyle("filter", s["filter"]);
    }
    /*
     * if (bgStyle.length > 0) { break; }
     */
  }
  return bgStyle;
};
Evernote.ClipFullStylingStrategy.prototype.cleanUp = function() {
  if (this._dirty) {
    var els = this.window.document.getElementsByTagName("*");
    for ( var i = 0; i < els.length; i++) {
      delete els[i][this.constructor.COMPUTED_STYLE_KEY];
    }
  }
  return true;
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

Evernote.RequestMessage = function RequestMessage(code, message) {
  this.initialize(code, message);
};
Evernote.RequestMessage.fromObject = function(obj) {
  var msg = new Evernote.RequestMessage();
  if (typeof obj == 'object' && obj != null) {
    if (typeof obj["code"] != 'undefined') {
      msg.code = obj.code;
    }
    if (typeof obj["message"] != 'undefined') {
      msg.message = obj.message;
    }
  }
  return msg;
};
Evernote.RequestMessage.prototype._code = 0;
Evernote.RequestMessage.prototype._message = null;
Evernote.RequestMessage.prototype._callback = null;
Evernote.RequestMessage.prototype.initialize = function(code, message, fn) {
  this.__defineGetter__("code", this.getCode);
  this.__defineSetter__("code", this.setCode);
  this.__defineGetter__("message", this.getMessage);
  this.__defineSetter__("message", this.setMessage);
  this.__defineGetter__("callback", this.getCallback);
  this.__defineSetter__("callback", this.setCallback);
  this.code = code;
  this.message = message;
};
Evernote.RequestMessage.prototype.getCode = function() {
  return this._code;
};
Evernote.RequestMessage.prototype.setCode = function(code) {
  this._code = parseInt(code);
  if (isNaN(this._code)) {
    this._code = 0;
  }
};
Evernote.RequestMessage.prototype.getMessage = function() {
  return this._message;
};
Evernote.RequestMessage.prototype.setMessage = function(message) {
  this._message = message;
};
Evernote.RequestMessage.prototype.getCallback = function() {
  return this._callback;
};
Evernote.RequestMessage.prototype.setCallback = function(fn) {
  if (typeof fn == 'function' || fn == null) {
    this._callback = fn;
  }
};
Evernote.RequestMessage.prototype.send = function() {
  chrome.extension.sendRequest( {
    code : this.code,
    message : this.message
  });
};
Evernote.RequestMessage.prototype.isEmpty = function() {
  return (this.code) ? false : true;
};

(function() {
  var LOG = null;
  var logEnabled = false;

  Evernote.ContentClipper = function ContentClipper() {
    LOG = Evernote.Logger.getInstance();
    LOG.level = Evernote.ContentClipper.LOG_LEVEL;
    if (LOG.level == Evernote.Logger.LOG_LEVEL_DEBUG) {
      logEnabled = true;
    }
    try {
      var style = document.createElement("link");
      style.setAttribute("rel", "stylesheet");
      style.setAttribute("type", "text/css");
      style.setAttribute("href", "chrome-extension://"
          + chrome.i18n.getMessage("@@extension_id")
          + "/css/contentclipper.css");
      if (document.head) {
        document.head.appendChild(style);
      } else if (document.body && document.body.parentNode) {
        document.body.parentNode.appendChild(style);
      }
    } catch (e) {
      LOG
          .warn("Could not inject our own style sheets... Could be that we're dealing with a file view and not a web page");
    }
  };

  Evernote.ContentClipper._instance = null;
  Evernote.ContentClipper.getInstance = function() {
    if (!this._instance) {
      this._instance = new Evernote.ContentClipper();
    }
    return this._instance;
  };
  Evernote.ContentClipper.destroyInstance = function() {
    this._instance = null;
  };

  Evernote.ContentClipper.LOG_LEVEL = 0;

  Evernote.ContentClipper.prototype.clip = null;

  Evernote.ContentClipper.prototype.PAGE_CLIP_SUCCESS = Evernote.Constants.RequestType.PAGE_CLIP_SUCCESS;
  Evernote.ContentClipper.prototype.PAGE_CLIP_CONTENT_TOO_BIG = Evernote.Constants.RequestType.PAGE_CLIP_CONTENT_TOO_BIG;
  Evernote.ContentClipper.prototype.PAGE_CLIP_CONTENT_SUCCESS = Evernote.Constants.RequestType.PAGE_CLIP_CONTENT_SUCCESS;
  Evernote.ContentClipper.prototype.PAGE_CLIP_CONTENT_FAILURE = Evernote.Constants.RequestType.PAGE_CLIP_CONTENT_FAILURE;
  Evernote.ContentClipper.prototype.PAGE_CLIP_FAILURE = Evernote.Constants.RequestType.PAGE_CLIP_FAILURE;
  Evernote.ContentClipper.prototype.WAIT_CONTAINER_ID = "evernoteContentClipperWait";

  Evernote.ContentClipper.prototype.onClip = function(clip) {
    new Evernote.RequestMessage(this.PAGE_CLIP_SUCCESS, clip.toDataObject())
        .send();
  };
  Evernote.ContentClipper.prototype.onClipContent = function(clip) {
    new Evernote.RequestMessage(this.PAGE_CLIP_CONTENT_SUCCESS, clip
        .toDataObject()).send();
  };
  Evernote.ContentClipper.prototype.onClipFailure = function(error) {
    new Evernote.RequestMessage(this.PAGE_CLIP_FAILURE, error).send();
  };
  Evernote.ContentClipper.prototype.onClipContentFailure = function(error) {
    new Evernote.RequestMessage(this.PAGE_CLIP_CONTENT_FAILURE, error).send();
  };
  Evernote.ContentClipper.prototype.onClipContentTooBig = function(clip) {
    new Evernote.RequestMessage(this.PAGE_CLIP_CONTENT_TOO_BIG, clip
        .toDataObject()).send();
  };

  Evernote.ContentClipper.prototype.perform = function(fullPageOnly,
      stylingStrategy, showWait) {
    if (showWait) {
      this.wait();
      var self = this;
      setTimeout(function() {
        self._perform(fullPageOnly, stylingStrategy);
        self.clearWait();
      }, 100);
    } else {
      this._perform(fullPageOnly, stylingStrategy);
    }
  };

  Evernote.ContentClipper.prototype._perform = function(fullPageOnly,
      stylingStrategy) {
    if (logEnabled)
      LOG.debug("Contentscript clipping...");

    // construct Evernote.Clip
    var self = this;
    this.clip = new Evernote.Clip(window, stylingStrategy,
        (Evernote.Constants.Limits.CLIP_NOTE_CONTENT_LEN_MAX));
    this.clip.onsizeexceed = function() {
      LOG.debug("Content size exceeded during serialization");
      self.onClipContentTooBig(self.clip);
    };
    if (logEnabled)
      LOG.debug("CLIP: " + this.clip.toString());

    try {
      if (!fullPageOnly && this.clip.hasSelection()
          && this.clip.clipSelection()) {
        if (logEnabled)
          LOG.debug("Successful clip of selection: " + this.clip.toString());
        if (this.clip.sizeExceeded
            || this.clip.length >= (Evernote.Constants.Limits.CLIP_NOTE_CONTENT_LEN_MAX)) {
          if (logEnabled)
            LOG.debug("Notifying full page clip failure");
          this.onClipContentTooBig(this.clip);
        } else {
          this.onClipContent(this.clip);
        }
      } else if (this.clip.hasBody()) {
        this.onClip(this.clip);
        if (this.clip.clipBody()) {
          if (this.clip.sizeExceeded
              || this.clip.length >= (Evernote.Constants.Limits.CLIP_NOTE_CONTENT_LEN_MAX)) {
            if (logEnabled)
              LOG.debug("Notifying full page clip failure");
            this.onClipContentTooBig(this.clip);
          } else {
            if (logEnabled)
              LOG.debug("Notifying full page clip success");
            this.onClipContent(this.clip);
          }
        } else {
          this.onClipContentFailure(chrome.i18n
              .getMessage("fullPageClipFailure"));
        }
      } else {
        if (logEnabled)
          LOG.debug("Failed to clip full page");
        this.onClipFailure(chrome.i18n.getMessage("fullPageClipFailure"));
      }
    } catch (e) {
      // Can't construct a clip -- usually because the body is a frame
      if (logEnabled)
        LOG.debug("Exception clipping page or its selection"
            + ((typeof e.message != 'undefined') ? ": " + e.message : ""));
      this.onClipFailure(e.message);
    }
    if (logEnabled)
      LOG.debug("Done clipping...");
  };

  Evernote.ContentClipper.prototype.getWaitContainer = function() {
    var container = document.getElementById(this.WAIT_CONTAINER_ID);
    if (!container) {
      container = document.createElement("evernotediv");
      container.id = this.WAIT_CONTAINER_ID;
      var content = document.createElement("div");
      content.id = this.WAIT_CONTAINER_ID + "Content";
      container.appendChild(content);
      var center = document.createElement("center");
      content.appendChild(center);
      var spinner = document.createElement("img");
      spinner.setAttribute("src", "chrome-extension://"
          + chrome.i18n.getMessage("@@extension_id")
          + "/images/icon_scissors.png");
      center.appendChild(spinner);
      var text = document.createElement("span");
      text.id = this.WAIT_CONTAINER_ID + "Text";
      center.appendChild(text);
      container._waitMsgBlock = text;
      container.setMessage = function(msg) {
        this._waitMsgBlock.innerHTML = msg;
      };
    }
    return container;
  };

  Evernote.ContentClipper.prototype.wait = function() {
    var wait = this.getWaitContainer();
    wait.style.opacity = "1";
    wait.setMessage(chrome.i18n.getMessage("contentclipper_clipping"));
    document.body.appendChild(wait);
  };
  Evernote.ContentClipper.prototype.clearWait = function() {
    var wait = document.getElementById(this.WAIT_CONTAINER_ID);
    if (wait) {
      wait.style.opacity = "0";
      setTimeout(function() {
        wait.parentNode.removeChild(wait);
      }, 1000);
    }
  };

})();

