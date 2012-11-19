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
 * Evernote
 * Errors
 * 
 * Created by Pavel Skaldin on 2/23/10
 * Copyright 2010 Evernote Corp. All rights reserved.
 */
Evernote.EvernoteError = function EvernoteError(errorCodeOrObj, message,
    parameter) {
  this.__defineGetter__("errorCode", this.getErrorCode);
  this.__defineSetter__("errorCode", this.setErrorCode);
  this.__defineGetter__("modelName", this.getModelName);
  this.initialize(errorCodeOrObj, message, parameter);
};
Evernote.EvernoteError.CLASS_FIELD = "javaClass";
Evernote.EvernoteError.ERROR_CODE_FIELD = "errorCode";
Evernote.EvernoteError.MESSAGE_FIELD = "message";
Evernote.EvernoteError.PARAMETER_FIELD = "parameter";
Evernote.EvernoteError.javaClass = "com.evernote.web.EvernoteError";
Evernote.EvernoteError.prototype.handleInheritance = function(child, parent) {
  if (typeof child.prototype.constructor[Evernote.EvernoteError.CLASS_FIELD] == 'string') {
    Evernote.EvernoteError.Registry[child.prototype.constructor[Evernote.EvernoteError.CLASS_FIELD]] = child;
  }
};
Evernote.EvernoteError.prototype._errorCode = null;
Evernote.EvernoteError.prototype.message = null;
Evernote.EvernoteError.prototype.parameter = null;
Evernote.EvernoteError.prototype.getModelName = function() {
  return this.constructor.name;
};
Evernote.EvernoteError.prototype.initialize = function(errorCodeOrObj, message,
    parameter) {
  if (errorCodeOrObj && typeof errorCodeOrObj == 'object') {
    if (typeof errorCodeOrObj[Evernote.EvernoteError.ERROR_CODE_FIELD] != 'undefined') {
      this.errorCode = errorCodeOrObj[Evernote.EvernoteError.ERROR_CODE_FIELD];
    }
    if (typeof errorCodeOrObj[Evernote.EvernoteError.MESSAGE_FIELD] != 'undefined') {
      this.message = errorCodeOrObj[Evernote.EvernoteError.MESSAGE_FIELD];
    }
    if (typeof errorCodeOrObj[Evernote.EvernoteError.PARAMETER_FIELD] != 'undefined') {
      this.parameter = errorCodeOrObj[Evernote.EvernoteError.PARAMETER_FIELD];
    }
  } else {
    if (typeof errorCodeOrObj != 'undefined')
      this.errorCode = errorCodeOrObj;
    if (typeof message != 'undefined')
      this.message = message;
    if (typeof parameter != 'undefined')
      this.parameter = parameter;
  }
};
Evernote.EvernoteError.prototype.setErrorCode = function(errorCode) {
  this._errorCode = (isNaN(parseInt(errorCode))) ? null : parseInt(errorCode);
};
Evernote.EvernoteError.prototype.getErrorCode = function() {
  return this._errorCode;
};
Evernote.EvernoteError.prototype.getClassName = function() {
  return (typeof this.constructor[Evernote.EvernoteError.CLASS_FIELD] != 'undefined') ? this.constructor[Evernote.EvernoteError.CLASS_FIELD]
      : null;
};
Evernote.EvernoteError.prototype.getShortClassName = function() {
  var className = this.getClassName();
  if (typeof className == 'string') {
    var parts = className.split(".");
    className = parts[parts.length - 1];
  }
  return className;
};
Evernote.EvernoteError.prototype.toJSON = function() {
  var obj = {
    errorCode : this.errorCode,
    message : this.message,
    parameter : this.parameter
  };
  if (this.constructor[Evernote.EvernoteError.CLASS_FIELD]) {
    obj[Evernote.EvernoteError.CLASS_FIELD] = this.constructor[Evernote.EvernoteError.CLASS_FIELD];
  }
  return obj;
};
Evernote.EvernoteError.prototype.toString = function() {
  var className = this.getShortClassName();
  if (className == null)
    return "Evernote.EvernoteError";
  return (className + " (" + this.errorCode + ") [" + this.parameter + "]" + ((typeof this.message == 'string') ? this.message
      : ""));
};
Evernote.EvernoteError.Registry = {};
Evernote.EvernoteError.responsibleConstructor = function(className) {
  if (typeof Evernote.EvernoteError.Registry[className] == 'function') {
    return Evernote.EvernoteError.Registry[className];
  } else {
    return Evernote.EvernoteError;
  }
};
Evernote.EvernoteError.fromObject = function(obj) {
  if (obj instanceof Evernote.EvernoteError) {
    return obj;
  } else if (typeof obj == 'object' && obj) {
    return Evernote.EvernoteError.unmarshall(obj);
  } else {
    return new Evernote.EvernoteError();
  }
};
Evernote.EvernoteError.unmarshall = function(obj) {
  var newObj = null;
  if (typeof obj != 'object' || !obj) {
    return obj;
  }
  if (typeof obj[Evernote.EvernoteError.CLASS_FIELD] == 'string'
      && typeof Evernote.EvernoteError.Registry[obj[Evernote.EvernoteError.CLASS_FIELD]] == 'function') {
    var constr = Evernote.EvernoteError.Registry[obj[Evernote.EvernoteError.CLASS_FIELD]];
    newObj = new constr();
  } else {
    newObj = new this();
  }
  if (newObj) {
    if (obj["errorCode"]) {
      newObj.errorCode = obj.errorCode;
    }
    if (obj["message"]) {
      newObj.message = obj.message;
    }
    if (obj["parameter"]) {
      newObj.parameter = obj.parameter;
    }
  }
  return newObj;
};
Evernote.EvernoteError.marshall = function(data) {
  if (data instanceof Array) {
    var newArray = new Array();
    for ( var i = 0; i < data.length; i++) {
      newArray.push(Evernote.EvernoteError._marshall(data[i]));
    }
    return newArray;
  } else {
    return Evernote.EvernoteError._marshall(data);
  }
};
Evernote.EvernoteError._marshall = function(data) {
  if (data instanceof Evernote.EvernoteError) {
    return data.toJSON();
  } else {
    return data;
  }
};

/**
 * Generic Evernote.Exception
 */
Evernote.Exception = function Exception(errorCodeOrObj, message) {
  this.initialize(errorCodeOrObj, message, null);
};
Evernote.Exception.javaClass = "java.lang.Exception";
Evernote.inherit(Evernote.Exception, Evernote.EvernoteError);
Evernote.Exception.prototype._errorCode = 0;

/**
 * Evernote.EDAMSystemException
 */
Evernote.EDAMSystemException = function EDAMSystemException(errorCodeOrObj,
    message) {
  this.initialize(errorCodeOrObj, message);
};
Evernote.EDAMSystemException.javaClass = "com.evernote.edam.error.EDAMSystemException";
Evernote.inherit(Evernote.EDAMSystemException, Evernote.Exception);

/**
 * Evernote.EDAMUserException
 */
Evernote.EDAMUserException = function EDAMUserException(errorCodeOrObj,
    message, parameter) {
  this.initialize(errorCodeOrObj, message, parameter);
};
Evernote.EDAMUserException.javaClass = "com.evernote.edam.error.EDAMUserException";
Evernote.inherit(Evernote.EDAMUserException, Evernote.Exception);

/**
 * Evernote.EDAMResponseException holds various errors associated with actual
 * responses from the server
 * 
 * @param errorCodeOrObj
 * @param message
 * @param parameter
 * @return
 */
Evernote.EDAMResponseException = function EDAMResponseException(errorCodeOrObj,
    message) {
  this.initialize(errorCodeOrObj, message);
};
Evernote.EDAMResponseException.javaClass = "com.evernote.edam.error.EDAMResponseException";
Evernote.inherit(Evernote.EDAMResponseException, Evernote.EvernoteError);

/**
 * Evernote.ValidationError is a base for various types of validation errors.
 * Validation errors are responses from the server indicating that there was a
 * problem validating request with its parameters.
 * 
 * @param errorCodeOrObj
 * @param message
 * @param parameter
 * @return
 */
Evernote.ValidationError = function ValidationError(errorCodeOrObj, message,
    parameter) {
  this.initialize(errorCodeOrObj, message, parameter);
};
Evernote.ValidationError.GLOBAL_PARAMETER = "__stripes_global_error";
Evernote.ValidationError.javaClass = "net.sourceforge.stripes.validation.ValidationError";
Evernote.inherit(Evernote.ValidationError, Evernote.EvernoteError);
Evernote.ValidationError.prototype.isGlobal = function() {
  return (this.parameter == null || this.parameter == Evernote.ValidationError.GLOBAL_PARAMETER);
};

/**
 * Evernote.SimpleError is a simple type of validation error. It has no error
 * codes associated with it. Just messages.
 * 
 * @param message
 * @return
 */
Evernote.SimpleError = function SimpleError(message) {
  this.initialize(null, message, null);
};
Evernote.SimpleError.javaClass = "net.sourceforge.stripes.validation.SimpleError";
Evernote.inherit(Evernote.SimpleError, Evernote.ValidationError);

/**
 * Evernote.ScopedLocalizableError is like a Evernote.SimpleError but provides
 * an error code and optionally a message and a parameter. Parameter indicates
 * which part of the request this error refers to.
 * 
 * @param errorCodeOrObj
 * @param message
 * @param parameter
 * @return
 */
Evernote.ScopedLocalizableError = function ScopedLocalizableError(
    errorCodeOrObj, message, parameter) {
  this.initialize(errorCodeOrObj, message, parameter);
};
Evernote.ScopedLocalizableError.javaClass = "net.sourceforge.stripes.validation.ScopedLocalizableError";
Evernote.inherit(Evernote.ScopedLocalizableError, Evernote.SimpleError);

/**
 * Evernote.EDAMScopedError is like a Evernote.ScopedLocalizableError but is
 * bound to Evernote.EDAMErrorCode's. These are typically included in a response
 * when a custom validation failed.
 * 
 * @param errorCodeOrObj
 * @param message
 * @param parameter
 * @return
 */
Evernote.EDAMScopedError = function EDAMScopedError(errorCodeOrObj, message,
    parameter) {
  this.initialize(errorCodeOrObj, message, parameter);
};
Evernote.EDAMScopedError.javaClass = "com.evernote.web.EDAMScopedError";
Evernote.inherit(Evernote.EDAMScopedError, Evernote.ScopedLocalizableError);


Evernote.DefiningMixin = function DefiningMixin() {
};

Evernote.DefiningMixin._getTargetFor = function(caller) {
  if (typeof caller == 'function' && caller == caller.prototype.constructor) {
    return caller.prototype;
  } else {
    return caller;
  }
};

Evernote.DefiningMixin.prototype.__defineBoolean__ = function(fieldName,
    defaultValue, dontIncludeGetter, dontIncludeSetter) {
  var protoFieldName = "_" + fieldName;
  var rootName = fieldName.substring(0, 1).toUpperCase()
      + fieldName.substring(1);
  var target = Evernote.DefiningMixin._getTargetFor(arguments.callee.caller);
  target[protoFieldName] = (defaultValue) ? true : false;
  if (!dontIncludeGetter) {
    var getterName = "is" + rootName;
    target[getterName] = function() {
      return this[protoFieldName];
    };
    this.__defineGetter__(fieldName, target[getterName]);
  }
  if (!dontIncludeSetter) {
    var setterName = "set" + rootName;
    target[setterName] = function(bool) {
      this[protoFieldName] = (bool) ? true : false;
    };
    this.__defineSetter__(fieldName, target[setterName]);
  }
};

Evernote.DefiningMixin.prototype.__defineFloat__ = function(fieldName,
    defaultValue, dontIncludeGetter, dontIncludeSetter) {
  var target = Evernote.DefiningMixin._getTargetFor(arguments.callee.caller);
  this._createNumericDefinition_(target, fieldName, defaultValue, false,
      parseFloat, dontIncludeGetter, dontIncludeSetter);
};

Evernote.DefiningMixin.prototype.__definePositiveFloat__ = function(fieldName,
    defaultValue, dontIncludeGetter, dontIncludeSetter) {
  var target = Evernote.DefiningMixin._getTargetFor(arguments.callee.caller);
  this._createNumericDefinition_(target, fieldName, defaultValue, true,
      parseFloat, dontIncludeGetter, dontIncludeSetter);
};

Evernote.DefiningMixin.prototype.__defineInteger__ = function(fieldName,
    defaultValue, dontIncludeGetter, dontIncludeSetter) {
  var target = Evernote.DefiningMixin._getTargetFor(arguments.callee.caller);
  this._createNumericDefinition_(target, fieldName, defaultValue, false,
      parseInt, dontIncludeGetter, dontIncludeSetter);
};

Evernote.DefiningMixin.prototype.__definePositiveInteger__ = function(
    fieldName, defaultValue, dontIncludeGetter, dontIncludeSetter) {
  var target = Evernote.DefiningMixin._getTargetFor(arguments.callee.caller);
  this._createNumericDefinition_(target, fieldName, defaultValue, true,
      parseInt, dontIncludeGetter, dontIncludeSetter);
};

Evernote.DefiningMixin.prototype._createNumericDefinition_ = function(target,
    fieldName, defaultValue, positiveValuesOnly, parseFn, dontIncludeGetter,
    dontIncludeSetter) {
  var rootName = fieldName.substring(0, 1).toUpperCase()
      + fieldName.substring(1);
  var protoFieldName = "_" + fieldName;
  defaultValue = (typeof defaultValue == 'number') ? defaultValue : null;
  if (!target) {
    target = this;
  }
  target[protoFieldName] = defaultValue;
  if (!dontIncludeGetter) {
    var getterName = "get" + rootName;
    target[getterName] = function() {
      return this[protoFieldName];
    };
    this.__defineGetter__(fieldName, target[getterName]);
  }
  if (!dontIncludeSetter) {
    var setterName = "set" + rootName;
    target[setterName] = (positiveValuesOnly) ? function(integer) {
      this[protoFieldName] = parseFn(integer);
      if (isNaN(this[protoFieldName]) || this[protoFieldName] < 0) {
        this[protoFieldName] = defaultValue;
      }
    } : function(integer) {
      this[protoFieldName] = parseFn(integer);
      if (isNaN(this[protoFieldName])) {
        this[protoFieldName] = defaultValue;
      }
    };
    this.__defineSetter__(fieldName, target[setterName]);
  }
};

Evernote.DefiningMixin.prototype.__defineString__ = function(fieldName,
    defaultValue, dontIncludeGetter, dontIncludeSetter) {
  defaultValue = (defaultValue) ? defaultValue : null;
  var rootName = fieldName.substring(0, 1).toUpperCase()
      + fieldName.substring(1);
  var protoFieldName = "_" + fieldName;
  var target = Evernote.DefiningMixin._getTargetFor(arguments.callee.caller);
  target[protoFieldName] = defaultValue;
  if (!dontIncludeGetter) {
    var getterName = "get" + rootName;
    target[getterName] = function() {
      return this[protoFieldName];
    };
    this.__defineGetter__(fieldName, target[getterName]);
  }
  if (!dontIncludeSetter) {
    var setterName = "set" + rootName;
    target[setterName] = function(string) {
      if (typeof string == 'string') {
        this[protoFieldName] = string;
      } else if (!string) {
        this[protoFieldName] = defaultValue;
      } else {
        this[protoFieldName] = "" + string;
      }
    };
    this.__defineSetter__(fieldName, target[setterName]);
  }
};

Evernote.DefiningMixin.prototype.__defineType__ = function(fieldName, type,
    defaultValue, dontIncludeGetter, dontIncludeSetter) {
  defaultValue = (defaultValue) ? defaultValue : null;
  var protoFieldName = "_" + fieldName;
  var rootName = fieldName.substring(0, 1).toUpperCase()
      + fieldName.substring(1);
  var target = Evernote.DefiningMixin._getTargetFor(arguments.callee.caller);
  target[protoFieldName] = defaultValue;
  if (!dontIncludeGetter) {
    var getterName = "get" + rootName;
    target[getterName] = function() {
      return this[protoFieldName];
    };
    this.__defineGetter__(fieldName, target[getterName]);
  }
  if (!dontIncludeSetter) {
    var setterName = "set" + rootName;
    target[setterName] = function(obj) {
      if (typeof type == 'string' && obj.constructor.name == type) {
        this[protoFieldName] = obj;
      } else if (typeof type == 'function' && obj instanceof type) {
        this[protoFieldName] = obj;
      } else if (!obj) {
        this[protoFieldName] = defaultValue;
      } else {
        throw new Error("Expected "
            + ((typeof type == 'string') ? type : type.name) + " but got "
            + (typeof obj));
      }
    };
    this.__defineSetter__(fieldName, target[setterName]);
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

  Evernote.FileLogger = function FileLogger(type, size, root, success, error) {
    this.__defineString__("root", "/");
    this.__definePositiveInteger__("maxLogSize", 2 * 1024 * 1024);
    this.initialize(type, size, root, success, error);
  };

  Evernote.mixin(Evernote.FileLogger, Evernote.DefiningMixin);

  Evernote.FileLogger.FSA_SIZE = 5 * 1024 * 1024;

  Evernote.FileLogger.prototype._fsa = null;
  Evernote.FileLogger.prototype._sema = null;
  Evernote.FileLogger.prototype._logFile = null;
  Evernote.FileLogger.prototype._logFileEntry = null;

  Evernote.FileLogger.prototype.initialize = function(type, size, root,
      success, error) {
    this.root = root;
    this._sema = Evernote.Semaphore.mutex();
    var self = this;
    var err = function(err) {
      this._sema.signal();
      if (typeof error == 'function') {
        error();
      }
      this.onerror(err);
    };
    var ok = function() {
      if (typeof success == 'function') {
        success(self);
      }
      self._sema.signal();
    };
    var fsaSize = (typeof size == 'number') ? size : this.constructor.FSA_SIZE;
    this._sema.critical(function() {
      self._fsa = new Evernote.FSA(type, fsaSize, function() {
        self._fsa.getCreateDirectory(self.root, function(dirEntry) {
          self._fsa.changeDirectory(dirEntry.fullPath, function(dirEntry) {
            self._fsa.listFiles(dirEntry.fullPath, function(files) {
              Evernote.FSA.sortEntries(files, function(f, cb) {
                f.getMetadata(function(meta) {
                  cb(meta.modificationTime.getTime(), f);
                });
              }, function(a, b) {
                if (a == b) {
                  return 0;
                } else {
                  return (a > b) ? 1 : -1;
                }
              }, function(sortedFiles) {
                if (sortedFiles.length > 0
                    && sortedFiles[sortedFiles.length - 1]) {
                  sortedFiles[sortedFiles.length - 1].file(function(lastFile) {
                    self._logFile = lastFile;
                    self._logFileEntry = sortedFiles[sortedFiles.length - 1];
                    ok();
                  }, err);
                } else {
                  ok();
                }
              });
            }, err);
          }, err);
        }, err);
      }, err);
    });
  };

  Evernote.FileLogger.prototype.onerror = function(err) {
    console.error(err);
  };

  Evernote.FileLogger.formatDateNumber = function(num) {
    if (num < 10) {
      return "0" + num;
    } else {
      return "" + num;
    }
  };

  Evernote.FileLogger.prototype.getNewLogFilename = function() {
    var d = new Date();
    var fname = (d.getMonth() + 1) + "-" + d.getDate() + "-" + d.getFullYear()
        + "_" + Evernote.FileLogger.formatDateNumber(d.getHours()) + "_"
        + Evernote.FileLogger.formatDateNumber(d.getMinutes()) + "_"
        + Evernote.FileLogger.formatDateNumber(d.getSeconds()) + ".log";
    return fname;
  };

  Evernote.FileLogger.prototype.getCurrentLogFilename = function() {
    return (this._logFileEntry) ? this._logFileEntry.name : null;
  };

  Evernote.FileLogger.prototype._getLogFile = function(callback) {
    var self = this;
    if (this._logFileEntry) {
      callback(this._logFileEntry);
    } else {
      this._swapLogFile(callback);
    }
  };

  Evernote.FileLogger.prototype._swapLogFile = function(callback) {
    var self = this;
    // return;
    this._fsa.getCreateFile(this.getNewLogFilename(), function(fileEntry) {
      fileEntry.file(function(file) {
        self._logFile = file;
        self._logFileEntry = fileEntry;
        self._logFileWriter = null;
        self.onlogswap(fileEntry);
        callback(fileEntry);
      }, self.error);
    }, self.onerror);
  };

  Evernote.FileLogger.prototype._getLogFileWriter = function(callback) {
    var self = this;
    if (this._logFileEntry && this._logFileWriter) {
      callback(this._logFileWriter);
    } else {
      this._getLogFile(function(fileEntry) {
        fileEntry.createWriter(function(writer) {
          self._logFileWriter = writer;
          callback(writer);
        });
      }, this.onerror);
    }
  };

  Evernote.FileLogger.prototype.releaseLogFile = function() {
    this._logFileEntry = null;
    this._logFileWriter = null;
  };

  Evernote.FileLogger.prototype.onlogswap = function(fileEntry) {
  };

  Evernote.FileLogger.prototype.listLogFiles = function(success, error) {
    var self = this;
    this._sema.critical(function() {
      self._fsa.listFiles(self._fsa.currentDirectory, function(files) {
        if (typeof success == 'function') {
          success(files);
        }
        self._sema.signal();
      }, function(err) {
        self.onfsaerror();
        if (typeof error == 'function') {
          error(err);
        }
        self._sema.signal();
      });
    });
  };

  Evernote.FileLogger.prototype.log = function(str) {
    var self = this;
    if (this._logFile
        && (this._logFile.fileSize + str.length) >= this.maxLogSize) {
      this._logFile = null;
      this._logFileEntry = null;
      this._logFileWriter = null;
    }
    this._log(str);
  };

  Evernote.FileLogger.prototype.log2 = function(str) {
    var self = this;
    if (!this._logFile
        || (this._logFile.fileSize + str.length) >= this.maxLogSize) {
      this._swapLogFile(function() {
        self._log(str);
      });
    } else {
      this._log(str);
    }
  };

  Evernote.FileLogger.prototype._log = function(str) {
    var self = this;
    this._sema.critical(function() {
      self._getLogFileWriter(function(writer) {
        writer.seek(writer.length);
        writer.onwriteend = function() {
          self._sema.signal();
        };
		var bb = self._fsa.createBlobBuilder();
        bb.append(str + "\n");
        writer.write(bb.getBlob());
      }, self.onerror);
    });
  };

  Evernote.FileLogger.prototype.clear = function() {
    var self = this;
    if (this._logFileEntry) {
      this._logFileEntry.truncate();
    }
  };
})();


/**
 * Chrome specific logger implementation to be used with Chrome extensions
 * 
 * @author pasha
 */
Evernote.FileLoggerImpl = function FileLoggerImpl(logger) {
  this.__defineGetter__("fileLogger", this.getFileLogger);
  this.__defineGetter__("keepFiles", this.getKeepFiles);
  this.__defineSetter__("keepFiles", this.setKeepFiles);
  this.initialize(logger);
};
Evernote.inherit(Evernote.FileLoggerImpl, Evernote.LoggerImpl, true);

Evernote.FileLoggerImpl.prototype.handleLogRemoval = function(request, sender,
    sendRequest) {
  if (typeof request == 'object'
      && request.code == Evernote.Constants.RequestType.LOG_FILE_REMOVED
      && request.message) {
    this.logger.debug("Received notification about a log file being removed");
    var logName = request.message;
    var fileLogger = this.getFileLogger();
    var currentLogName = fileLogger.getCurrentLogFilename();
    this.logger.debug("Comparing removed file with local " + logName + "?="
        + currentLogName);
    if (logName == currentLogName) {
      this.logger.debug("Releasing current log file");
      fileLogger.releaseLogFile();
    }
  }
};

Evernote.FileLoggerImpl.isResponsibleFor = function(navigator) {
  return (navigator.userAgent.toLowerCase().indexOf("chrome/") > 0);
};

Evernote.FileLoggerImpl.LOG_DIRECTORY = "/logs";
Evernote.FileLoggerImpl.FILE_LOGGER_FSA_SIZE = 5 * 1024 * 1024;

Evernote.FileLoggerImpl.prototype._enabled = false;
Evernote.FileLoggerImpl.prototype._keepFiles = 2;

Evernote.FileLoggerImpl.getProtoKeepFiles = function() {
  return this.prototype._keepFiles;
};
Evernote.FileLoggerImpl.setProtoKeepFiles = function(num) {
  this.prototype._keepFiles = parseInt(num);
  if (isNaN(this.prototype._keepFiles) || this.prototype._keepFiles < 0) {
    this.prototype._keepFiles = 0;
  }
};
Evernote.FileLoggerImpl.prototype.getKeepFiles = function() {
  return this._keepFiles;
};
Evernote.FileLoggerImpl.prototype.setKeepFiles = function(num) {
  this._keepFiles = parseInt(num);
  if (isNaN(this._keepFiles) || this._keepFiles < 0) {
    this._keepFiles = 0;
  }
};
Evernote.FileLoggerImpl.prototype.dump = function(obj) {
  this.dir(obj);
};
Evernote.FileLoggerImpl.prototype.dir = function(obj) {
  var str = ">" + this.logger.scopeName + "\n";
  try {
    if (typeof obj == 'object' && obj
        && typeof Evernote[obj.constructor.name] != 'undefined') {
      str += obj.constructor.name;
      str += JSON.stringify(obj.toLOG());
    } else if (typeof obj == 'object' && obj && typeof obj.toLOG == 'function') {
      str += JSON.stringify(obj.toLOG());
    } else {
      str += JSON.stringify(obj);
    }
  } catch (e) {
    str += obj;
  }
  str += "\n";
  str += "<" + this.logger.scopeName;
  this._logToFile(str);
};
Evernote.FileLoggerImpl.prototype.debug = function(str) {
  this._logToFile(str);
};
Evernote.FileLoggerImpl.prototype.info = function(str) {
  this._logToFile(str);
};
Evernote.FileLoggerImpl.prototype.warn = function(str) {
  this._logToFile(str);
};
Evernote.FileLoggerImpl.prototype.error = function(str) {
  this._logToFile(str);
  if (this.logger.isDebugEnabled() && str instanceof Error) {
    this._logToFile(str.stack);
  }
};
Evernote.FileLoggerImpl.prototype.exception = function(str) {
  this._logToFile(str);
  if (this.logger.isDebugEnabled() && str instanceof Error) {
    this._logToFile(str.stack);
  }
};
Evernote.FileLoggerImpl.prototype.clear = function() {
  this.fileLogger.clear();
};
Evernote.FileLoggerImpl.prototype.getFileLogger = function() {
  var self = this;
  if (!this.constructor.prototype._fileLogger) {
    this.constructor.prototype._fileLogger = new Evernote.FileLogger(
        PERSISTENT, this.constructor.FILE_LOGGER_FSA_SIZE,
        this.constructor.LOG_DIRECTORY, function(fileLogger) {
          // upon intialization of FileLogger, let's add an event listener for
        // LOG_FILE_REMOVED message so that we can release log files from
        // FileLogger
        chrome.extension.onRequest
            .addListener(function(request, sender, sendRequest) {
              if (typeof request == 'object'
                  && request.code == Evernote.Constants.RequestType.LOG_FILE_REMOVED
                  && request.message) {
                self.logger
                    .debug("Received notification about a log file being removed");
                var logName = request.message;
                var currentLogName = fileLogger.getCurrentLogFilename();
                self.logger.debug("Comparing removed file with local "
                    + logName + "?=" + currentLogName);
                if (logName == currentLogName) {
                  self.logger.debug("Releasing current log file");
                  fileLogger.releaseLogFile();
                }
              }
              sendRequest( {});
            });
      });
    this.constructor.prototype._fileLogger.maxLogSize = 2 * 1024 * 1024;
    this.constructor.prototype._fileLogger.onlogswap = function(newLogFile) {
      self.constructor.prototype._fileLogger
          .listLogFiles(function(fileEntries) {
            var oldAge = new Date(Date.now()
                - (self._keepFiles * 24 * 60 * 60 * 1000));
            var chainedDeleter = function(fileArray, callback, index) {
              index = (index) ? index : 0;
              if (index >= fileArray.length) {
                if (typeof callback == 'function') {
                  callback();
                }
              } else {
                fileArray[index].file(function(f) {
                  LOG.debug("Checking if " + f.name + " is older than "
                      + oldAge.toString());
                  LOG.debug(f.lastModifiedDate.toString());
                  if (f.lastModifiedDate.isBefore(oldAge)
                      && f.name != newLogFile.name) {
                    LOG.debug("Removing old log file: " + f.name + " -> "
                        + fileArray[index].name);
                    fileArray[index].remove(function() {
                      chainedDeleter(fileArray, callback, ++index);
                    });
                  } else {
                    chainedDeleter(fileArray, callback, ++index);
                  }
                });
              }
            };
            chainedDeleter(fileEntries, function() {
              chrome.extension.sendRequest(new Evernote.RequestMessage(
                  Evernote.Constants.RequestType.LOG_FILE_SWAPPED));
            });
          });
    };
  }
  return this.constructor.prototype._fileLogger;
};
Evernote.FileLoggerImpl.prototype._logToFile = function(str) {
  if (this.enabled) {
    this.fileLogger.log(str);
  }
};

/*
 * Evernote.LocalStore
 * 
 * Created by Pavel Skaldin on 3/31/10
 * Copyright 2010 Evernote Corp. All rights reserved.
 */

/**
 * Evernote.LocalStore provides single interface for locally storing key-value data on the client.
 * Currently there are two implementation:
 *   Evernote.LocalStore.DEFAULT_IMPL - which stores data inside an object
 *   Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL - which utilized HTML5's localStorage feature
 *   
 * Evernote.LocalStore requires that each instance has a name to distinguish it from other stores.
 * It provides the following interface:
 *   get(key) - to retrieve value associated with given key
 *   put(key, value) - to store key-value association
 *   remove(key) - to remove stored key-value association
 *   clear() - to remove all stored key-value associations
 *   getLength() - returns total number of stored associations
 */
Evernote.LocalStore = function LocalStore(name, impl) {
  this.initialize(name, impl);
  this.__defineGetter__("length", this.getLength);
};
Evernote.LocalStore.prototype.initialize = function(name, impl) {
  if (typeof name == 'string')
    this.storeName = name;
  else
    this.storeName = Evernote.LocalStore.DEFAULT_STORE_NAME;
  this.impl = (impl) ? impl : new Evernote.LocalStore.DEFAULT_IMPL();
  this.impl.store = this;
};
Evernote.LocalStore.prototype.get = function(key) {
  return this.impl.get(key);
};

Evernote.LocalStore.prototype.put = function(key, value) {
  this.impl.put(key, value);
};
Evernote.LocalStore.prototype.remove = function(key) {
  this.impl.remove(key);
};
Evernote.LocalStore.prototype.clear = function() {
  this.impl.clear();
};
Evernote.LocalStore.prototype.getLength = function() {
  return this.impl.length;
};
Evernote.LocalStore.DEFAULT_STORE_NAME = "Evernote.LocalStore";

/**
 * Default object based storage implementation
 */
Evernote.LocalStore.DEFAULT_IMPL = function() {
  this.initialize();
  this.__defineGetter__("length", this.getLength);
};
Evernote.LocalStore.DEFAULT_IMPL.prototype.store = null;
Evernote.LocalStore.DEFAULT_IMPL.prototype._cache = null;
Evernote.LocalStore.DEFAULT_IMPL.prototype._countDelta = 0;
Evernote.LocalStore.DEFAULT_IMPL.prototype.initialize = function() {
  this._cache = {};
  this._countDelta = 0;
  for ( var i = 0; i < this._cache.length; i++) {
    this._countDelta++;
  }
};
Evernote.LocalStore.DEFAULT_IMPL.prototype.clear = function() {
  this.initialize();
};
Evernote.LocalStore.DEFAULT_IMPL.prototype.get = function(key) {
  return this._cache[key];
};
Evernote.LocalStore.DEFAULT_IMPL.prototype.put = function(key, value) {
  this._cache[key] = value;
};
Evernote.LocalStore.DEFAULT_IMPL.prototype.remove = function(key) {
  if (typeof this._cache[key] != 'undefined') {
    delete (this._cache[key]);
  }
};
Evernote.LocalStore.DEFAULT_IMPL.prototype.getLength = function() {
  var l = 0;
  for ( var i in this._cache) {
    l++;
  }
  return l - this._countDelta;
};

/**
 * Default storage utilizing HTML5's localStorage object. Simply pass
 * localStorage object when instantiating this implementation. This localStorage
 * object is usually available as window.localStorage.
 */
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL = function(localStorage) {
  this.initialize(localStorage);
  this.__defineGetter__("length", this.getLength);
};
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL.prototype.store = null;
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL.prototype._cache = null;
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL.prototype.initialize = function(localStorage) {
  this._cache = localStorage;
};
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL.prototype.clear = function() {
  this._cache.clear();
};
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL.prototype.get = function(key) {
  var value = this._cache.getItem(key);
  if (value)
    return this.unmarshall(value);
  else
    return null;
};
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL.prototype.put = function(key, value) {
  this._cache.setItem(key, this.marshall(value));
};
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL.prototype.remove = function(key) {
  this._cache.removeItem(key);
};
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL.prototype.getLength = function() {
  return this._cache.length;
};
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL.prototype.marshall = function(data) {
  return JSON.stringify(data);
};
Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL.prototype.unmarshall = function(data) {
  return JSON.parse(data);
};

(function() {
  var LOG = null;
  Evernote.FSA = function FSA(type, size, successCallback, errorCallback) {
    LOG = Evernote.Logger.getInstance();
    this.initialize(type, size, successCallback, errorCallback);
  };

  Evernote.FSA.prototype._type = null;
  Evernote.FSA.prototype._size = 0;
  Evernote.FSA.prototype._fsys = null;
  Evernote.FSA.prototype._sema = null;
  Evernote.FSA.prototype._currentDirectory = null;

  Evernote.FSA.prototype.initialize = function(type, size, successCallback,
      errorCallback) {
    var self = this;
    this.__defineGetter__("root", this.getRoot);
    this.__defineGetter__("currentDirectory", this.getCurrentDirectory);
    this._type = parseInt(type);
    if (isNaN(this._type) || this._type < 0) {
      this._type = 0;
    }
    this._size = parseInt(size);
    if (isNaN(this._size) || this._size < 0) {
      this._size = 0;
    }
    this._sema = Evernote.Semaphore.mutex();
    this._sema.critical(function() {
      self.requestFileSystem(this._type, this._size, function(fsObj) {
        LOG.debug("Successful request for FileSystem");
        self._fsys = fsObj;
        self._sema.signal();
        if (typeof successCallback == 'function') {
          successCallback(fsObj);
        }
      }, function(e) {
        LOG.error("Failed request for FileSystem: " + e.code);
        self._sema.signal();
        if (typeof errorCallback == 'function') {
          errorCallback(e);
        }
      });
    });
  };
  Evernote.FSA.prototype.requestFileSystem = function(type, size, success,
      error) {
    if (typeof window.requestFileSystem == 'function') {
      window.requestFileSystem(type, size, success, error);
    } else if (typeof window.webkitRequestFileSystem == 'function') {
      window.webkitRequestFileSystem(type, size, success, error);
    } else {
      throw new Evernote.FSAError(
          Evernote.FSAError.NO_SUITABLE_FILESYSTEM_REQUESTOR);
    }
  };
  Evernote.FSA.prototype.createBlobBuilder = function() {
    if (typeof BlobBuilder == 'function') {
      return new BlobBuilder();
    } else if (typeof WebKitBlobBuilder == 'function') {
      return new WebKitBlobBuilder();
    } else {
      throw new Evernote.FSAError(Evernote.FSAError.NO_SUITABLE_BLOB_BUILDER);
    }
  };
  Evernote.FSA.prototype.getRoot = function() {
    if (this._fsys) {
      return this._fsys.root;
    } else {
      return undefined;
    }
  };
  Evernote.FSA.prototype.dirname = function(path) {
    var parts = path.split("/");
    parts.splice(-1);
    return parts.join("/");
  };
  Evernote.FSA.prototype.getCurrentDirectory = function() {
    if (!this._currentDirectory) {
      this._currentDirectory = this.root;
    }
    return this._currentDirectory;
  };
  Evernote.FSA.prototype.changeDirectory = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.changeDirectory: " + path);
    var self = this;
    this._getDirectory(path, null, function(dir) {
      LOG.debug("Successfully changed directory to: " + dir.fullPath);
      self._currentDirectory = dir;
      if (typeof successCallback == 'function') {
        successCallback.apply(self, arguments);
      }
    }, function(e) {
      LOG.error("Error changing directory to: " + path);
      if (typeof errorCallback == 'function') {
        errorCallback.apply(self, arguments);
      }
    });
  };
  Evernote.FSA.prototype.createDirectory = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.createDirectory: " + path);
    this._getDirectory(path, {
      create : true,
      exclusive : true
    }, successCallback, errorCallback);
  };
  Evernote.FSA.prototype.getCreateDirectory = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.getCreateDirectory: " + path);
    this._getDirectory(path, {
      create : true
    }, successCallback, errorCallback);
  };
  Evernote.FSA.prototype.ensureDirectory = function(path, successCallback,
      errorCallback, startAt, curDir) {
    LOG.debug("FSA.ensureDirectory");
    var self = this;
    var parts = (path instanceof Array) ? path : path.split("/");
    var r = this.currentDirectory;
    if (!startAt || startAt < 0) {
      startAt = 0;
    }
    while (startAt <= (parts.length - 1) && !parts[startAt]) {
      r = this.root;
      startAt++;
    }
    if (startAt >= parts.length) {
      if (typeof successCallback == 'function') {
        successCallback(r);
        return;
      }
    }
    if (!curDir) {
      curDir = this.currentDirectory;
    }
    LOG.debug("Attempting to retrieve/create directory: "
        + parts.slice(startAt, startAt + 1));
    this.getCreateDirectory(parts.slice(startAt, startAt + 1), function(dir) {
      if (startAt < (parts.length - 1)) {
        self._currentDirectory = dir;
        self.ensureDirectory(parts, successCallback, errorCallback,
            (startAt + 1), curDir);
      } else {
        // TODO: properly restore orig dir
        if (typeof successCallback == 'function') {
          successCallback(dir);
        }
        self._currentDirectory = curDir;
      }
    }, function(e) {
      LOG.debug("Failed to ensure existence of directory: " + parts.join("/")
          + "(" + e.code + ")");
      self._currentDirectory = curDir;
      if (typeof errorCallback == 'function') {
        errorCallback.apply(self, arguments);
      }
    });
  };
  Evernote.FSA.prototype.getDirectory = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.getDirectory: " + path);
    this._getDirectory(path, {
      create : false
    }, successCallback, errorCallback);
  };
  Evernote.FSA.prototype._getDirectory = function(path, flags, successCallback,
      errorCallback) {
    LOG.debug("FSA._getDirectory: " + path);
    var self = this;
    this._sema.critical(function() {
      self.currentDirectory.getDirectory(path, flags, function(dir) {
        LOG.debug("Successfully obtained directory entry: " + dir.fullPath);
        self._sema.signal();
        if (typeof successCallback == 'function') {
          successCallback.apply(self, arguments);
        }
      }, function(e) {
        LOG.error("Failed to obtain directory entry for: " + path + "("
            + e.code + ")");
        self._sema.signal();
        if (typeof errorCallback == 'function') {
          errorCallback.apply(self, arguments);
        }
      });
    });
  };
  Evernote.FSA.prototype.list = function(dir, success, error) {
    LOG.debug("FSA.listDirectory");
    var self = this;
    if (typeof dir == 'string') {
      this._getDirectory(dir, null, function(dirEntry) {
        self.list(dirEntry, success, error);
      }, error);
      return;
    }
    if (!dir) {
      dir = this.currentDirectory;
    }
    var reader = dir.createReader();
    reader.readEntries(success, error);
  };
  Evernote.FSA.prototype.listFiles = function(dir, success, error) {
    LOG.debug("FSA.listFiles");
    this.list(dir, function(entries) {
      if (typeof success == 'function') {
        var files = [];
        for ( var i = 0; i < entries.length; i++) {
          if (entries[i].isFile) {
            files.push(entries[i]);
          }
        }
        success(files);
      }
    }, error);
  };
  Evernote.FSA.prototype.listDirectories = function(dir, success, error) {
    LOG.debug("FSA.listDirectories");
    this.list(dir, function(entries) {
      if (typeof success == 'function') {
        var dirs = [];
        for ( var i = 0; i < entries.length; i++) {
          if (!entries[i].isFile) {
            dirs.push(entries[i]);
          }
        }
        success(dirs);
      }
    }, error);
  };
  Evernote.FSA.prototype.createFile = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.createFile: " + path);
    var self = this;
    this.ensureDirectory(this.dirname(path), function(d) {
      self._getFile(path, {
        create : true,
        exclusive : true
      }, successCallback, errorCallback);
    }, errorCallback);
  };
  Evernote.FSA.prototype.emptyDirectory = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.emptyDirectory: " + path);
    var self = this;
    this._getDirectory(path, null, function(dir) {
      dir.removeRecursively(function() {
        self.createDirectory(path, successCallback, errorCallback);
      }, errorCallback);
    }, errorCallback);
  };
  Evernote.FSA.prototype.removeFile = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.createFile: " + path);
    var self = this;
    this.ensureDirectory(this.dirname(path), function(d) {
      self._getFile(path, {
        create : false,
        exclusive : true
      }, function(fileEntry) {
        fileEntry.remove(successCallback, errorCallback);
      }, errorCallback);
    }, errorCallback);
  };
  Evernote.FSA.prototype.getFile = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.getFile: " + path);
    this._getFile(path, null, successCallback, errorCallback);
  };
  Evernote.FSA.prototype.getCreateFile = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.getCreateFile: " + path);
    var self = this;
    this.ensureDirectory(this.dirname(path), function(d) {
      self._getFile(path, {
        create : true,
        exclusive : false
      }, successCallback, errorCallback);
    }, errorCallback);
  };
  Evernote.FSA.prototype._getFile = function(path, flags, successCallback,
      errorCallback) {
    LOG.debug("FSA._getFile: " + path);
    var self = this;
    this._sema.critical(function() {
      self.currentDirectory.getFile(path, flags, function() {
        LOG.debug("Successfully retrieved file: " + path);
        self._sema.signal();
        if (typeof successCallback == 'function') {
          successCallback.apply(self, arguments);
        }
      }, function(e) {
        LOG.error("Failed to retreive file: " + path + "(" + e.code + ")");
        self._sema.signal();
        if (typeof errorCallback == 'function') {
          errorCallback.apply(self, arguments);
        }
      });
    });
  };
  Evernote.FSA.prototype.writeFile = function(path, content, successCallback,
      errorCallback) {
    LOG.debug("FSA.writeFile: " + path);
	var self = this;
    this.getCreateFile(path, function(fileEntry) {
      fileEntry.createWriter(function(writer) {
        var bb = self.createBlobBuilder();
        bb.append(content);
        var ontruncateend = function() {
          writer.onwriteend = onwriteend;
          LOG.debug("Writing blob to file [" + writer.readyState + "]");
          writer.write(bb.getBlob());
        };
        var onwriteend = function() {
          LOG.debug("Finished writing file: " + path);
          if (typeof successCallback == 'function') {
            successCallback(writer, fileEntry);
          }
        };
        writer.onwriteend = ontruncateend;
        LOG.debug("Truncating file [" + writer.readyState + "]");
        writer.truncate(0);
      }, errorCallback);
    }, errorCallback);
  };
  Evernote.FSA.prototype.appendFile = function(path, content, successCallback,
      errorCallback) {
    LOG.debug("FSA.appendFile: " + path);
	var self = this;
    this.getCreateFile(path, function(fileEntry) {
      fileEntry.createWriter(function(writer) {
        var bb = self.createBlobBuilder();
        bb.append(content);
        writer.onwriteend = function() {
          LOG.debug("Finished writing file: " + path);
          if (typeof successCallback == 'function') {
            successCallback(writer, fileEntry);
          }
        };
        writer.seek();
        writer.write(bb.getBlob());
      }, errorCallback);
    }, errorCallback);
  };
  Evernote.FSA.prototype.readTextFile = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.readTextFile: " + path);
    this.createFileReader(path, function(reader, file, fileEntry) {
      reader.onloadend = function() {
        LOG.debug("Finished reading file: " + path);
        if (typeof successCallback == 'function') {
          successCallback(reader, fileEntry);
        }
      };
      reader.readAsText(file);
    }, errorCallback);
  };
  Evernote.FSA.prototype.readTextFromFile = function(file, successCallback,
      errorCallback) {
    var reader = new FileReader();
    reader.onloadend = function() {
      LOG.debug("Finished reading file: " + file.name);
      if (typeof successCallback == 'function') {
        successCallback(reader, file);
      }
    };
    reader.onerror = errorCallback;
    reader.readAsText(file);
  };
  Evernote.FSA.prototype.createFileReader = function(path, successCallback,
      errorCallback) {
    LOG.debug("FSA.createFileReader: " + path);
    var self = this;
    this.getFile(path, function(fileEntry) {
      fileEntry.file(function(file) {
        var reader = new FileReader();
        if (typeof successCallback == 'function') {
          successCallback(reader, file, fileEntry);
        }
      }, errorCallback);
    }, errorCallback);
  };
  Evernote.FSA.prototype.ls = function(dir) {
    var _dir = (typeof dir == 'string') ? dir : this.currentDirectory.name;
    var err = function(e) {
      console.error(e);
    };
    var dateToStr = function(date) {
      return date.toString().split(" ").slice(1, 5).join(" ");
    };
    var printFileEntry = function(entry) {
      entry.file(function(f) {
        console.log("f " + f.fileSize + " " + dateToStr(f.lastModifiedDate)
            + " " + f.fileName);
      });
    };
    var printDirEntry = function(entry) {
      entry.getMetadata(function(meta) {
        console.log("d " + " " + dateToStr(meta.modificationTime) + " "
            + entry.name);
      });
    };
    this._getDirectory(_dir, {
      create : false,
      exclusive : false
    }, function(dir) {
      dir.createReader().readEntries(function(entries) {
        console.log(_dir);
        console.log("total " + entries.length);
        for ( var i = 0; i < entries.length; i++) {
          if (entries[i].isDirectory) {
            printDirEntry(entries[i]);
          } else if (entries[i].isFile) {
            printFileEntry(entries[i]);
          }
        }
      }, err);
    }, err);
  };
  /**
   * Maps given array of FileEntry's or DirectoryEntry's, or an EntryArray. The
   * keys of the map are determined by mapFn function. When mapping is complete -
   * callback is called with the map as the only arguments.
   * 
   * mapFn will be called with two arguments - first is the FileEntry or
   * DirectoryEntry, and the second is a callback that needs to be called from
   * within mapFn, passing that callback two arguments - first is the key and
   * second is the file that corresponds to that key.
   * 
   * Example mapping files by their modification time.
   * 
   * <pre>
   * fsa.listFiles(&quot;/foo&quot;, function(files) {
   *   Evernote.FSA.mapEntries(files, function(file, cb) {
   *     file.getMetadata(function(meta) {
   *       cb(meta.modificationTime.getTime(), file);
   *     });
   *   }, function(map) {
   *     console.dir(map)
   *   })
   * })
   * </pre>
   * 
   * @param entries
   * @param mapFn
   * @param callback
   * @return
   */
  Evernote.FSA.mapEntries = function(entries, mapFn, callback) {
    var sema = Evernote.Semaphore.mutex();
    var map = {};
    var x = 0;
    for ( var i = 0; i < entries.length; i++) {
      sema.critical(function() {
        var file = entries[x];
        mapFn(file, function(key, val) {
          map[key] = val;
          x++;
          sema.signal();
        });
      });
    }
    sema.critical(function() {
      callback(map);
    });
  };

  /**
   * Sorts given array of FileEntry's or DirectoryEntry's, or an EntryArray, and
   * passes the resulting array of entries to the given callback.
   * 
   * Sorting is done by first constructing a map of keys to entries using mapFn
   * function. If mapFn is not given, the default behavior will be to map
   * entries to their file names.
   * 
   * After the map is created, the given entries are sorted based on their
   * corresponsing keys in that map using sortFn function. If sortFn is not
   * supplied, the default behavior will be to sort by keys in an ascending
   * order - similarly to Array.prototype.sort.
   * 
   * Once the sorting is done, the resulting Array of entries will be passed to
   * the given callback function.
   * 
   * Example sorting entries by their modification time in reverse order.
   * 
   * <pre>
   * fsa.listFiles(&quot;/foo&quot;, function(files) {
   *   Evernote.FSA.sortEntries(files, function(f, cb) {
   *     f.getMetadata(function(meta) {
   *       cb(meta.modificationTime.getTime(), f);
   *     });
   *   }, function(a, b, fileArray, fileMap) {
   *     if (a == b) {
   *       return 0;
   *     } else if (a &gt; b) {
   *       return -1;
   *     } else {
   *       return 1;
   *     }
   *   }, function(filesArray) {
   *     console.dir(filesArray);
   *   });
   * })
   * </pre>
   * 
   * @param entries
   * @param mapFn
   * @param sortFn
   * @param callback
   * @return
   */
  Evernote.FSA.sortEntries = function(entries, mapFn, sortFn, callback) {
    var entriesArray = [];
    if (entries instanceof Array) {
      entriesArray = entries;
    } else if (entries.length > 0) {
      for ( var i = 0; i < entries.length; i++) {
        entriesArray.push(entries[i]);
      }
    }
    if (typeof mapFn != 'function') {
      mapFn = function(f, cb) {
        cb(f.name, f);
      };
    }
    if (typeof sortFn != 'function') {
      sortFn = function(a, b) {
        if (a == b) {
          return 0;
        } else {
          return (a > b) ? 1 : -1;
        }
      };
    }
    this.mapEntries(entries, mapFn, function(map) {
      entriesArray.sort(function(a, b) {
        var aKey = null;
        var bKey = null;
        for ( var i in map) {
          if (map[i] == a) {
            aKey = i;
          } else if (map[i] == b) {
            bKey = i;
          }
        }
        return sortFn(aKey, bKey, entriesArray, map);
      });
      callback(entriesArray);
    });
  };

  Evernote.FSAError = function(code) {
    this.code = parseInt(code);
    if (isNaN(this.code)) {
      this.code = Evernote.FSAError.UNKNOWN_ERROR;
    }
  };
  Evernote.inherit(Evernote.FSAError, Error);
  Evernote.FSAError.UNKNOWN_ERROR = 0;
  Evernote.FSAError.NO_SUITABLE_FILESYSTEM_REQUESTOR = 1;
  Evernote.FSAError.NO_SUITABLE_BLOB_BUILDER = 2;
  Evernote.FSAError.prototype.code = Evernote.FSAError.UNKNOWN_ERROR;
  Evernote.FSAError.prototype.valueOf = function() {
    return this.code;
  };
  Evernote.FSAError.prototype.toString = function() {
    return "Evernote.FSAError: " + this.code;
  };
})();


/*
 * Evernote
 * EDAMResponse
 * 
 * Created by Pavel Skaldin on 2/23/10
 * Copyright 2010 Evernote Corp. All rights reserved.
 */

/** ************** Server Responses *************** */
(function() {
  var LOG = null;
  Evernote.EDAMErrorCode = {
    UNKNOWN : 1,
    BAD_DATA_FORMAT : 2,
    PERMISSION_DENIED : 3,
    INTERNAL_ERROR : 4,
    DATA_REQUIRED : 5,
    LIMIT_REACHED : 6,
    QUOTA_REACHED : 7,
    INVALID_AUTH : 8,
    AUTH_EXPIRED : 9,
    DATA_CONFLICT : 10,
    ENML_VALIDATION : 11,
    SHARD_UNAVAILABLE : 12
  };

  Evernote.EDAMResponseErrorCode = {
    UNKNOWN : 1,
    INVALID_RESPONSE : 2
  };

  Evernote.EDAMResponse = function EDAMResponse(data) {
    LOG = Evernote.Logger.getInstance();
    this.initialize(data);
  };
  Evernote.EDAMResponse.TYPE_UNKNOWN = 0;
  Evernote.EDAMResponse.TYPE_ERROR = 1;
  Evernote.EDAMResponse.TYPE_TEXT = 2;
  Evernote.EDAMResponse.TYPE_HTML = 3;
  Evernote.EDAMResponse.TYPE_OBJECT = 4;

  Evernote.EDAMResponse.fromObject = function(obj) {
    if (obj instanceof Evernote.EDAMResponse) {
      return obj;
    } else {
      return new Evernote.EDAMResponse(obj);
    }
  };

  Evernote.EDAMResponse.prototype._result = null;
  Evernote.EDAMResponse.prototype._errors = null;
  Evernote.EDAMResponse.prototype._type = Evernote.EDAMResponse.TYPE_UNKNOWN;
  Evernote.EDAMResponse.prototype.initialize = function(data) {
    this.__defineGetter__("errors", this.getErrors);
    this.__defineSetter__("errors", this.setErrors);
    this.__defineGetter__("result", this.getResult);
    this.__defineSetter__("result", this.setResult);
    this.__defineGetter__("type", this.getType);
    this.__defineSetter__("type", this.setType);
    if (typeof data == 'object'
        && typeof data[Evernote.EvernoteRemote.RESPONSE_ERROR_KEY] != 'undefined'
        && data[Evernote.EvernoteRemote.RESPONSE_ERROR_KEY]) {
      this.errors = data[Evernote.EvernoteRemote.RESPONSE_ERROR_KEY];
    }
    if (typeof data == 'object'
        && typeof data[Evernote.EvernoteRemote.RESPONSE_RESULT_KEY] != 'undefined'
        && data[Evernote.EvernoteRemote.RESPONSE_RESULT_KEY]) {
      this.result = data[Evernote.EvernoteRemote.RESPONSE_RESULT_KEY];
    }
  };
  Evernote.EDAMResponse.prototype.isEmpty = function() {
    return (this.result == null && this.errors == null);
  };
  Evernote.EDAMResponse.prototype.isError = function() {
    return (this.errors != null);
  };
  Evernote.EDAMResponse.prototype.isResult = function() {
    return (this.result != null);
  };
  Evernote.EDAMResponse.prototype.addError = function(e) {
    if (this._errors == null)
      this._errors = new Array();
    this._errors.push(e);
  };
  Evernote.EDAMResponse.prototype.setErrors = function(errors) {
    if (errors == null || typeof errors == 'undefined')
      this._errors = null;
    else
      this._errors = (errors instanceof Array) ? errors : [ errors ];
  };
  Evernote.EDAMResponse.prototype.getErrors = function() {
    return this._errors;
  };
  Evernote.EDAMResponse.prototype.hasValidationErrors = function() {
    return this.hasErrorClass(Evernote.ValidationError);
  };
  Evernote.EDAMResponse.prototype.hasExceptions = function() {
    return this.hasErrorClass(Evernote.Exception);
  };
  Evernote.EDAMResponse.prototype.hasErrorClass = function(constructor) {
    if (this.isError()) {
      for ( var i = 0; i < this.errors.length; i++) {
        if (this._errors[i] instanceof constructor)
          return true;
      }
    }
    return false;
  };
  Evernote.EDAMResponse.prototype.hasErrorCode = function(errorCode) {
    if (this.isError()) {
      for ( var i = 0; i < this._errors.length; i++) {
        if (this._errors[i].errorCode == errorCode)
          return true;
      }
    }
    return false;
  };
  Evernote.EDAMResponse.prototype.hasErrorCodeWithParameter = function(
      errorCode, parameter) {
    if (this.isError()) {
      for ( var i = 0; i < this._errors.length; i++) {
        if (this._errors[i].errorCode == errorCode
            && typeof this._errors[i].parameter != 'undefined'
            && this._errors[i].parameter == parameter) {
          return true;
        }
      }
    }
    return false;
  };
  Evernote.EDAMResponse.prototype.isMissingAuthTokenError = function() {
    return this.hasErrorCodeWithParameter(Evernote.EDAMErrorCode.DATA_REQUIRED,
        "authenticationToken")
        || this.hasErrorCode(Evernote.EDAMErrorCode.PERMISSION_DENIED);
  };
  Evernote.EDAMResponse.prototype.isAuthTokenExpired = function() {
    return this.hasErrorCode(Evernote.EDAMErrorCode.AUTH_EXPIRED);
  };
  Evernote.EDAMResponse.prototype.hasAuthenticationError = function() {
    return this.isMissingAuthTokenError() || this.isAuthTokenExpired();
  };
  Evernote.EDAMResponse.prototype.isInvalidAuthentication = function() {
    return this.hasErrorCode(Evernote.EDAMErrorCode.INVALID_AUTH);
  };
  Evernote.EDAMResponse.prototype.getErrorsByCode = function(errorCode, limit) {
    return this.getErrorsByField(Evernote.Exception.ERROR_CODE_FIELD,
        errorCode, limit);
  };
  Evernote.EDAMResponse.prototype.getErrorsByClass = function(constructor,
      limit) {
    return this.getErrorsByField(Evernote.Exception.CLASS_FIELD,
        (typeof constructor == 'string') ? constructor
            : constructor[Evernote.Exception.CLASS_FIELD], limit);
  };
  Evernote.EDAMResponse.prototype.getErrorsByField = function(fieldName,
      fieldValue, limit) {
    var found = new Array();
    if (this.isError()) {
      for ( var i = 0; i < this._errors.length; i++) {
        if (typeof this._errors[i][fieldName] != 'undefined'
            && this._errors[i][fieldName] == fieldValue) {
          found.push(this._errors[i]);
          if (typeof limit == 'number' && found.length >= limit)
            break;
        }
      }
    }
    return (found.length == 0) ? null : found;
  };
  Evernote.EDAMResponse.prototype.selectErrors = function(fn) {
    var selected = new Array();
    if (typeof fn == 'function' && this.isError()) {
      for ( var i = 0; i < this._errors.length; i++) {
        if (fn(this._errors[i]))
          selected.push(this._errors[i]);
      }
    }
    return (selected.length == 0) ? null : selected;
  };
  Evernote.EDAMResponse.prototype.getResult = function() {
    return this._result;
  };
  Evernote.EDAMResponse.prototype.setResult = function(result) {
    this._result = result;
  };
  Evernote.EDAMResponse.prototype.getType = function() {
    return this._type;
  };
  Evernote.EDAMResponse.prototype.setType = function(type) {
    this._type = parseInt(type);
  };
  Evernote.EDAMResponse.prototype.toString = function() {
    return "Evernote.EDAMResponse (" + this.type + ") "
        + ((this.isError()) ? "ERROR" : "RESULT");
  };
  Evernote.EDAMResponse.createFrom = function(data, resultTransform) {
    LOG = LOG || Evernote.chromeExtension.getLogger(Evernote.EDAMResponse);
    LOG.debug("Evernote.EDAMResponse.createFrom");
    var response = new Evernote.EDAMResponse();
    // Check for errors
    if (typeof data[Evernote.EvernoteRemote.RESPONSE_ERROR_KEY] == 'object'
        && data[Evernote.EvernoteRemote.RESPONSE_ERROR_KEY] != null) {
      var errors = (data[Evernote.EvernoteRemote.RESPONSE_ERROR_KEY] instanceof Array) ? data[Evernote.EvernoteRemote.RESPONSE_ERROR_KEY]
          : [ data[Evernote.EvernoteRemote.RESPONSE_ERROR_KEY] ];
      for ( var i = 0; i < errors.length; i++) {
        if (typeof errors[i] == 'object'
            && typeof errors[i][Evernote.EvernoteRemote.CLASS_IDENTIFIER] == 'string') {
          var eClass = Evernote.EvernoteError
              .responsibleConstructor(errors[i][Evernote.EvernoteRemote.CLASS_IDENTIFIER]);
          if (typeof eClass == 'function') {
            var e = new eClass(errors[i]);
            LOG.debug("Classifiable error: " + e.toString());
            response.addError(e);
          } else {
            LOG.debug("Generic error");
            response.addError(new Evernote.Exception(errors[i]));
          }
        } else if (typeof errors[i] == 'object') {
          LOG.debug("Non-classifiable exception");
          response.addError(new Evernote.Exception(errors[i]));
        } else if (errors[i] != null) {
          LOG.debug("Non-classifiable error");
          response.addError(new Error(errors[i]));
        }
      }
      response.type = Evernote.EDAMResponse.TYPE_ERROR;
    }
    // check for result
    else if ((typeof data[Evernote.EvernoteRemote.RESPONSE_RESULT_KEY] == 'object' && data[Evernote.EvernoteRemote.RESPONSE_RESULT_KEY] != null)
        || typeof data[Evernote.EvernoteRemote.RESPONSE_RESULT_KEY] == 'string'
        || typeof data[Evernote.EvernoteRemote.RESPONSE_RESULT_KEY] == 'number'
        || typeof data[Evernote.EvernoteRemote.RESPONSE_RESULT_KEY] == 'boolean') {
      if (typeof resultTransform == 'function') {
        LOG.debug("Transforming and setting response result");
        response.result = resultTransform(data[Evernote.EvernoteRemote.RESPONSE_RESULT_KEY]);
      } else {
        LOG.debug("Setting response result as-is");
        response.result = data[Evernote.EvernoteRemote.RESPONSE_RESULT_KEY];
      }
      if (typeof response.result == 'object' && response.result != null) {
        response.type = Evernote.EDAMResponse.TYPE_OBJECT;
      } else if (typeof response.result == 'string'
          && response.result.match(/<[^>]+>/)) {
        response.type = Evernote.EDAMResponse.TYPE_HTML;
      } else if (typeof response.result != null) {
        response.type = Evernote.EDAMResponse.TYPE_TEXT;
      }
    } else {
      LOG.debug("Invalid response data");
      LOG.debug(">>> " + JSON.stringify(data));
      throw new Evernote.EDAMResponseException(
          Evernote.EDAMResponseErrorCode.INVALID_RESPONSE);
    }
    return response;
  };
})();

/*
 * Evernote
 * EvernoteMultiPartForm
 * 
 * Created by Pavel Skaldin on 2/23/10
 * Copyright 2010 Evernote Corp. All rights reserved.
 */
/** ************** Evernote.EvernoteMultiPartForm *************** */
Evernote.EvernoteMultiPartForm = function EvernoteMultiPartForm(data) {
  this.__defineGetter__("data", this.getData);
  this.__defineSetter__("data", this.setData);
  this.initialize(data);
};
Evernote.EvernoteMultiPartForm.CONTENT_TYPE = "multipart/form-data";
Evernote.EvernoteMultiPartForm.BOUNDARY_MARK = "--";
Evernote.EvernoteMultiPartForm.BOUNDARY_PREFIX = "----EvernoteFormBoundary";
Evernote.EvernoteMultiPartForm.HEADER_SEPARATOR = "; ";
Evernote.EvernoteMultiPartForm.HEADER_BOUNDARY = "boundary";
Evernote.EvernoteMultiPartForm.CR = "\r\n";
Evernote.EvernoteMultiPartForm.createBoundary = function() {
  return this.BOUNDARY_PREFIX + (new Date().getTime());
};
Evernote.EvernoteMultiPartForm.prototype._data = null;
Evernote.EvernoteMultiPartForm.prototype.boundary = null;
Evernote.EvernoteMultiPartForm.prototype.initialize = function(data) {
  this.boundary = this.constructor.createBoundary();
  this.data = data;
};
Evernote.EvernoteMultiPartForm.prototype.setData = function(data) {
  if (typeof data == 'object') {
    this._data = data;
  }
};
Evernote.EvernoteMultiPartForm.prototype.getData = function() {
  return this._data;
};
Evernote.EvernoteMultiPartForm.prototype.getContentTypeHeader = function() {
  return this.constructor.CONTENT_TYPE + this.constructor.HEADER_SEPARATOR
      + this.constructor.HEADER_BOUNDARY + "=" + this.boundary;
};
Evernote.EvernoteMultiPartForm.prototype.toJSON = function() {
  return {
    contentType : this.getContentTypeHeader(),
    boundary : this.boundary,
    data : this.data
  };
};
Evernote.EvernoteMultiPartForm.prototype.toString = function() {
  var str = "";
  if (this._data) {
    for ( var i in this._data) {
      if (this._data[i] == null || (this._data[i] + "").length == 0) {
        continue;
      }
      str += this.constructor.BOUNDARY_MARK + this.boundary
          + this.constructor.CR;
      str += (new Evernote.EvernoteFormPart( {
        name : i,
        data : this._data[i]
      })).toString();
      str += this.constructor.CR;
    }
  }
  str += this.constructor.BOUNDARY_MARK + this.boundary
      + this.constructor.BOUNDARY_MARK + this.constructor.CR;
  return str;
};

/** ************** Evernote.EvernoteFormPart *************** */

Evernote.EvernoteFormPart = function EvernoteFormPart(obj) {
  this.__defineGetter__("name", this.getName);
  this.__defineSetter__("name", this.setName);
  this.__defineGetter__("data", this.getData);
  this.__defineSetter__("data", this.setData);
  this.initialize(obj);
};
Evernote.EvernoteFormPart.HEADER_CONTENT_DISPOSITION = "Content-Disposition: ";
Evernote.EvernoteFormPart.HEADER_FORM_DATA = "form-data";
Evernote.EvernoteFormPart.HEADER_SEPARATOR = "; ";
Evernote.EvernoteFormPart.HEADER_KEYVAL_SEPARATOR = "=";
Evernote.EvernoteFormPart.HEADER_NAME = "name";
Evernote.EvernoteFormPart.CR = "\r\n";
Evernote.EvernoteFormPart.prototype._name = null;
Evernote.EvernoteFormPart.prototype._data = null;
Evernote.EvernoteFormPart.prototype.initialize = function(obj) {
  if (typeof obj == 'object' && obj != null) {
    this.name = (typeof obj["name"] != 'undefined') ? obj["name"] : null;
    this.data = (typeof obj["data"] != 'undefined') ? obj["data"] : null;
  }
};
Evernote.EvernoteFormPart.prototype.getHeader = function() {
  return this.constructor.HEADER_CONTENT_DISPOSITION
      + this.constructor.HEADER_FORM_DATA + this.constructor.HEADER_SEPARATOR
      + this.constructor.HEADER_NAME + this.constructor.HEADER_KEYVAL_SEPARATOR
      + "\"" + this.name + "\"";
};
Evernote.EvernoteFormPart.prototype.setName = function(name) {
  if (name == null) {
    this._name = null;
  } else {
    this._name = name + "";
  }
};
Evernote.EvernoteFormPart.prototype.getName = function() {
  return this._name;
};
Evernote.EvernoteFormPart.prototype.setData = function(data) {
  if (data == null) {
    this._data = null;
  } else {
    this._data = data + "";
  }
};
Evernote.EvernoteFormPart.prototype.getData = function() {
  return this._data;
};
Evernote.EvernoteFormPart.prototype.toJSON = function() {
  return {
    name : this.name,
    data : this.data
  };
};
Evernote.EvernoteFormPart.prototype.toString = function() {
  return this.getHeader() + this.constructor.CR + this.constructor.CR
      + (this.data + "");
};

(function() {
  var LOG = null;

  Evernote.MutableXMLHttpRequest = function MutableXMLHttpRequest() {
    LOG = Evernote.Logger.getInstance();
    this.initialize();
  };
  Evernote.inherit(Evernote.MutableXMLHttpRequest, XMLHttpRequest, true);
  Evernote.MutableXMLHttpRequest.prototype.initialize = function() {
    var self = this;
    for ( var i in this.__proto__) {
      if (i.indexOf("on") == 0) {
        var setter = function(value) {
          var fieldName = arguments.callee._fieldName;
          self["_" + fieldName] = value;
        };
        setter._fieldName = i;
        this.__defineSetter__(i, setter);
        var getter = function() {
          var fieldName = arguments.callee._fieldName;
          return function() {
            if (typeof self["_" + fieldName] == 'function') {
              self["_" + fieldName]();
            }
            if (typeof self["_proto_" + fieldName] == 'function') {
              self["_proto_" + fieldName]();
            }
          };
        };
        getter._fieldName = i;
        this.__defineGetter__(i, getter);
        this["_proto_" + i] = this.__proto__[i];
      }
    }
  };
  Evernote.MutableXMLHttpRequest.prototype.become = function(xhr) {
    var self = this;
    if (xhr instanceof XMLHttpRequest) {
      var oldXhr = this.__proto__;
      this.__proto__ = xhr;
      this.constructor = Evernote.MutableXMLHttpRequest;
      for ( var i in this) {
        if (i.indexOf("on") == 0 && this.hasOwnProperty(i)) {
          oldXhr[i] = this["_proto_" + i];
          this["_proto_" + i] = this.__proto__[i];
          var setter = function(value) {
            var fieldName = i;
            self["_proto_" + fieldName] = value;
          };
          setter._fieldName = i;
          this.__proto__[i] = this[i];
        }
      }
      for ( var i in this.constructor.prototype) {
        if (this.constructor.prototype.hasOwnProperty(i)
            && !this.__proto__.hasOwnProperty(i)) {
          try {
            this.__proto__[i] = this.constructor.prototype[i];
          } catch (e) {
          }
        }
      }
    }
  };

})();

/*
 * Evernote
 * EvernoteRemote
 * 
 * Created by Pavel Skaldin on 2/23/10
 * Copyright 2010 Evernote Corp. All rights reserved.
 */
/** ************** Evernote.EvernoteRemote *************** */

/**
 * Evernote.EvernoteRemote is used to retrieve data from and submit data to the
 * Evernote web service.
 * 
 * @return
 */
(function() {
  var LOG = null;
  Evernote.EvernoteRemote = function EvernoteRemote() {
    LOG = Evernote.Logger.getInstance();
    this.initialize();
  };
  // constants
  Evernote.EvernoteRemote.CLASS_IDENTIFIER = "javaClass";
  Evernote.EvernoteRemote.RESPONSE_ERROR_KEY = "errors";
  Evernote.EvernoteRemote.RESPONSE_RESULT_KEY = "result";
  Evernote.EvernoteRemote.DEFAULT_SNIPPET_MAX_LENGTH = 200;
  Evernote.EvernoteRemote.POST_TIMEOUT = 10 * 60 * 1000;
  Evernote.EvernoteRemote.GET_TIMEOUT = 5 * 60 * 1000;

  Evernote.EvernoteRemote.prototype._debugRequestData = false;

  Evernote.EvernoteRemote.prototype._dataMarshaller = function(data) {
    return Evernote.AppModel.marshall(data);
  };
  Evernote.EvernoteRemote.prototype._dataUnmarshaller = function(result) {
    if (typeof result == 'object') {
      for ( var resultKey in result) {
        var model = Evernote.AppModel.unmarshall(result[resultKey]);
      }
    }
    return result;
  };

  Evernote.EvernoteRemote.prototype.initialize = function() {
    this.__defineGetter__("dataMarshaller", this.getDataMarshaller);
    this.__defineSetter__("dataMarshaller", this.setDataMarshaller);
    this.__defineGetter__("dataUnmarshaller", this.getDataUnmarshaller);
    this.__defineSetter__("dataUnmarshaller", this.setDataUnmarshaller);
    this.__defineGetter__("debugRequestData", this.setDebugRequestData);
    this.__defineSetter__("debugRequestData", this.isDebugRequestData);
  };
  Evernote.EvernoteRemote.prototype.getDataMarshaller = function(fn) {
    return this._dataMarshaller;
  };
  Evernote.EvernoteRemote.prototype.setDataMarshaller = function(fn) {
    this._dataMarshaller = fn;
  };
  Evernote.EvernoteRemote.prototype.getDataUnmarshaller = function(fn) {
    return this._dataUnmarshaller;
  };
  Evernote.EvernoteRemote.prototype.setDataUnmarshaller = function(fn) {
    this._dataUnmarshaller = fn;
  };
  Evernote.EvernoteRemote.prototype.isDebugRequestData = function() {
    return this._debugRequestData;
  };
  Evernote.EvernoteRemote.prototype.setDebugRequestData = function(bool) {
    this._debugRequestData = (bool) ? true : false;
  };
  /**
   * Authenticates against web service. If rememberMe is <code>true</code>,
   * the session will be long-expriting (week).
   * 
   * @param username
   * @param password
   * @param rememberMe
   * @param success
   * @param failure
   * @param processResponse
   * @return
   */
  Evernote.EvernoteRemote.prototype.authenticate = function(username, password,
      rememberMe, success, failure, processResponse) {
    LOG.debug("Evernote.EvernoteRemote.authenticate");
    rememberMe = (typeof rememberMe == 'undefined' || !(rememberMe)) ? false
        : true;
    var data = {
      username : username,
      password : password,
      rememberMe : rememberMe
    };
    return this.getJson(Evernote.getContext().getLoginUrl(), data, success,
        failure, processResponse);
  };
  /**
   * Logs out from web service. This invalidates authentication token etc.
   * 
   * @param success
   * @param failure
   * @param processResponse
   * @return
   */
  Evernote.EvernoteRemote.prototype.logout = function(success, failure,
      processResponse) {
    LOG.debug("Evernote.EvernoteRemote.logout");
    return this.getJson(Evernote.getContext().getLogoutUrl(), {}, success,
        failure, processResponse);
  };
  /**
   * Gets sync state. Use last known updateCount whenever possible as that will
   * limit the amount of data returned from the service.
   * 
   * @param updateCount
   * @param success
   * @param failure
   * @param processResponse
   * @return
   */
  Evernote.EvernoteRemote.prototype.getSyncState = function(updateCount,
      success, failure, processResponse) {
    LOG.debug("Evernote.EvernoteRemote.getSyncState");
    updateCount = parseInt(updateCount);
    var data = {};
    if (updateCount > 0)
      data.updateCount = updateCount;
    try {
      LOG.debug("Get: " + Evernote.getContext().getSyncStateUrl() + "&"
          + ((data) ? JSON.stringify(data).replace(/,/g, "&") : ""));
    } catch (e) {
    }
    return this.getJson(Evernote.getContext().getSyncStateUrl(), data, success,
        failure, processResponse);
  };
  /**
   * Posts a clip to the web service, creating a note.
   * 
   * @param clipNote
   * @param success
   * @param failure
   * @param processResponse
   * @return
   */
  Evernote.EvernoteRemote.prototype.clip = function(clipNote, success, failure,
      processResponse) {
    LOG.debug("Evernote.EvernoteRemote.clip");
    var data = null;
    if (clipNote instanceof Evernote.ClipNote) {
      data = clipNote.toStorable();
    } else if (typeof clipNote == 'object' && clipNote != null) {
      LOG
          .warn("Passed object was not a Evernote.ClipNote... trying to make one");
      data = (new Evernote.ClipNote(clipNote)).toStorable();
    }
    return this.postJson(Evernote.getContext().getClipperUrl(), data, success,
        failure, processResponse, true);
  };
  /**
   * Files already created note. Basically this really just updates the note's
   * attributes such as notebook and tag association, as well as prepends or
   * appends additional text content to the note.
   * 
   * @param note
   * @param success
   * @param failure
   * @param processResponse
   * @return
   */
  Evernote.EvernoteRemote.prototype.file = function(note, success, failure,
      processResponse) {
    LOG.debug("Evernote.EvernoteRemote.fileNote");
    var data = {};
    if (note instanceof Evernote.Note) {
      if (note.guid)
        data.noteGuid = note.guid;
      if (note.title)
        data.title = note.title;
      if (note.comment)
        data.comment = note.comment;
      if (note.notebookGuid) {
        data.notebookGuid = note.notebookGuid;
      }
      if (note.tagNames) {
        data.tagNames = (note.tagNames instanceof Array) ? note.tagNames
            .join(",") : note.tagNames;
      }
      if (note.mailTo) {
        data.mailTo = note.mailTo;
        if (note.mailComment)
          data.mailComment = note.mailComment;
      }
    }
    return this.postJson(Evernote.getContext().getFileNoteUrl(), data, success,
        failure, processResponse);
  };
  /**
   * Deletes existing note from the account.
   * 
   * @param note
   * @param success
   * @param failure
   * @param processResponse
   * @return
   */
  Evernote.EvernoteRemote.prototype.deleteNote = function(note, success,
      failure, processResponse) {
    LOG.debug("Evernote.EvernoteRemote.deleteNote");
    var data = {};
    if (note instanceof Evernote.Note) {
      if (note.guid)
        data.noteGuid = note.guid;
    }
    return this.postJson(Evernote.getContext().getDeleteNoteUrl(), data,
        success, failure, processResponse);
  };
  /**
   * Finds note based on criteria specified by {@link Evernote.NoteFilter},
   * starting with offset, returning at most maxNotes notes.
   * 
   * @param noteFilter
   * @param offset
   * @param maxNotes
   * @param success
   * @param failure
   * @param processResponse
   * @return
   */
  Evernote.EvernoteRemote.prototype.findNotes = function(noteFilter, offset,
      maxNotes, success, failure, processResponse) {
    LOG.debug("Evernote.EvernoteRemote.findNotes");
    var data = {
      offset : parseInt(offset),
      maxNotes : parseInt(maxNotes)
    };
    this._findNotes(noteFilter, data, success, failure, processResponse);
  };

  /**
   * Much like findNotes except expect the result to contain an array of
   * SnippetNote's rather than Note's.
   */
  Evernote.EvernoteRemote.prototype.findSnippetNotes = function(noteFilter,
      offset, maxNotes, snippetMaxLength, success, failure, processResponse) {
    LOG.debug("Evernote.EvernoteRemote.findNotes");
    var data = {
      offset : parseInt(offset),
      maxNotes : parseInt(maxNotes),
      snippetMaxLength : parseInt(snippetMaxLength)
    };
    if (isNaN(data.snippetMaxLength) || data.snippetMaxLength <= 0) {
      data.snippetMaxLength = this.constructor.DEFAULT_SNIPPET_MAX_LENGTH;
    }
    this._findNotes(noteFilter, data, success, failure, processResponse);
  };

  /**
   * Supporting method for finding notes on the server
   */
  Evernote.EvernoteRemote.prototype._findNotes = function(noteFilter, data,
      success, failure, processResponse) {
    LOG.debug("Evernote.EvernoteRemote.findNotes");
    if (noteFilter instanceof Evernote.NoteFilter) {
      var storable = noteFilter.toStorable();
      for ( var i in storable) {
        if (typeof storable[i] != 'undefined' && storable[i] != null) {
          data["noteFilter." + i] = storable[i];
        }
      }
    }
    return this.postJson(Evernote.getContext().getFindNotesUrl(), data,
        success, failure, processResponse);
  };
  /**
   * General purpose method for posting JSON data to given url. If data is
   * large, set multipart argument to <code>true</code>.
   * 
   * @param url
   * @param data
   * @param success
   * @param failure
   * @param processResponse
   * @param multipart
   * @return
   */
  Evernote.EvernoteRemote.prototype.postJson = function(url, data, success,
      failure, processResponse, multipart) {
    return this.doRequest("POST", "json", url, data, success, failure,
        processResponse, multipart);
  };
  /**
   * General purpose method for getting JSON content from given URL. Query
   * parameters should be given in data object argument.
   * 
   * @param url
   * @param data
   * @param success
   * @param failure
   * @param processResponse
   * @return
   */
  Evernote.EvernoteRemote.prototype.getJson = function(url, data, success,
      failure, processResponse) {
    return this.doRequest("GET", "json", url, data, success, failure,
        processResponse);
  };
  /**
   * Method for executing web requests (posts and gets).
   * 
   * @param meth
   * @param dataType
   * @param url
   * @param data
   * @param success
   * @param failure
   * @param processResponse
   * @param multipart
   * @return
   */
  Evernote.EvernoteRemote.prototype.doRequest = function(meth, dataType, url,
      data, success, failure, processResponse, multipart) {
    if (meth == null) {
      meth = "GET";
    }
    var self = this;
    var updateCount = null;
    var username = null;
    var syncState = Evernote.getContext().getSyncState();
    var user = Evernote.getContext().getUser();
    var origRequest = {
      meth : meth,
      dataType : dataType,
      url : url,
      data : data,
      success : success,
      failure : failure,
      processResponse : processResponse,
      multipart : multipart
    };
    origRequest.__defineGetter__("arguments", function() {
      return [ this.meth, this.dataType, this.url, this.data, this.success,
          this.failure, this.processResponse, this.multipart ];
    });
    if (syncState instanceof Evernote.SyncState && syncState.updateCount
        && typeof data["updateCount"] == 'undefined') {
      data["updateCount"] = syncState.updateCount;
    }
    if (user instanceof Evernote.User && typeof user.username == 'string') {
      data["username"] = user.username;
    }
    if (LOG.isDebugEnabled()) {
      var dataStr = "";
      if (this._debugRequestData) {
        try {
          dataStr = JSON.stringify(data).replace(/\"password\":\"[^\"]+\"/,
              "\"password\":\"******\"");
        } catch (e) {
        }
      } else {
        var dataParams = [];
        for ( var i in data) {
          dataParams.push(i);
        }
        dataStr = "{" + dataParams.toString() + "}";
      }
      LOG.debug("doRequest(" + meth + ", " + dataType + ", " + url + ", "
          + dataStr + ")");
    }
    var errorHandler = function(xhr, textStatus, error) {
      LOG.debug("Evernote.EvernoteRemote.doRequest failed response");
      if (processResponse) {
        try {
          self.handleHttpError(xhr, textStatus, error, origRequest);
        } catch (e) {
          LOG.error((e && e.message) ? e.message : e);
          if (e instanceof Evernote.EvernoteRemoteException
              && e.code == Evernote.EvernoteRemoteErrors.ABORTED_RESPONSE_HANDLING) {
            return;
          } else {
            throw e;
          }
        }
      }
      if (typeof failure == 'function') {
        failure(xhr, textStatus, error);
      }
    };
    var successHandler = function(data, textStatus, xhr) {
      // work around for jQuery folks fucking up HTTP status codes
      if (xhr.status == 0) {
        return errorHandler(xhr, textStatus, data);
      }
      LOG.debug("Evernote.EvernoteRemote.doRequest successfull response");
      var response = data;
      if (processResponse) {
        try {
          response = self.handleHttpSuccess(data, textStatus, xhr, origRequest);
        } catch (e) {
          if (e instanceof Evernote.EvernoteRemoteException
              && e.code == Evernote.EvernoteRemoteErrors.ABORTED_RESPONSE_HANDLING) {
            return;
          } else {
            throw e;
          }
        }
      }
      if (typeof success == 'function') {
        success(response, textStatus, xhr);
      }
    };
    var ajaxOpts = {
      url : url,
      async : true,
      cache : false,
      data : data,
      dataType : dataType,
      error : errorHandler,
      success : successHandler,
      type : meth
    };
    if (multipart && meth == "POST") {
      var form = new Evernote.EvernoteMultiPartForm(data);
      ajaxOpts.contentType = form.getContentTypeHeader();
      ajaxOpts.data = form.toString();
    }
    if (meth == "POST") {
      ajaxOpts.timeout = this.constructor.POST_TIMEOUT;
    } else {
      ajaxOpts.timeout = this.constructor.GET_TIMEOUT;
    }
    return $.ajax(ajaxOpts);
  };
  /**
   * Handler of successfull HTTP requests. It gets called whenever XHR receives
   * a successful (200's HTTP Code) response.
   * 
   * @param data
   * @param textStatus
   * @param xhr
   * @return
   */
  Evernote.EvernoteRemote.prototype.handleHttpSuccess = function(data,
      textStatus, xhr, origRequest) {
    LOG.debug("Evernote.EvernoteRemote.handleHttpSuccess");
    var remote = this;
    try {
      var response = Evernote.EDAMResponse.createFrom(data, function(result) {
        if (result != null && typeof remote.dataUnmarshaller == 'function') {
          LOG.debug("Unmarshalling result");
          result = remote.dataUnmarshaller(result);
        } else {
          LOG.warn("Cannot unmarshall result");
        }
        return result;
      });
    } catch (e) {
      var msg = "";
      if (e instanceof Evernote.EvernoteError) {
        msg = e.errorCode;
        LOG.error("Exception creating Evernote.EDAMResponse: " + msg);
        var response = new Evernote.EDAMResponse();
        response.addError(e);
      } else {
        throw e;
      }
    }
    LOG.debug("HTTP [" + xhr.status + ", " + textStatus + "] Type: "
        + response.type);
    return response;
  };
  /**
   * Handler of erroneous HTTP requests. It gets called when XHR receives an
   * erroneous (non-200 HTTP Code) response.
   * 
   * @param xhr
   * @param textStatus
   * @param error
   * @return
   */
  Evernote.EvernoteRemote.prototype.handleHttpError = function(xhr, textStatus,
      error, origRequest) {
    if (xhr.readyState != 4) {
      LOG.error("HTTP [readyState: " + xhr.readyState + "]");
    } else {
      LOG.error("HTTP [readyState: " + xhr.readyState + "," + xhr.status + ","
          + textStatus + "] " + error);
    }
  };
  Evernote.EvernoteRemote.prototype.validateEDAMResponse = function(data,
      textStatus) {
    LOG.debug("Evernote.EvernoteRemote.validateEDAMResponse");
    if (data && typeof data == 'object') {
      return (typeof data[this.constructor.RESPONSE_RESULT_KEY] == 'object' && data[this.constructor.RESPONSE_RESULT_KEY] != null);
    } else {
      LOG.debug("Invalid response from jclipper...");
      throw new Error(Evernote.EDAMResponseErrorCode.INVALID_RESPONSE);
    }
  };

  /**
   * Exceptions generated by EvernoteRemote
   */
  Evernote.EvernoteRemoteException = function EvernoteRemoteException(code,
      message) {
    this.__defineGetter__("code", this.getCode);
    this.__defineSetter__("code", this.setCode);
    this.initialize(code, message);
  };
  Evernote.inherit(Evernote.EvernoteRemoteException, Error);
  Evernote.EvernoteRemoteException.prototype._code = 0;
  Evernote.EvernoteRemoteException.prototype.initialize = function(code,
      message) {
    this.code = code;
    this.message = message;
  };
  Evernote.EvernoteRemoteException.prototype.setCode = function(code) {
    this._code = parseInt(code);
    if (isNaN(this._code)) {
      this._code = 0;
    }
  };
  Evernote.EvernoteRemoteException.prototype.getCode = function() {
    return this._code;
  };

  /**
   * Error codes used by EvernoteRemote
   */
  Evernote.EvernoteRemoteErrors = {
    // indicates that handling of response was aborted
    ABORTED_RESPONSE_HANDLING : 10
  };
})();

Evernote.KonamiProto = {
  seq : [ 38, 38, 40, 40, 37, 39, 37, 39, 66, 65 ],
  timeout : 6000,
  reset : function() {
    this.idx = 0;
  },
  clearTimeout : function() {
    if (this.timeoutProc) {
      clearTimeout(this.timeoutProc);
    }
  },
  keystrokeHandler : function(event) {
    var self = Evernote.Konami.getInstance();
    self.clearTimeout();
    if (event.keyCode == self.seq[self.idx]) {
      self.idx++;
    } else {
      self.reset();
      return;
    }
    if (self.idx == self.seq.length) {
      self.reset();
      self.onactivate.apply(self, []);
    } else {
      self.timeoutProc = setTimeout(function() {
        self.reset();
      }, self.timeout);
    }
  },
  onactivate : function() {
  },
  start : function() {
    this.window.document.addEventListener("keydown", this.keystrokeHandler,
        false);
  },
  stop : function() {
    this.window.document.removeEventListener("keydown", this.keystrokeHandler,
        false);
  },
  initialize : function(win) {
    this.window = win || window;
    this.idx = 0;
    this.timeoutProc = null;
  }
};

Evernote.Konami = function Konami(win) {
  this.initialize(win);
};
Evernote.Konami.prototype = Evernote.KonamiProto;
Evernote.Konami._instance = null;
Evernote.Konami.getInstance = function(win) {
  var w = win || window;
  if (!this._instance) {
    this._instance = new this(w);
  }
  return this._instance;
};
Evernote.Konami.start = function(fn, win) {
  var konami = Evernote.Konami.getInstance(win);
  konami.onactivate = fn;
  konami.start();
};
Evernote.Konami.stop = function() {
  Evernote.Konami.getInstance().stop();
};

/*
 * Evernote.Utils
 * Evernote
 * 
 * Created by Pavel Skaldin on 2/23/10
 * Copyright 2010 Evernote Corp. All rights reserved.
 */
Evernote.Utils = new function Utils() {
};

/**
 * Expands object a with properties of object b
 */
Evernote.Utils.extendObject = function(a, b, deep, overwrite) {
  if (typeof a == 'object' && a != null && typeof b == 'object' && b != null) {
    for ( var i in b) {
      if (typeof a[i] == 'undefined' || overwrite) {
        a[i] = b[i];
      } else if (deep) {
        arguments.callee.apply(this, [ a[i], b[i], deep, overwrite ]);
      }
    }
  }
};
Evernote.Utils.importConstructs = function(fromWindow, toWindow, constructNames) {
  var names = (constructNames instanceof Array) ? constructNames
      : [ constructNames ];
  for ( var i = 0; i < names.length; i++) {
    var nameParts = names[i].split(".");
    var toAnchor = toWindow;
    var fromAnchor = fromWindow;
    for ( var p = 0; p < nameParts.length; p++) {
      if (p == nameParts.length - 1) {
        if (typeof toAnchor[nameParts[p]] == 'undefined') {
          toAnchor[nameParts[p]] = fromAnchor[nameParts[p]];
        } else {
          Evernote.Utils.extendObject(toAnchor[nameParts[p]],
              fromAnchor[nameParts[p]], true);
        }
      } else {
        fromAnchor = fromAnchor[nameParts[p]];
        if (typeof toAnchor[nameParts[p]] == 'undefined') {
          toAnchor[nameParts[p]] = {};
        }
        toAnchor = toAnchor[nameParts[p]];
      }
    }
  }
};

Evernote.Utils.separateString = function(str, separator) {
  if (typeof str != 'string')
    return str;
  if (typeof separator != 'string')
    separator = ",";
  var parts = str.split(separator);
  var returnParts = new Array();
  for ( var i = 0; i < parts.length; i++) {
    if (typeof parts[i] != 'string')
      continue;
    var clean = Evernote.Utils.trim(parts[i]);
    if (clean && clean.length > 0)
      returnParts.push(clean);
  }
  return returnParts;
};

Evernote.Utils.trim = function(str) {
  if (typeof str != 'string')
    return str;
  return str.replace(/^\s+/, "").replace(/\s+$/, "");
};

Evernote.Utils.shortenString = function(str, len, suffix) {
  var s = str + "";
  if (s.length > len) {
    s = s.substring(0, Math.max(0, len
        - ((typeof suffix == 'string') ? suffix.length : 0)));
    if (typeof suffix == 'string')
      s += suffix;
  }
  return s;
};

Evernote.Utils.htmlEntities = function(anything) {
  return $("<div/>").text(anything).html();
};
Evernote.Utils.urlPath = function(url) {
  if (typeof url == 'string') {
    var path = url.replace(/^[^:]+:\/+([^\/]+)/, "");
    if (path.indexOf("/") == 0) {
      return path.replace(/^(\/[^\?\#]*).*$/, "$1");
    }
  }
  return "";
};
Evernote.Utils.urlDomain = function(url, includePort) {
  if (typeof url == 'string') {
    var re = new RegExp("^[^:]+:\/+([^\/" + ((includePort) ? "" : ":")
        + "]+).*$");
    return url.replace(re, "$1");
  }
  return url;
};
Evernote.Utils.urlTopDomain = function(url) {
  var topDomain = url;
  if (typeof url == 'string') {
    var topDomain = Evernote.Utils.urlDomain(url);
    if (topDomain.toLowerCase().indexOf("www.") == 0) {
      topDomain = topDomain.substring(4);
    }
  }
  return topDomain;
};
Evernote.Utils.urlQueryValue = function(key, url) {
  if (typeof url == 'string' && typeof key == 'string' && url.indexOf("?") >= 0) {
    var queries = url.split(/[\?\#\&]+/).slice(1);
    var k = key.toLowerCase();
    var results = new Array();
    for ( var i = 0; i < queries.length; i++) {
      var kv = queries[i].split("=", 2);
      if (kv[0].toLowerCase() == k) {
        var r = (kv[1]) ? kv[1].replace(/\+/g, " ") : kv[1];
        results.push(decodeURIComponent(r));
      }
    }
    if (results.length > 0) {
      return results[results.length - 1];
    }
  }
  return null;
};
Evernote.Utils.urlProto = function(url) {
  if (typeof url == 'string') {
    var x = -1;
    if ((x = url.indexOf(":/")) > 0) {
      return url.substring(0, x).toLowerCase();
    }
  }
  return null;
};
Evernote.Utils.urlToSearchQuery = function(url, searchPrefix) {
  // determine protocol
  var proto = Evernote.Utils.urlProto(url);
  if (proto && proto.indexOf("http") == 0) {
    return Evernote.Utils.httpUrlToSearchQuery(url, searchPrefix);
  } else if (proto && proto == "file") {
    return Evernote.Utils.fileUrlToSearchQuery(url, searchPrefix);
  } else if (proto) {
    return Evernote.Utils.anyProtoUrlToSearchQuery(url, searchPrefix);
  } else {
    return Evernote.Utils.anyUrlToSearchQuery(url, searchPrefix);
  }
};
Evernote.Utils.httpUrlToSearchQuery = function(url, searchPrefix) {
  // determine query prefix
  var pfx = (typeof searchPrefix == 'string') ? searchPrefix : "";
  // actual FQDN
  var domain = Evernote.Utils.urlDomain((url + "").toLowerCase());
  var allUrls = [ (pfx + "http://" + domain + "*"),
      (pfx + "https://" + domain + "*") ];
  if (domain.match(/[^0-9\.]/)) {
    var secondaryDomain = (domain.indexOf("www.") == 0) ? domain.substring(4)
        : ("www." + domain);
    // query parameters based on actual FQDN
    allUrls = allUrls.concat( [ (pfx + "http://" + secondaryDomain + "*"),
        (pfx + "https://" + secondaryDomain + "*") ]);
  }
  var q = "any: " + allUrls.join(" ");
  return q;
};
Evernote.Utils.fileUrlToSearchQuery = function(url, searchPrefix) {
  // determine query prefix
  var pfx = (typeof searchPrefix == 'string') ? searchPrefix : "";
  var q = pfx + "file:*";
  return q;
};
Evernote.Utils.anyProtoUrlToSearchQuery = function(url, searchPrefix) {
  // determine query prefix
  var pfx = (typeof searchPrefix == 'string') ? searchPrefix : "";
  var proto = Evernote.Utils.urlProto(url);
  var secProto = proto + "s";
  if (proto.indexOf("s") == (proto.length - 1)) {
    proto = proto.substring(0, (proto.length - 1));
    secProto = proto + "s";
  }
  var domain = Evernote.Utils.urlDomain(url);
  var allUrls = [ (pfx + proto + "://" + domain + "*"),
      (pfx + secProto + "://" + domain + "*") ];
  var q = "any: " + allUrls.join(" ");
  return q;
};
Evernote.Utils.anyUrlToSearchQuery = function(url, searchPrefix) {
  // determine query prefix
  var pfx = (typeof searchPrefix == 'string') ? searchPrefix : "";
  var q = pfx + url + "*";
  return q;
};
Evernote.Utils.urlSuffix = "...";
Evernote.Utils.shortUrl = function(url, maxLength) {
  var shortUrl = url;
  if (typeof url == 'string') {
    if (shortUrl.indexOf("file:") == 0) {
      shortUrl = decodeURIComponent(shortUrl.replace(/^file:.*\/([^\/]+)$/,
          "$1"));
      if (typeof maxLength == 'number' && !isNaN(maxLength)
          && shortUrl.length > maxLength) {
        shortUrl = shortUrl.substring(0, maxLength);
        shortUrl += "" + Evernote.Utils.urlSuffix;
      }
    } else {
      shortUrl = shortUrl.replace(/^([a-zA-Z]+:\/+)?([^\/]+).*$/, "$2");
      if (typeof maxLength == 'number' && !isNaN(maxLength)
          && shortUrl.length > maxLength) {
        shortUrl = shortUrl.substring(0, maxLength);
        shortUrl += "" + Evernote.Utils.urlSuffix;
      } else if (url.substring(url.indexOf(shortUrl) + shortUrl.length).length > 2) {
        shortUrl += "/" + Evernote.Utils.urlSuffix;
      }
    }
  }
  return shortUrl;
};
Evernote.Utils.appendSearchQueryToUrl = function(url, params) {
  var _url = url + "";
  _url += (_url.indexOf("?") >= 0) ? "&" : "?";
  if (typeof params == 'string') {
    _url += params;
  } else if (typeof params == 'object' && params) {
    for ( var i in params) {
      _url += encodeURIComponent(i) + "=" + encodeURIComponent(params[i]) + "&";
    }
  }
  if (_url.charAt(_url.length - 1) == "&") {
    _url = _url.substring(0, _url.length - 1);
  }
  return _url;
};

Evernote.UUID = {
  generateQuad : function() {
    return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
  },
  generateGuid : function() {
    return (this.generateQuad() + this.generateQuad() + "-"
        + this.generateQuad() + "-" + this.generateQuad() + "-"
        + this.generateQuad() + "-" + this.generateQuad() + this.generateQuad() + this
        .generateQuad());
  }
};

/*
 * Evernote.XORCrypt
 * Evernote
 *
 * Created by Pavel Skaldin on 3/7/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
/**
 * Naive implementation of XOR encryption with padding. It is not meant to be a
 * strong encryption of any kind, just an obfuscation. The algorithm uses a seed
 * string for XORing. The string to be encrypted is first XOR'd with a random
 * number to avoid recognizable patterns; the result is then padded and then
 * XOR'd with the seed string.
 * 
 * Make sure that XORCrypt.LENGTH is larger than the strings you're trying to
 * encrypt.
 * 
 * <pre>
 * Usage: 
 * var enc = Evernote.XORCrypt.encrypt(&quot;secret&quot;, &quot;seed&quot;); 
 * var dec = Evernote.XORCrypt.decrypt(enc, &quot;seed&quot;);
 * </pre>
 */
Evernote.XORCrypt = {
  DELIMIT : ":",
  LENGTH : 128,
  /**
   * Pads string to make it XORCrypt.LENGTH characters in length. Padding is
   * done by prepending the string with random chars from a range of printable
   * ascii chars.
   */
  _padString : function(str) {
    var counter = 0;
    if (str.length < 128) {
      for ( var i = str.length; i <= 128; i++) {
        str = String.fromCharCode(this._randomForChar()) + str;
        counter++;
      }
    }
    return counter + this.DELIMIT + str;
  },
  /**
   * Returns random number that would correspond to a printable ascii char.
   */
  _randomForChar : function() {
    var r = 0;
    var c = 0;
    while (r < 33 || r > 126) {
      // just a waiting... this shouldn't happen frequently
      r = parseInt(Math.random() * 150);
      c++;
    }
    return r;
  },
  /**
   * Returns random non-zero integer.
   */
  _randomNonZero : function() {
    var r = 0;
    while ((r = parseInt(Math.random() * 100)) == 0) {
      // just a waiting... this shouldn't happen frequently
    }
    return r;
  },
  /**
   * Shifts string by XOR'ing it with a number larger than 100 so as to avoid
   * non-printable characters. The resulting string will be prepended with the
   * number used to XOR followed by DELIMITER.
   */
  _shiftString : function(str) {
    var delta = this._randomNonZero() + 100;
    var shifted = [];
    for ( var i = 0; i < str.length; i++) {
      shifted.push(String.fromCharCode(str.charCodeAt(i) + delta));
    }
    return delta + this.DELIMIT + shifted.join("");
  },
  /**
   * Unshifts and returns a shifted string. The argument should be in a format
   * produced by _shitString(), i.e. begin with the shift coefficient followed
   * by DELIMITER, followed by the shifted string.
   */
  _unshiftString : function(str) {
    var delta = parseInt(str.substring(0, str.indexOf(this.DELIMIT)));
    var unshifted = [];
    if (!isNaN(delta)) {
      for ( var i = ((delta + "").length + this.DELIMIT.length); i < str.length; i++) {
        unshifted.push(String.fromCharCode(str.charCodeAt(i) - delta));
      }
    }
    return unshifted.join("");
  },
  /**
   * Encrypts string with a seed string and returns encrypted string padded to
   * be XORCrypt.LENGTH characters long.
   */
  encrypt : function(str, seed) {
    str += "";
    seed += "";
    var newStr = this._padString(this._shiftString(str));
    var enc = [];
    for ( var i = 0; i < newStr.length; i++) {
      var e = newStr.charCodeAt(i);
      for ( var j = 0; j < seed.length; j++) {
        e = seed.charCodeAt(j) ^ e;
      }
      enc.push(String.fromCharCode(e + 100));
    }
    return enc.join("");
  },
  /**
   * Decrypts string using seed string. The seed string has to be the same
   * string that was used in encrypt()ing.
   */
  decrypt : function(str, seed) {
    str += "";
    seed += "";
    var dec = [];
    for ( var i = 0; i < str.length; i++) {
      var e = str.charCodeAt(i) - 100;
      for ( var j = seed.length - 1; j >= 0; j--) {
        e = seed.charCodeAt(j) ^ e;
      }
      dec.push(String.fromCharCode(e));
    }
    var decStr = dec.join("");
    var pad = parseInt(decStr.substring(0, decStr.indexOf(this.DELIMIT)));
    if (!isNaN(pad)) {
      return this._unshiftString(decStr.substring(("" + pad).length
          + this.DELIMIT.length + pad));
    }
    return "";
  }
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

(function() {
  var LOG = null;

  Evernote.QueueProcessorStatus = {
    STOPPED : 0,
    STARTED : 1
  };

  Evernote.QueueProcessor = function QueueProcessor(interval, gracePeriod) {
    LOG = Evernote.Logger.getInstance();
    this.__defineGetter__("active", this.isActive);
    this.__defineGetter__("length", this.getLength);
    this.__defineType__("queue", "Array");
    this.__definePositiveInteger__("sema", 0);
    this.__definePositiveInteger__("status", 0);
    this.__definePositiveInteger__("interval", 0);
    this.__definePositiveInteger__("gracePeriod", 0);
    this.__definePositiveInteger__("lastSuccess", 0);
    this.__definePositiveInteger__("lastError", 0);
    this.__definePositiveInteger__("processTimeout", 0);
    this.initialize(interval, gracePeriod);
  };
  Evernote.mixin(Evernote.QueueProcessor, Evernote.DefiningMixin);

  Evernote.QueueProcessor.prototype._proc = null;

  Evernote.QueueProcessor.prototype.initialize = function(interval, gracePeriod) {
    this.interval = interval;
    this.gracePeriod = gracePeriod;
    this.queue = [];
  };

  Evernote.QueueProcessor.prototype.getLength = function() {
    if (this.currentItem && this.queue.indexOf(this.currentItem) >= 0) {
      LOG
          .warn("Something went wrong and currentItem ended up back in the queue while still being currentItem");
    }
    var delta = (this.currentItem) ? 1 : 0;
    return this.queue.length + delta;
  };
  Evernote.QueueProcessor.prototype.isEmpty = function() {
    return this.length == 0;
  };
  Evernote.QueueProcessor.prototype.start = function(noprocess) {
    LOG.debug("Evernote.QueueProcessor.start");
    var self = this;
    if (typeof this.processor != 'function') {
      throw new Error("No processor defined");
    }
    if (this.isStopped()) {
      this.status = Evernote.QueueProcessorStatus.STARTED;
      if (this.interval > 0) {
        this._proc = setInterval(function() {
          LOG.debug("Periodic check for processing");
          self.process();
        }, this.interval);
      }
      if (!this.isActive() && !noprocess) {
        this.process();
      }
    } else if (this.isStarted() && !noprocess) {
      LOG
          .debug("Attempt was made to start QueueProcessor, but it's already started. Kicking off the processor...");
      this.process();
    } else {
      LOG
          .error("Attempt was made to start QueueProcessor, but it's status is uknown: "
              + this.status + ". Ignoring...");
    }
  };
  Evernote.QueueProcessor.prototype.stop = function() {
    LOG.debug("Evernote.QueueProcessor.stop");
    if (this._proc) {
      clearInterval(this._proc);
      this.sema = 0;
    }
    this.status = Evernote.QueueProcessorStatus.STOPPED;
  };
  Evernote.QueueProcessor.prototype.isStopped = function() {
    return this.status == Evernote.QueueProcessorStatus.STOPPED;
  };
  Evernote.QueueProcessor.prototype.isStarted = function() {
    return this.status == Evernote.QueueProcessorStatus.STARTED;
  };
  Evernote.QueueProcessor.prototype.isActive = function() {
    return this.sema > 0;
  };
  Evernote.QueueProcessor.prototype.createPayload = function(item) {
    return new Evernote.ProcessorPayload(item);
  };
  Evernote.QueueProcessor.prototype.add = function(item) {
    this.queue.push(this.createPayload(item));
  };
  Evernote.QueueProcessor.prototype.addAll = function(items) {
    for ( var i = 0; i < items.length; i++) {
      this._add(items[i], true);
    }
  };
  Evernote.QueueProcessor.prototype.remove = function(item) {
    var removed = undefined;
    for ( var i = 0; i < this.queue.length; i++) {
      if (this.queue[i].data == item) {
        removed = this.queue.splice(i, 1).shift();
        break;
      }
    }
    if (!removed && this.currentItem && this.currentItem.data == item) {
      removed = this.currentItem;
      this.currentItem = null;
    }
    if (LOG.isDebugEnabled()) {
      LOG.debug("Removed item");
      LOG.dir(removed);
    }
    return removed;
  };
  Evernote.QueueProcessor.prototype.removePayload = function(payload) {
    var i = this.queue.indexOf(payload);
    var removed = undefined;
    if (i >= 0) {
      removed = this.queue.splice(i, 1).shift();
    } else if (this.currentItem && this.currentItem == payload) {
      removed = this.currentItem;
      this.currentItem = null;
    }
    if (LOG.isDebugEnabled()) {
      LOG.debug("Removed payload");
      LOG.dir(removed);
    }
    return removed;
  };
  Evernote.QueueProcessor.prototype.removeAll = function() {
    this.queue = [];
    this.currentItem = null;
  };
  Evernote.QueueProcessor.prototype.isPayloadProcessed = function(payload) {
    return (payload.processed) ? true : false;
  };
  Evernote.QueueProcessor.prototype.isPayloadInGrace = function(payload) {
    var now = new Date().getTime();
    if (!payload.processed && payload.lastProcessed > 0
        && (now - payload.lastProcessed) < this.gracePeriod) {
      return true;
    }
    return false;
  };
  Evernote.QueueProcessor.prototype.isPayloadProcessable = function(payload) {
    if (this.isPayloadProcessed(payload) || this.isPayloadInGrace(payload)) {
      return false;
    }
    return true;
  };
  Evernote.QueueProcessor.prototype.indexOfNext = function() {
    LOG.debug("QueueProcessor.indexOfNext");
    var now = new Date().getTime();
    for ( var i = 0; i < this.queue.length; i++) {
      var payload = this.queue[i];
      if (this.isPayloadProcessable(payload)) {
        return i;
      }
    }
    return -1;
  };
  Evernote.QueueProcessor.prototype.hasNext = function() {
    LOG.debug("QueueProcessor.hasNext");
    return (this.indexOfNext() >= 0) ? true : false;
  };
  Evernote.QueueProcessor.prototype.next = function() {
    LOG.debug("Evernote.QueueProcessor.next");
    var i = this.indexOfNext();
    if (i >= 0) {
      return this.queue.splice(i, 1).shift();
    }
    return undefined;
  };
  Evernote.QueueProcessor.prototype.peek = function() {
    LOG.debug("Evernote.QueueProcessor.peek");
    // return this.queue[0];
    var i = this.indexOfNext();
    if (i >= 0) {
      return this.queue[i];
    }
  };
  Evernote.QueueProcessor.prototype.wait = function() {
    LOG.debug("Evernote.QueueProcessor.wait");
    this.sema++;
    LOG.debug("SEMA = " + this.sema);
  };
  Evernote.QueueProcessor.prototype.signal = function() {
    LOG.debug("Evernote.QueueProcessor.signal");
    if (LOG.isDebugEnabled()) {
      LOG.dir(arguments.callee.caller);
    }
    this.sema--;
    LOG.debug("SEMA = " + this.sema);
    if (this.isStarted()) {
      LOG
          .debug("Kicking off processor cuz there's no one waiting and we're started");
      this.process();
    } else {
      LOG
          .debug("Not kicking off processor when there's nothing waiting because it hasn't been started yet...");
    }
  };
  Evernote.QueueProcessor.prototype._onprocess = function(item, processor, data) {
    LOG.debug("QueueProcessor._onprocess");
    item.processed = true;
    item.lastProcessed = new Date().getTime();
    if (typeof this.onprocess == 'function') {
      try {
        this.onprocess(item, processor, data);
      } catch (e) {
        LOG.exception("Exception handling onprocess: " + e);
      }
    }
    this.currentItem = null;
    this.lastSuccess = new Date().getTime();
    LOG.debug("Queue size: " + this.queue.length);
  };
  Evernote.QueueProcessor.prototype._onprocesserror = function(item, processor,
      data) {
    LOG.debug("QueueProcessor._onprocesserror");
    item.processed = false;
    item.lastProcessed = new Date().getTime();
    this.lastError = new Date().getTime();
    if (typeof this.onprocesserror == 'function') {
      try {
        this.onprocesserror(item, processor, data);
      } catch (e) {
        LOG.exception("Exception handling onprocesserror: " + e);
      }
    }
    this.currentItem = null;
    this.queue.push(item);
    LOG.debug("Queue size: " + this.queue.length);
  };
  Evernote.QueueProcessor.prototype._onprocesstimeout = function() {
    LOG.debug("QueueProcessor._onprocesstimeout");
    if (typeof this.onprocesstimeout == 'function') {
      try {
        this.onprocesstimeout();
      } catch (e) {
        LOG.exception("Exception handling onprocesstimeout: " + e);
      }
    }
    if (this.currentItem) {
      this.currentItem.processed = false;
      this.currentItem.lastProcessed = new Date().getTime();
      this.currentItem.lastError = new Date().getTime();
      this.queue.push(this.currentItem);
      this.currentItem = null;
      this.signal();
    }
  };
  Evernote.QueueProcessor.prototype.process = function(force) {
    LOG.debug("QueueProcessor.process");
    if (this.isStarted() && !this.isActive()) {
      var self = this;
      if (force) {
        this.refresh();
      }
      if (this.hasNext()) {
        this.wait();
        var item = this.currentItem = this.next();
        LOG.debug("About to process next item:");
        if (LOG.isDebugEnabled()) {
          LOG.dir(item);
        }
        item.attempts++;
        this.processor(item.data, function(data) {
          LOG.debug("Successfully processed item");
          self._onprocess(item, self, data);
          self.signal();
        }, function(data) {
          LOG.debug("Error processing item");
          self._onprocesserror(item, self, data);
          self.signal();
        });
      } else {
        LOG.debug("Nothing to process...");
      }
    } else if (!this.isStarted()) {
      LOG.warn("QueueProcessor hasn't been started");
    } else if (this.isActive()) {
      if (this.processTimeout > 0 && this.currentItem
          && ((Date.now() - this.currentItem.created) > this.processTimeout)) {
        LOG.debug("Payload is taking too long, let's timeout");
        this._onprocesstimeout();
      } else {
        LOG
            .warn("Attempt was made to process QueueProcessor, but it's already active. Ignoring attempt");
      }
    }
  };
  Evernote.QueueProcessor.prototype.refresh = function() {
    LOG.debug("QueueProcessor.refresh");
    for ( var i = 0; i < this.queue.length; i++) {
      var payload = this.queue[i];
      if (payload) {
        payload.refresh();
      }
    }
  };
  Evernote.QueueProcessor.prototype.toString = function() {
    var stat = "UNKNOWN";
    if (this.status == Evernote.QueueProcessorStatus.STARTED) {
      stat = "STARTED";
    } else if (this.status == Evernote.QueueProcessorStatus.STOPPED) {
      stat = "STOPPED";
    }
    return this.constructor.name + " " + stat + " (" + this.queue.length
        + " items; " + ((this.currentItem) ? "1" : "0") + " pending) [int: "
        + this.interval + "; grace: " + this.gracePeriod + "; lastSuccess: "
        + this.lastSuccess + "; lastError: " + this.lastError + "]";
  };

  Evernote.ProcessorPayload = function ProcessorPayload(obj) {
    this.initialize(obj);
  };
  Evernote.ProcessorPayload.fromObject = function(obj) {
    if (obj instanceof Evernote.ProcessorPayload) {
      return obj;
    } else {
      var newObj = new Evernote.ProcessorPayload();
      if (typeof obj == 'object' && obj) {
        for ( var i in obj) {
          if (typeof obj[i] != 'function'
              && typeof newObj.__proto__[i] != 'undefined') {
            newObj[i] = obj[i];
          }
        }
      }
      return newObj;
    }
  };
  Evernote.ProcessorPayload.prototype.data = null;
  Evernote.ProcessorPayload.prototype.created = 0;
  Evernote.ProcessorPayload.prototype.lastProcessed = 0;
  Evernote.ProcessorPayload.prototype.processed = false;
  Evernote.ProcessorPayload.prototype.attempts = 0;
  Evernote.ProcessorPayload.prototype.initialize = function(obj) {
    this.data = obj;
    this.created = new Date().getTime();
  };
  Evernote.ProcessorPayload.prototype.refresh = function() {
    this.lastProcessed = 0;
    this.processed = false;
    this.attempts = 0;
  };
  Evernote.ProcessorPayload.prototype.toJSON = function() {
    return {
      data : this.data,
      processed : this.processed,
      created : this.created,
      lastProcessed : this.lastProcessed,
      attempts : this.attempts
    };
  };
  Evernote.ProcessorPayload.prototype.toLOG = function() {
    return {
      "created" : this.created,
      "processed" : this.processed,
      "lastProcessed" : this.lastProcessed,
      "attempts" : this.attempts,
      "data" : (typeof this.data == 'object' && this.data && typeof this.data.toLOG == 'function') ? this.data
          .toLOG()
          : this.data
    };
  };
})();


(function() {
  var LOG = null;
  Evernote.PersistentQueueProcessor = function PersistentQueueProcessor(path,
      size, interval, gracePeriod, success, error) {
    LOG = Evernote.Logger.getInstance();
    this.__defineType__("fsa", Evernote.FSA);
    this.__defineString__("rootPath", "/");
    this.initialize(path, size, interval, gracePeriod, success, error);
  };
  Evernote.inherit(Evernote.PersistentQueueProcessor, Evernote.QueueProcessor);

  Evernote.PersistentQueueProcessor.prototype.initialize = function(path, size,
      interval, gracePeriod, success, error) {
    LOG.debug("PersistentQueueProcessor.initialize");
    var self = this;
    Evernote.PersistentQueueProcessor.parent.initialize.apply(this, [ interval,
        gracePeriod ]);
    if (path && size) {
      if (path) {
        this.rootPath = path;
      }
      this.initializeFSA(size, success, error);
    }
  };
  Evernote.PersistentQueueProcessor.prototype.initializeFSA = function(size,
      success, error) {
    LOG.debug("PersistentQueueProcessor.inializeFSA");
    var self = this;
    var errorHandler = function(e) {
      LOG.debug("Error creating FSA for PersistentQueueProcessor: " + e.code);
      self.signal();
      if (typeof error == 'function') {
        error(e);
      }
    };
    this.wait();
    this.fsa = new Evernote.FSA(PERSISTENT, size, function() {
      LOG.debug("Successfully created FSA, making sure we have the path");
      self.fsa.ensureDirectory(self.rootPath, function() {
        LOG.debug("Ensured and using the requested path as root path: "
            + self.rootPath);
        self.fsa.changeDirectory(self.rootPath, function() {
          self.fsa.listFiles(null, function(entries) {
            LOG.debug("Successfully read pre-existing file entries: "
                + entries.length);
            self.initializeWithEntries(entries);
            if (typeof success == 'function') {
              success();
            }
            self.signal();
          }, errorHandler);
        }, errorHandler);
      }, errorHandler);
    }, errorHandler);
  };
  Evernote.PersistentQueueProcessor.prototype._pathForItem = function(item) {
    return "" + (new Date().getTime());
  };
  Evernote.PersistentQueueProcessor.prototype.initializeWithEntries = function(
      entries) {
    LOG.debug("PersistentQueueProcessor.initializeWithEntries");
    if (entries && entries.length > 0) {
      for ( var i = 0; i < entries.length; i++) {
        if (this.isInitializableFileEntry(entries[i])) {
          this.add(entries[i]);
        }
      }
    }
  };
  Evernote.PersistentQueueProcessor.prototype.isInitializableFileEntry = function(
      fileEntry) {
    return (fileEntry && fileEntry.isFile) ? true : false;
  };
  Evernote.PersistentQueueProcessor.prototype.createPayload = function(item) {
    LOG.debug("PersistentQueueProcessor.createPayload");
    var self = this;
    var payload = Evernote.PersistentProcessorPayload
        .fromObject(Evernote.PersistentQueueProcessor.parent.createPayload
            .apply(this, [ item ]));
    if (item && item.isFile) {
      LOG.debug("Creating payload for file");
      payload.path = item.name;
      payload.file = item;
      payload.data = null;
    } else {
      LOG.debug("Creating payload for data object");
      payload.path = this._pathForItem(item);
      payload.data = item;
      var content = Evernote.AppModel.serializeStorable(item);
      this.fsa
          .writeFile(
              payload.path,
              content,
              function(writer, file) {
                if (self.isPayloadProcessed(payload)) {
                  self.fsa
                      .removeFile(
                          payload.path,
                          function() {
                            LOG
                                .debug("Successfully removed just-created file, since it was already uploaded");
                          }, self._onremoveerror);
                } else {
                  LOG.debug("Associating file with payload");
                  payload.file = file;
                  if (LOG.isDebugEnabled()) {
                    LOG.dir(payload);
                  }
                }
              }, this._onwriteerror);
    }
    return payload;
  };
  Evernote.PersistentQueueProcessor.prototype.remove = function(item,
      dontRemoveFile) {
    LOG.debug("PersistentQueueProcessor.remove");
    var removed = Evernote.PersistentQueueProcessor.parent.remove.apply(this,
        [ item ]);
    if (removed && !dontRemoveFile) {
      this._removePayloadFile(removed);
    } else {
      LOG
          .debug("Not removing payload file cuz there isn't one associated with the payload");
    }
    return removed;
  };
  Evernote.PersistentQueueProcessor.prototype.removePayload = function(payload,
      dontRemoveFile) {
    LOG.debug("PersistentQueueProcessor.removePayload");
    var removed = Evernote.PersistentQueueProcessor.parent.removePayload.apply(
        this, [ payload ]);
    if (removed && !dontRemoveFile) {
      this._removePayloadFile(removed);
    } else {
      LOG
          .debug("Not removing payload file cuz there isn't one associated with the payload");
    }
  };
  Evernote.PersistentQueueProcessor.prototype._removePayloadFile = function(
      payload) {
    LOG.debug("PersistentQueueProcessor._removePayloadFile");
    if (payload && payload.file) {
      payload.file.remove(function() {
        LOG.debug("Successfully removed file: " + payload.file.fullPath);
      }, this._onremoveerror);
    }
  };
  Evernote.PersistentQueueProcessor.prototype.removeAll = function(
      dontRemoveFiles) {
    LOG.debug("PersistentQueueProcessor.removeAll");
    var self = this;
    Evernote.PersistentQueueProcessor.parent.removeAll.apply(this);
    if (!dontRemoveFiles) {
      var errorCallback = function(e) {
        LOG.error("FSA Error during PersistentQueueProcessor.removeAll: "
            + e.code);
      };
      this.fsa.emptyDirectory(this.rootPath, function() {
        LOG.debug("Successfully emptied directory: " + this.rootPath);
      }, errorCallback);
    }
  };
  Evernote.PersistentQueueProcessor.prototype._onfsaerror = function(e) {
    LOG.error("FSA Error: " + e.code);
    if (typeof this.onfsaerror == 'function') {
      this.onfsaerror(e);
    }
  };
  Evernote.PersistentQueueProcessor.prototype._onwriteerror = function(e) {
    LOG.error("Failed to write to file: " + e.code);
    this._onfsaerror(e);
    if (typeof this.onwriteerror == 'function') {
      this.onwriteerror(e);
    }
  };
  Evernote.PersistentQueueProcessor.prototype._onremoveerror = function(e) {
    LOG.error("Failed to remove file: " + e.code);
    if (typeof this.onremoveerror == 'function') {
      this.onremoveerror(e);
    }
  };
  Evernote.PersistentQueueProcessor.prototype._onprocess = function(item,
      processor, data) {
    LOG.debug("PersistentQueueProcessor._onprocess");
    Evernote.PersistentQueueProcessor.parent._onprocess.apply(this, arguments);
    this._removePayloadFile(item);
  };
  Evernote.PersistentQueueProcessor.prototype._onreaderror = function(item, e) {
    LOG.debug("PersistentQueueProcessor._onreaderror");
    this.removePayload(item);
    if (typeof this.onreaderror == 'function') {
      this.onreaderror(item, e);
    }
  };
  Evernote.PersistentQueueProcessor.prototype.process = function(force) {
    LOG.debug("PersistentQueueProcessor.process");
    var self = this;
    var error = function(e) {
      LOG.error("Error retrieving contents of a file: " + e.code);
      self.signal();
    };
    if (!this.isStarted()) {
      LOG
          .warn("Attempted to processes when processor hasn't been started yet...");
      return;
    }
    var peeked = this.peek();
    if (peeked && !this.isActive() && !peeked.data && peeked.file) {
      LOG.debug("Next entry in the queue is a file, let's read it in");
      this.wait();
      peeked.file.file(function(file) {
        self.fsa.readTextFromFile(file, function(reader, file) {
          try {
            var content = Evernote.AppModel.unserializeStorable(reader.result);
            peeked.data = content;
          } catch (e) {
            LOG.warn("Error reading clip from file " + file.name + ": " + e);
            self._onreaderror(peeked, e);
          }
          self.signal();
        }, error);
      }, error);
      return;
    } else if (peeked) {
      LOG.debug("Next entry is not a file, let's process it...");
      Evernote.PersistentQueueProcessor.parent.process.apply(this, arguments);
    }
  };

  Evernote.PersistentProcessorPayload = function PersistentProcessorPayload(obj) {
    this.initialize(obj);
  };
  Evernote.inherit(Evernote.PersistentProcessorPayload,
      Evernote.ProcessorPayload);
  Evernote.PersistentProcessorPayload.fromObject = function(obj) {
    if (obj instanceof Evernote.PersistentProcessorPayload) {
      return obj;
    } else {
      var newObj = new Evernote.PersistentProcessorPayload();
      if (typeof obj == 'object' && obj) {
        for ( var i in obj) {
          if (typeof obj[i] != 'function'
              && typeof newObj.__proto__[i] != 'undefined') {
            newObj[i] = obj[i];
          }
        }
      }
      return newObj;
    }
  };
  Evernote.PersistentProcessorPayload.prototype.file = null;
  Evernote.PersistentProcessorPayload.prototype.path = null;
  Evernote.PersistentProcessorPayload.prototype.processResponse = null;
  Evernote.PersistentProcessorPayload.prototype.refresh = function() {
    Evernote.PersistentProcessorPayload.parent.refresh.apply(this, []);
    this.processResponse = null;
  };
  Evernote.PersistentProcessorPayload.prototype.toJSON = function() {
    var obj = Evernote.PersistentProcessorPayload.parent.toJSON.apply(this);
    obj["processResponse"] = this.processResponse;
    obj["path"] = this.path;
    return obj;
  };
  Evernote.PersistentProcessorPayload.prototype.toLOG = function() {
    var logObj = Evernote.PersistentProcessorPayload.parent.toLOG.apply(this);
    logObj["file"] = (this.file && this.file.name) ? this.file.name : null;
    logObj["path"] = this.path;
    logObj["hasProcessResponse"] = (this.processResponse) ? true : false;
    logObj["data"] = (typeof this.data == 'object' && this.data && typeof this.data["toLOG"] == 'function') ? this.data
        .toLOG()
        : this.data;
    return logObj;
  };
})();

/*
 * Evernote.AppModel
 * Evernote
 *
 * Created by Pavel Skaldin on 2/25/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
/**
 * I represent a basic Evernote.AppModel. My subclasses are more interesting
 * than me, and I keep a Registry for them in order to provide basic object
 * un/marshalling between server and client sides
 */
Evernote.AppModel = function AppModel(obj) {
  this.__defineGetter__("modelName", this.getModelName);
  this.initialize(obj);
};
Evernote.mixin(Evernote.AppModel, Evernote.DefiningMixin);
/**
 * Using FunctionOverrides
 */
Evernote.AppModel.prototype.handleInheritance = function(child, parent) {
  if (typeof child[Evernote.AppModel.CLASS_FIELD] == 'string') {
    Evernote.AppModel.Registry[child[Evernote.AppModel.CLASS_FIELD]] = child;
  }
};
// indicates whether model was updated...
Evernote.AppModel.prototype._updated = false;

/**
 * Deferred intialization
 */
Evernote.AppModel.prototype.initialize = function(obj) {
  if (obj != null && typeof obj == 'object') {
    for ( var i in obj) {
      var methName = "set" + (i.substring(0, 1).toUpperCase()) + i.substring(1);
      if (typeof this[methName] == 'function') {
        this[methName].apply(this, [ obj[i] ]);
      } else if (typeof this[i] != 'undefined' && i != "modelName") {
        try {
          this[i] = obj[i];
        } catch (e) {
        }
      }
    }
  }
};

/**
 * Description of a model, often used by getModelName() and getLabel() to
 * represent the model on canvas
 */
Evernote.AppModel.prototype.getModelName = function() {
  return this.constructor.name;
};

Evernote.AppModel.prototype.equals = function(model) {
  return (this == model);
};

Evernote.AppModel.prototype.serialize = function() {
  return JSON.stringify(this);
};
Evernote.AppModel.prototype.properties = function() {
  var props = new Array();
  for ( var i in this) {
    if (typeof this[i] != 'function') {
      props.push(i);
    }
  }
  return props;
};
Evernote.AppModel.prototype.methods = function() {
  var meths = new Array();
  for ( var i in this) {
    if (typeof this[i] == 'function' && i != 'constructor' && i != 'prototype') {
      meths.push(i);
    }
  }
  return meths;
};

/**
 * Answers object containing "storable" data. This is used to send to remote
 * services as part of automating translation between server side objects and
 * client side objects.
 */
Evernote.AppModel.prototype.toStorable = function(prefix) {
  var storable = {};
  var params = this.getStorableProps();
  prefix = (typeof prefix == 'string') ? prefix : "";
  for ( var i = 0; i < params.length; i++) {
    if (typeof this[params[i]] != 'undefined' && this[params[i]] != null)
      storable[prefix + params[i]] = this[params[i]];
  }
  return storable;
};
/**
 * toStorable uses this to retrieve names of fields of an instance that are
 * storable.
 */
Evernote.AppModel.prototype.getStorableProps = function() {
  var params = new Array();
  for ( var i in this) {
    if (this[i] != null
        && i.indexOf("_") != 0 // private props
        && i != "modelName"
        && (typeof this[i] == 'string' || typeof this[i] == 'number' || typeof this[i] == 'boolean'))
      params.push(i);
  }
  return params;
};
Evernote.AppModel.prototype.toJSON = function() {
  return this.toStorable();
};

/**
 * Holds references to subclasses of Evernote.AppModel so as to provide quick
 * and easy way to unmarshall classifiable objects. These are often produced by
 * other languages which would e.g. produce JSON strings with a specific field
 * identifying the kind of class the struct represents. i.e. {"javaClass":
 * "java.util.List", "list": [...]} This registry holds references to subclasses
 * of Evernote.AppModel that claim responsibility for handling those
 * identifiable structs.
 */
Evernote.AppModel.Registry = {};
Evernote.AppModel.registeredClasses = function() {
  var str = new Array();
  for ( var i in Evernote.AppModel.Registry) {
    str.push(i);
  }
  return str;
};
/**
 * Name of the object's field used to identify correlation between JSON struct
 * and typeof Evernote.AppModel
 */
Evernote.AppModel.CLASS_FIELD = "javaClass";
/**
 * Returns a serialized string representing given object. This string is
 * suitable for storage (local disk, etc). To re-construct the object from that
 * string, use Evernote.AppModel.unserializeStorable(str);
 * 
 * @param obj
 * @return
 */
Evernote.AppModel.serializeStorable = function(obj) {
  var storable = this.marshall(obj);
  if (obj.constructor[this.CLASS_FIELD]) {
    storable[this.CLASS_FIELD] = obj.constructor[this.CLASS_FIELD];
  }
  return JSON.stringify(storable);
};
/**
 * Unserializes a storable object from a string, unmarshalling it to produce an
 * appropriate instance of the object represented in given string. Use
 * Evernote.AppModel.serializeStorable(obj) to produce correctly serialized
 * strings.
 * 
 * @param str
 * @return
 */
Evernote.AppModel.unserializeStorable = function(str) {
  return this.unmarshall(JSON.parse(str));
};
/**
 * Unmarshalls obnj
 */
Evernote.AppModel.unmarshall = function(obj) {
  var newObj = null;
  if (!obj) {
    return obj;
  }
  if (typeof obj[Evernote.AppModel.CLASS_FIELD] == 'string'
      && typeof Evernote.AppModel.Registry[obj[Evernote.AppModel.CLASS_FIELD]] == 'function') {
    // LOG.debug("Found a function for class " +
    // obj[Evernote.AppModel.CLASS_FIELD]);
    var constr = Evernote.AppModel.Registry[obj[Evernote.AppModel.CLASS_FIELD]];
    newObj = new constr();
  } else if (obj[Evernote.AppModel.CLASS_FIELD]
      && obj[Evernote.AppModel.CLASS_FIELD].toLowerCase().indexOf("list") > 0
      && obj["list"] instanceof Array) {
    // LOG.debug("Found a list for class " +
    // obj[Evernote.AppModel.CLASS_FIELD]);
    newObj = new Array();
  } else if (typeof obj == 'string' || typeof obj == 'number'
      || typeof obj == 'boolean') {
    // LOG.debug("Object is a basic struct");
    return obj;
  } else if (obj instanceof Array) {
    // LOG.debug("Object is an array. Recursing..");
    newObj = new Array();
    for ( var i = 0; i < obj.length; i++) {
      newObj.push(Evernote.AppModel.unmarshall(obj[i]));
    }
    return newObj;
  } else {
    // LOG.debug("Creating a dummy for object");
    // create dummy Evernote.AppModel
    newObj = new this();
  }
  if (newObj) {
    for ( var i in obj) {
      // skip setters
      if (i.indexOf("set") == 0) {
        // LOG.debug("Skipping property that's a setter: " + i);
        continue;
      }
      var setterName = "set" + i.substring(0, 1).toUpperCase() + i.substring(1);
      if (typeof obj[i] == 'string' || typeof obj[i] == 'number'
          || typeof obj[i] == 'boolean') {
        if (typeof newObj[setterName] == 'function') {
          // LOG.debug("Calling setter: " + setterName);
          newObj[setterName].apply(newObj, [ obj[i] ]);
        } else {
          // LOG.debug("Setting property: " + i);
          newObj[i] = obj[i];
        }
      } else if (typeof obj[i] == 'object' && obj[i] != null) {
        // LOG.debug("Umarshalling object and assigning it to property");
        newObj[i] = Evernote.AppModel.unmarshall(obj[i]);
      }
    }
  }
  // LOG.debug("Done unmarshalling...");
  return newObj;
};
/**
 * Marshalls instance of Evernote.AppModel into a classifiable object. Custom
 * logic is implemented by the subclass's toStorable method - which should
 * return the expected structure.
 */
Evernote.AppModel.marshall = function(data) {
  if (data instanceof Array) {
    var newArray = new Array();
    for ( var i = 0; i < data.length; i++) {
      newArray.push(Evernote.AppModel._marshall(data[i]));
    }
    return newArray;
  } else {
    return Evernote.AppModel._marshall(data);
  }
};
Evernote.AppModel._marshall = function(data) {
  if (data && typeof data["toStorable"] == 'function') {
    return data.toStorable();
  } else {
    return data;
  }
};

/*
 * Evernote.AppDataModel
 * Evernote
 *
 * Created by Pavel Skaldin on 2/25/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
/**
 * My instances represent storable Models such as Notes, Notebooks, Tags,
 * SavedSearches etc
 * 
 * @param obj
 * @return
 */
Evernote.AppDataModel = function AppDataModel(obj) {
  this.initialize(obj);
};
Evernote.inherit(Evernote.AppDataModel, Evernote.AppModel);
Evernote.AppDataModel.prototype.guid = null;
Evernote.AppDataModel.prototype.updateSequenceNum = -1;

Evernote.AppDataModel.prototype.getLabel = function() {
  if (this.modelName) {
    return this.modelName;
  } else {
    return null;
  }
};
Evernote.AppDataModel.prototype.equals = function(model) {
  return (model instanceof Evernote.AppDataModel && (this.guid == model.guid && this.updateSequenceNum == model.updateSequenceNum));
};
Evernote.AppDataModel.prototype.toString = function() {
  return '[' + this.modelName + ':' + this.guid + ']';
};
Evernote.AppDataModel.prototype.toLOG = function() {
  return this;
};
Evernote.AppDataModel.toCSV = function(models) {
  var modelNames = new Array();
  for ( var i = 0; i < models.length; i++) {
    if (models[i] instanceof Evernote.AppDataModel)
      modelNames.push(models[i].modelName);
  }
  return modelNames.join(", ");
};

Evernote.AppDataModel.fromCSV = function(modelNames) {
  var modelArray = new Array();
  var models = modelNames.split(',');

  for ( var i = 0; i < models.length; i++) {
    if (models[i] instanceof Evernote.AppDataModel) {
      var modelName = Evernote.AppDataModel.trim(models[i]);
      if (modelName.length > 0) {
        modelArray.push(modelName);
      }
    }
  }

  return modelArray;
};

Evernote.AppDataModel.trim = function(modelName) {
  return modelName.replace(/^\s*/, "").replace(/\s*$/, "");
};

Evernote.AuthenticationToken = function() {
  this.__defineString__("shardId");
  this.__definePositiveInteger__("userId");
  this.__definePositiveInteger__("expiration");
  this.__definePositiveInteger__("created");
  this.__definePositiveInteger__("permissions");
  this.__defineString__("signature");
  this.__definePositiveInteger__("sharedNotebookId");
  this.__defineString__("apiKey");
  this.initialize();
};

Evernote.AuthenticationToken.javaClass = "com.evernote.service.AuthenticationToken";
Evernote.inherit(Evernote.AuthenticationToken, Evernote.AppModel);
Evernote.mixin(Evernote.AuthenticationToken, Evernote.DefiningMixin);

Evernote.AuthenticationToken.decode = function(str) {
  // S=s1:U=1fb:E=12f07f018c4:C=12ee3e394c4:P=7f:H=2a86db035d8f165fdc5460dd2fd91885
  var authToken = new Evernote.AuthenticationToken();
  var parts = str.split(":");
  for ( var i = 0; i < parts.length; i++) {
    var kv = parts[i].split("=");
    switch (kv[0]) {
      case "S":
        authToken.shardId = kv[1];
        break;
      case "U":
        authToken.userId = parseInt(kv[1], 16);
        break;
      case "E":
        authToken.expiration = parseInt(kv[1], 16);
        break;
      case "C":
        authToken.created = parseInt(kv[1], 16);
        break;
      case "P":
        authToken.permissions = parseInt(kv[1], 16);
        break;
      case "H":
        authToken.signature = kv[1];
        break;
      case "N":
        authToken.sharedNotebookId = parseInt(kv[1], 16);
        break;
      case "A":
        authToken.apiKey = kv[1];
        break;
    }
  }
  return authToken;
};

Evernote.AuthenticationToken.initialize = function() {
  // nothing to do
};

/*
 * Evernote.AuthenticationResult
 * Evernote
 *
 * Created by Pavel Skaldin on 2/25/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.AuthenticationResult = function AuthenticationResult(obj) {
  this.__defineGetter__("timestamp", this.getTimestamp);

  this.__defineGetter__("user", this.getUser);
  this.__defineSetter__("user", this.setUser);

  this.__defineGetter__("expiration", this.getExpiration);
  this.__defineSetter__("expiration", this.setExpiration);

  this.__defineGetter__("currentTime", this.getCurrentTime);
  this.__defineSetter__("currentTime", this.setCurrentTime);
  this.initialize(obj);
};
Evernote.AuthenticationResult.javaClass = "com.evernote.edam.userstore.AuthenticationResult";
Evernote.inherit(Evernote.AuthenticationResult, Evernote.AppModel);
Evernote.AuthenticationResult.prototype._expiration = null;
Evernote.AuthenticationResult.prototype._currentTime = null;
Evernote.AuthenticationResult.prototype.authenticationToken = null;
Evernote.AuthenticationResult.prototype._user = null;
/**
 * timestamp keeps epoch time of when currentTime is set making it possible to
 * compare relative expiration time
 */
Evernote.AuthenticationResult.prototype._timestamp = null;
/**
 * critical time holds default value indicating how many milliseconds before
 * expiration time that this authentication result is considered in critical
 * condition
 */
Evernote.AuthenticationResult.prototype.criticalTime = (1000 * 60 * 6);
Evernote.AuthenticationResult.prototype.getTimestamp = function() {
  return this._timestamp;
};
Evernote.AuthenticationResult.prototype.setCurrentTime = function(num) {
  if (num == null) {
    this._currentTime = null;
  } else if (typeof num == 'number') {
    this._currentTime = parseInt(num);
  }
  this._timestamp = new Date().getTime();
};
Evernote.AuthenticationResult.prototype.getCurrentTime = function() {
  return this._currentTime;
};
Evernote.AuthenticationResult.prototype.setUser = function(user) {
  if (user == null) {
    this._user = null;
  } else if (user instanceof Evernote.User) {
    this._user = user;
  }
};
Evernote.AuthenticationResult.prototype.getUser = function() {
  return this._user;
};
Evernote.AuthenticationResult.prototype.setExpiration = function(num) {
  if (num == null) {
    this._expiration = null;
  } else if (typeof num == 'number') {
    this._expiration = parseInt(num);
  }
};
Evernote.AuthenticationResult.prototype.getExpiration = function() {
  if (this._expiration && this.currentTime) {
    var delta = (this.timestamp) ? this.timestamp : 0;
    return ((this._expiration - this.currentTime) + delta);
  } else {
    return this._expiration;
  }
};
Evernote.AuthenticationResult.prototype.isExpiring = function() {
  var now = new Date().getTime();
  var critical = this.expiration - now - this.criticalTime;
  return (critical <= this.criticalTime);
};
Evernote.AuthenticationResult.prototype.isExpired = function() {
  var now = new Date().getTime();
  return (this.expiration <= now);
};
Evernote.AuthenticationResult.prototype.expire = function() {
  this.expiration = null;
  this.currentTime = null;
  this._timestamp = null;
};
Evernote.AuthenticationResult.prototype.isEmpty = function() {
  return (!(this.authenticationToken != null && this.user instanceof Evernote.User));
};

Evernote.BasicNote = function BasicNote(obj) {
  this.__defineGetter__("title", this.getTitle);
  this.__defineSetter__("title", this.setTitle);
  this.__defineString__("content");
  this.__defineString__("notebookGuid");
  this.__defineString__("comment");
  this.__definePositiveInteger__("created", 0);
  this.__definePositiveInteger__("updated", 0);
  this.initialize(obj);
};
Evernote.BasicNote.javaClass = "com.evernote.chromeExtension.BasicNote";
Evernote.inherit(Evernote.BasicNote, Evernote.AppDataModel);

Evernote.BasicNote.prototype.cleanTitle = function(title) {
  if (typeof title == 'string') {
    return title.replace(/[\n\r\t]+/, "").replace(/^\s+/, "").replace(/\s+$/,
        "");
  }
  return title;
};

Evernote.BasicNote.prototype.getTitle = function() {
  return this._title;
};

Evernote.BasicNote.prototype.setTitle = function(title, defaultTitle) {
  var newTitle = this.cleanTitle("" + title);
  if ((newTitle == null || newTitle.length == 0) && defaultTitle)
    newTitle = this.cleanTitle("" + defaultTitle);
  this._title = newTitle;
};

Evernote.BasicNote.prototype.getStorableProps = function() {
  return [ "title", "notebookGuid", "tagNames", "content", "comment",
      "created", "updated" ];
};
Evernote.BasicNote.prototype.toLOG = function() {
  return {
    title : this.title,
    notebookGuid : this.notebookGuid,
    tagNames : this.tagNames,
    created : this.created,
    updated : this.updated,
    contentLength : (this.content) ? this.content.length : 0,
    commentLength : (this.comment) ? this.comment.length : 0
  };
};

/*
 * Evernote.Note
 * Evernote
 *
 * Created by Pavel Skaldin on 2/25/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
/**
 * Note object as represented by the thrift model. A few convinience methods
 * were added...
 */
Evernote.Note = function Note(obj) {
  this.__defineBoolean__("active", false);
  this.__defineType__("attributes", "NoteAttributes");
  this.__defineType__("tagNames", "Array");
  this.__defineType__("tagGuids", "Array");
  this.initialize(obj);
};

Evernote.Note.javaClass = "com.evernote.edam.type.Note";
Evernote.inherit(Evernote.Note, Evernote.BasicNote);

Evernote.Note.prototype.NOTE_URL_PREFIX = "/view.jsp?";
Evernote.Note.prototype.DEFAULT_LOCALE = "default";

Evernote.Note.prototype.initialize = function(obj) {
  this.tagNames = [];
  this.tagGuids = [];
  Evernote.Note.parent.initialize.apply(this, [ obj ]);
};

Evernote.Note.prototype.getThumbnailUrl = function(shardUrl, size) {
  // /shard/s1/thm/note/f67f2848-f49d-493a-b94a-0275dac7f8c6
  shardUrl = shardUrl || "";
  var url = shardUrl + "/thm/note/" + this.guid;
  if (typeof size == 'number' && size > 0) {
    url += "?size=" + size;
  }
  return url;
};

Evernote.Note.prototype.getNoteUrl = function(shardUrl, shardId, searchWords,
    locale) {
  // /view.jsp?locale=default&shard=s1#v=t&n=8d3c87f9-6df9-4475-8ebc-45f336cf9757&b=0
  locale = locale || this.DEFAULT_LOCALE;
  shardUrl = shardUrl || "";
  var noteUrl = shardUrl.replace(/\/$/, "")
      + this.NOTE_URL_PREFIX
      + "locale="
      + locale
      + "&shard="
      + shardId
      + "#v=t&n="
      + this.guid
      + "&b="
      + ((this.notebookGuid) ? this.notebookGuid : 0)
      + ((typeof searchWords == 'string' && searchWords.length > 0) ? "&x="
          + encodeURI(searchWords) : "");
  return noteUrl;
};

Evernote.Note.prototype.hasLocation = function() {
  return (this.attributes != null
      && typeof this.attributes.longitude == 'number' && typeof this.attributes.latitude == 'number');
};

Evernote.Note.prototype.addTag = function(tag) {
  if (tag instanceof Evernote.Tag) {
    if (tag.name)
      this.tagNames.push(tag.name);
    if (tag.guid)
      this.tagGuids.push(tag.guid);
  }
};

Evernote.Note.prototype.getStorableProps = function() {
  var basicStorable = Evernote.Note.parent.getStorableProps.apply(this);
  return basicStorable
      .concat( [ "active", "attributes", "tagNames", "tagGuids" ]);
};
Evernote.Note.prototype.toLOG = function() {
  var logObj = Evernote.Note.parent.toLOG.apply(this);
  logObj["active"] = this.active;
  logObj["attributes"] = (this.attributes instanceof Evernote.NoteAttributes) ? this.attributes
      .toLOG()
      : this.attributes;
  logObj["tagNames"] = this.tagNames;
  logObj["tagGuids"] = this.tagGuids;
  return logObj;
};

Evernote.SnippetNote = function SnippetNote(obj) {
  this.__defineGetter__("snippet", this.getSnippet);
  this.__defineSetter__("snippet", this.setSnippet);
  this.initialize(obj);
};
Evernote.SnippetNote.javaClass = "com.evernote.web.SnippetNote";
Evernote.inherit(Evernote.SnippetNote, Evernote.Note, true);
Evernote.SnippetNote.prototype._snippet = null;
Evernote.SnippetNote.prototype.setSnippet = function(snippetText) {
  if (typeof snippetText == 'string' || snippetText == null) {
    this._snippet = snippetText;
  }
};
Evernote.SnippetNote.prototype.getSnippet = function() {
  return this._snippet;
};

/*
 * Evernote.NoteAttributes
 * Evernote
 *
 * Created by Pavel Skaldin on 2/25/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.NoteAttributes = function NoteAttributes(obj) {
  this.__defineGetter__("altitude", this.getAltitude);
  this.__defineSetter__("altitude", this.setAltitude);
  this.__defineGetter__("longitude", this.getLongitude);
  this.__defineSetter__("longitude", this.setLongitude);
  this.__defineGetter__("latitude", this.getLatitude);
  this.__defineSetter__("latitude", this.setLatitude);
  this.initialize(obj);
};

Evernote.NoteAttributes.WEB_CLIP = "web.clip";

Evernote.NoteAttributes.javaClass = 'com.evernote.edam.type.NoteAttributes';
Evernote.inherit(Evernote.NoteAttributes, Evernote.AppModel);
Evernote.NoteAttributes.prototype.author = null;
Evernote.NoteAttributes.prototype.sourceApplication = null;
Evernote.NoteAttributes.prototype.source = Evernote.NoteAttributes.WEB_CLIP;
Evernote.NoteAttributes.prototype.sourceURL = null;
Evernote.NoteAttributes.prototype.subjectDate = null;
Evernote.NoteAttributes.prototype._altitude = null;
Evernote.NoteAttributes.prototype._longitude = null;
Evernote.NoteAttributes.prototype._latitude = null;
Evernote.NoteAttributes.prototype.setAltitude = function(num) {
  if (typeof num == 'number' && !isNaN(num)) {
    this._altitude = num;
  } else if (num == null) {
    this._altitude = null;
  }
};
Evernote.NoteAttributes.prototype.getAltitude = function() {
  return this._altitude;
};
Evernote.NoteAttributes.prototype.setLongitude = function(num) {
  if (typeof num == 'number' && !isNaN(num)) {
    this._longitude = num;
  } else if (num == null) {
    this._longitude = null;
  }
};
Evernote.NoteAttributes.prototype.getLongitude = function() {
  this._longitude;
};
Evernote.NoteAttributes.prototype.setLatitude = function(num) {
  if (typeof num == 'number' && !isNaN(num)) {
    this._latitude = num;
  } else if (num == null) {
    this._latitude = null;
  }
};
Evernote.NoteAttributes.prototype.getLatitude = function() {
  return this._latitude;
};
Evernote.NoteAttributes.prototype.getStorableProps = function() {
  return [ "author", "sourceApplication", "source", "sourceURL", "altitude",
      "subjectDate", "longitude", "latitude" ];
};

/*
 * Evernote.Notebook
 * Evernote
 *
 * Created by Pavel Skaldin on 2/25/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.Notebook = function Notebook(obj) {
  this.__defineGetter__("defaultNotebook", this.isDefaultNotebook);
  this.__defineSetter__("defaultNotebook", this.setDefaultNotebook);
  this.__defineGetter__("name", this.getName);
  this.__defineSetter__("name", this.setName);
  this.__defineGetter__("publishing", this.getPublishing);
  this.__defineSetter__("publishing", this.setPublishing);
  this.initialize(obj);
};
Evernote.Notebook.javaClass = "com.evernote.edam.type.Notebook";
Evernote.inherit(Evernote.Notebook, Evernote.AppDataModel);
Evernote.Notebook.prototype._name = null;
Evernote.Notebook.prototype._defaultNotebook = false;
Evernote.Notebook.prototype._publishing = null;
Evernote.Notebook.prototype.setName = function(notebookName) {
  if (typeof notebookName == 'string')
    this._name = notebookName;
  else if (notebookName == null)
    this._name = null;
};
Evernote.Notebook.prototype.getName = function() {
  return this._name;
};
Evernote.Notebook.prototype.setDefaultNotebook = function(bool) {
  this._defaultNotebook = (bool) ? true : false;
};
Evernote.Notebook.prototype.isDefaultNotebook = function() {
  return this._defaultNotebook;
};
Evernote.Notebook.prototype.setPublishing = function(publishing) {
  // do nothing for now
};
Evernote.Notebook.prototype.getPublishing = function() {
  return this._publishing;
};
Evernote.Notebook.prototype.toString = function() {
  return '[' + this.modelName + ':' + this.guid + ':' + this.name + ']';
};

/*
 * Evernote.NoteFilter
 * Evernote
 *
 * Created by Pavel Skaldin on 3/29/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
NoteSortOrderTypes = {
  CREATED : 1,
  UPDATED : 2,
  RELEVANCE : 3,
  UPDATE_SEQUENCE_NUMBER : 4
};

/** ************** Evernote.NoteSortOrder *************** */
Evernote.NoteSortOrder = function NoteSortOrder(obj) {
  this.__defineGetter__("order", this.getOrder);
  this.__defineSetter__("order", this.setOrder);
  this.__defineGetter__("ascending", this.isAscending);
  this.__defineSetter__("ascending", this.setAscending);
  this.__defineGetter__("type", this.getType);
  this.initialize(obj);
};

Evernote.NoteSortOrder.isValidOrder = function(num) {
  if (typeof num == 'number') {
    for ( var t in NoteSortOrderTypes) {
      if (NoteSortOrderTypes[t] == num) {
        return true;
      }
    }
  }
  return false;
};
Evernote.NoteSortOrder.isValidType = function(orderType) {
  if (typeof orderType == 'string'
      && typeof NoteSortOrderTypes[orderType.toUpperCase()] == 'number') {
    return true;
  }
  return false;
};

Evernote.NoteSortOrder.prototype._order = NoteSortOrderTypes.CREATED;
Evernote.NoteSortOrder.prototype._ascending = false;
Evernote.NoteSortOrder.prototype.initialize = function(obj) {
  if (typeof obj == 'object' && obj != null) {
    for ( var i in obj) {
      if (typeof this[i] != 'undefined') {
        this[i] = obj[i];
      }
    }
  }
};
Evernote.NoteSortOrder.prototype.setOrder = function(order) {
  if (typeof order == 'number' && !isNaN(order)
      && Evernote.NoteSortOrder.isValidOrder(order)) {
    this._order = order;
  } else if (typeof order == 'string' && Evernote.NoteSortOrder.isValidType(order)) {
    this._order = NoteSortOrderTypes[order.toUpperCase()];
  } else {
    this._order = NoteSortOrderTypes.CREATED;
  }
};
Evernote.NoteSortOrder.prototype.getOrder = function() {
  return this._order;
};
Evernote.NoteSortOrder.prototype.getType = function() {
  if (this._order != null) {
    for ( var t in NoteSortOrderTypes) {
      if (NoteSortOrderTypes[t] == this._order) {
        return t;
      }
    }
  }
  return null;
};
Evernote.NoteSortOrder.prototype.setAscending = function(bool) {
  this._ascending = (bool) ? true : false;
};
Evernote.NoteSortOrder.prototype.isAscending = function() {
  return this._ascending;
};
Evernote.NoteSortOrder.prototype.toJSON = function() {
  return {
    order : this.order,
    ascending : this.ascending
  };
};

/** ************** Evernote.NoteFilter *************** */
Evernote.NoteFilter = function NoteFilter(obj) {
  this.__defineGetter__("order", this.getOrder);
  this.__defineSetter__("order", this.setOrder);
  this.__defineGetter__("ascending", this.isAscending);
  this.__defineSetter__("ascending", this.setAscending);
  this.__defineGetter__("words", this.getWords);
  this.__defineSetter__("words", this.setWords);
  this.__defineGetter__("notebookGuid", this.getNotebookGuid);
  this.__defineSetter__("notebookGuid", this.setNotebookGuid);
  this.__defineGetter__("tagGuids", this.getTagGuids);
  this.__defineSetter__("tagGuids", this.setTagGuids);
  this.__defineGetter__("timeZone", this.getTimeZone);
  this.__defineSetter__("timeZone", this.setTimeZone);
  this.__defineGetter__("inactive", this.isInactive);
  this.__defineSetter__("inactive", this.setInactive);
  this.__defineGetter__("fuzzy", this.isFuzzy);
  this.__defineSetter__("fuzzy", this.setFuzzy);
  this.initialize(obj);
};

Evernote.NoteFilter.javaClass = "com.evernote.edam.notestore.NoteFilter";
Evernote.inherit(Evernote.NoteFilter, Evernote.AppModel);

Evernote.NoteFilter.prototype._order = NoteSortOrderTypes.CREATED;
Evernote.NoteFilter.prototype._ascending = false;
Evernote.NoteFilter.prototype._words = null;
Evernote.NoteFilter.prototype._notebookGuid = null;
Evernote.NoteFilter.prototype._tagGuids = null;
Evernote.NoteFilter.prototype._timeZone = null;
Evernote.NoteFilter.prototype._inactive = false;
Evernote.NoteFilter.prototype._fuzzy = false;

Evernote.NoteFilter.prototype.getOrder = function() {
  return this._order;
};
Evernote.NoteFilter.prototype.setOrder = function(order) {
  this._order = Math.max(parseInt(order), 1);
};
Evernote.NoteFilter.prototype.isAscending = function() {
  return this._ascending;
};
Evernote.NoteFilter.prototype.setAscending = function(bool) {
  this._ascending = (bool) ? true : false;
};
Evernote.NoteFilter.prototype.getWords = function() {
  return this._words;
};
Evernote.NoteFilter.prototype.setWords = function(words) {
  if (words == null) {
    this._words = null;
  } else {
    var wordArray = (words instanceof Array) ? words : Evernote.NoteFilter
        .separateWords((words + ""));
    if (wordArray instanceof Array && wordArray.length > 0) {
      if (this.fuzzy) {
        var newWords = new Array();
        for ( var i = 0; i < wordArray.length; i++) {
          newWords.push(Evernote.NoteFilter.makeWordFuzzy(wordArray[i]));
        }
        if (newWords.length > 0) {
          this._words = newWords.join(" ");
        }
      } else {
        this._words = wordArray.join(" ");
      }
    }
  }
};
Evernote.NoteFilter.prototype.getNotebookGuid = function() {
  return this._notebookGuid;
};
Evernote.NoteFilter.prototype.setNotebookGuid = function(guid) {
  if (typeof guid == 'string' && guid.length > 0)
    this._notebookGuid = guid;
  else if (guid == null)
    this._notebookGuid = null;
};
Evernote.NoteFilter.prototype.getTagGuids = function() {
  return this._tagGuids;
};
Evernote.NoteFilter.prototype.setTagGuids = function(guids) {
  if (guids instanceof Array)
    this._tagGuids = guids;
  else if (typeof guids == 'string')
    this._tagGuids = new Array(guids);
  else if (guids == null)
    this._tagGuids = null;
};
Evernote.NoteFilter.prototype.getTimeZone = function() {
  return this._timeZone;
};
Evernote.NoteFilter.prototype.setTimeZone = function(tz) {
  if (typeof tz == 'string')
    this._timeZone = tz;
  else if (tz == null)
    this._timeZone = null;
};
Evernote.NoteFilter.prototype.isInactive = function() {
  return this._inactive;
};
Evernote.NoteFilter.prototype.setInactive = function(bool) {
  this._inactive = (bool) ? true : false;
};
Evernote.NoteFilter.prototype.setFuzzy = function(bool) {
  this._fuzzy = (bool) ? true : false;
};
Evernote.NoteFilter.prototype.isFuzzy = function() {
  return this._fuzzy;
};
Evernote.NoteFilter.prototype.isEmpty = function() {
  return (this._words == null && this._notebookGuid == null
      && this._tagGuids == null && this._timeZone == null);
};
Evernote.NoteFilter.prototype.resetQuery = function() {
  this.words = null;
  this.tagGuids = null;
  this.notebookGuid = null;
  this.inactive = false;
  this.timeZone = null;
};
/**
 * Separates given string by given separator (defaults to
 * Evernote.NoteFilter.WORD_SEPARATOR). Returns array of words found. Keeps quoted words
 * together. If quote charater is not given, defaults to Evernote.NoteFilter.QUOTE.
 */
Evernote.NoteFilter.WORD_SEPARATOR = " ";
Evernote.NoteFilter.QUOTE = '"';
Evernote.NoteFilter.TOKEN_SEPARATOR = ":";
Evernote.NoteFilter.FUZZY_SUFFIX = "*";
Evernote.NoteFilter.RESERVED_TOKENS = [ "any", "notebook", "tag", "intitle", "created",
    "updated", "resource", "subjectDate", "latitude", "longitude", "altitude",
    "author", "source", "sourceApplication", "recoType", "todo" ];
Evernote.NoteFilter.separateWords = function(str, separator, quote) {
  if (typeof separator == 'undefined' || separator == null) {
    separator = Evernote.NoteFilter.WORD_SEPARATOR;
  }
  if (typeof quote == 'undefined' || quote == null) {
    quote = Evernote.NoteFilter.QUOTE;
  }
  var words = new Array();
  var i = 0;
  var buffer = "";
  var quoted = false;
  function addWord(word) {
    if (word) {
      word = word.replace(/^\s+/, "").replace(/\s+$/, "");
      if (word.length > 0) {
        words.push(word);
      }
    }
  }
  str = str.replace(/^\s+/, "").replace(/\s+$/, "");
  while (i < str.length) {
    var c = str.charAt(i);
    if (c == quote) {
      buffer += c;
      quoted = !quoted;
    } else if (!quoted && c == separator) {
      addWord(buffer);
      buffer = "";
    } else {
      buffer += c;
    }
    i++;
  }
  if (buffer.length > 0)
    addWord(buffer);
  return words;
};
Evernote.NoteFilter.isWordFuzzy = function(word) {
  return (typeof word == 'string' && word.charAt(word.length - 1) == Evernote.NoteFilter.FUZZY_SUFFIX);
};
Evernote.NoteFilter.canWordBeFuzzy = function(word) {
  if (typeof word == 'string' && word.length > 0 && word.indexOf(" ") < 0
      && word.indexOf(Evernote.NoteFilter.QUOTE) < 0 && !Evernote.NoteFilter.isWordFuzzy(word)) {
    if (word.indexOf(Evernote.NoteFilter.TOKEN_SEPARATOR) <= 0) {
      return true;
    } else {
      var w = word.toLowerCase();
      for ( var i = 0; i < Evernote.NoteFilter.RESERVED_TOKENS.length; i++) {
        var re = new RegExp("^-?" + Evernote.NoteFilter.RESERVED_TOKENS[i]
            + Evernote.NoteFilter.TOKEN_SEPARATOR);
        if (w.match(re)) {
          return false;
        }
      }
      return true;
    }
  }
  return false;
};
Evernote.NoteFilter.makeWordFuzzy = function(word) {
  if (Evernote.NoteFilter.canWordBeFuzzy(word))
    word += Evernote.NoteFilter.FUZZY_SUFFIX;
  return word;
};
Evernote.NoteFilter.formatWord = function(str) {
  if (str.indexOf(Evernote.NoteFilter.WORD_SEPARATOR) > 0) {
    return Evernote.NoteFilter.QUOTE + str + Evernote.NoteFilter.QUOTE;
  } else {
    return str;
  }
};
Evernote.NoteFilter.isWordQuoted = function(word) {
  return (typeof word == 'string' && word.length > 2
      && word.indexOf(Evernote.NoteFilter.QUOTE) == 0 && word.indexOf(Evernote.NoteFilter.QUOTE,
      1) == (word.length - 1));
};
Evernote.NoteFilter.unquoteWord = function(word) {
  if (Evernote.NoteFilter.isWordQuoted(word)) {
    return word.substring(1, (word.length - 1));
  } else {
    return word;
  }
};
Evernote.NoteFilter.extractTokenValue = function(token, word) {
  if (typeof word == 'string' && typeof token == 'string') {
    var x = word.indexOf(token + Evernote.NoteFilter.TOKEN_SEPARATOR);
    if (x >= 0 && x <= 1) {
      return Evernote.NoteFilter.unquoteWord(word.substring(x + token.length
          + Evernote.NoteFilter.TOKEN_SEPARATOR.length));
    }
  }
  return null;
};

Evernote.NoteFilter.prototype.getStorableProps = function() {
  return [ "order", "ascending", "words", "notebookGuid", "tagGuids",
      "timeZone", "inactive" ];
};


/*
 * Evernote.NoteList
 * Evernote
 *
 * Created by Pavel Skaldin on 3/29/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.NoteList = function NoteList(obj) {
  this.__defineGetter__("notes", this.getNotes);
  this.__defineSetter__("notes", this.setNotes);
  this.__defineGetter__("searchedWords", this.getSearchedWords);
  this.__defineSetter__("searchedWords", this.setSearchedWords);
  this.__defineGetter__("stoppedWords", this.getStoppedWords);
  this.__defineSetter__("stoppedWords", this.setStoppedWords);
  this.__defineGetter__("startIndex", this.getStartIndex);
  this.__defineSetter__("startIndex", this.setStartIndex);
  this.__defineGetter__("endIndex", this.getEndIndex);
  this.__defineGetter__("nextIndex", this.getNextIndex);
  this.__defineGetter__("remainingCount", this.getRemainingCount);
  this.__defineGetter__("totalNotes", this.getTotalNotes);
  this.__defineSetter__("totalNotes", this.setTotalNotes);
  this.initialize(obj);
  this.initializeNotes();
  this.initializeSearchedWords();
  this.initializeStoppedWords();
};

Evernote.NoteList.javaClass = "com.evernote.edam.notestore.NoteList";
Evernote.inherit(Evernote.NoteList, Evernote.AppModel);

Evernote.NoteList.prototype._notes = null;
Evernote.NoteList.prototype._searchedWords = null;
Evernote.NoteList.prototype._stoppedWords = null;
Evernote.NoteList.prototype._startIndex = 0;
Evernote.NoteList.prototype._totalNotes = 0;

Evernote.NoteList.prototype.initializeNotes = function() {
  this._notes = new Array();
};

Evernote.NoteList.prototype.initializeSearchedWords = function() {
  this._searchedWords = new Array();
};
Evernote.NoteList.prototype.initializeStoppedWords = function() {
  this._stoppedWords = new Array();
};

Evernote.NoteList.prototype.setNotes = function(notes) {
  if (notes instanceof Array) {
    this._notes = notes;
  } else if (notes instanceof Evernote.Note) {
    this._notes = new Array(notes);
  } else if (notes == null) {
    this._notes = new Array();
  }
};
Evernote.NoteList.prototype.getNotes = function() {
  return this._notes;
};
Evernote.NoteList.prototype.setSearchedWords = function(words) {
  if (words instanceof Array) {
    this._searchedWords = words;
  } else if (words != null) {
    this._searchedWords = new Array(words + "");
  } else if (words == null) {
    this._searchedWords = new Array();
  }
};
Evernote.NoteList.prototype.getSearchedWords = function() {
  return this._searchedWords;
};
Evernote.NoteList.prototype.setStoppedWords = function(words) {
  if (words instanceof Array) {
    this._stoppedWords = words;
  } else if (words != null) {
    this._stoppedWords = new Array(words + "");
  } else if (words == null) {
    this._stoppedWords = new Array();
  }
};
Evernote.NoteList.prototype.getStoppedWords = function() {
  return this._stoppedWords;
};
Evernote.NoteList.prototype.setStartIndex = function(index) {
  this._startIndex = parseInt(index);
};
Evernote.NoteList.prototype.getStartIndex = function() {
  return this._startIndex;
};
Evernote.NoteList.prototype.getEndIndex = function() {
  return this.startIndex + this.notes.length - 1;
};
Evernote.NoteList.prototype.getNextIndex = function() {
  if (this.isAtEnd())
    return null;
  return this.startIndex + this.notes.length;
};
Evernote.NoteList.prototype.getRemainingCount = function() {
  return this.totalNotes - this.nextIndex;
};
Evernote.NoteList.prototype.setTotalNotes = function(count) {
  this._totalNotes = parseInt(count);
};
Evernote.NoteList.prototype.getTotalNotes = function() {
  return this._totalNotes;
};
Evernote.NoteList.prototype.isAtEnd = function() {
  return (this.totalNotes <= this.startIndex + this.notes.length);
};
Evernote.NoteList.prototype.isAtStart = function() {
  return (this.startIndex == 0);
};
Evernote.NoteList.prototype.getStorableProps = function() {
  return [ "notes", "searchedWords", "stoppedWords", "startIndex", "totalNotes" ];
};

/*
 * Evernote.SavedSearch
 * Evernote
 *
 * Created by Pavel Skaldin on 2/25/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.SavedSearch = function SavedSearch(obj) {
  this.__defineGetter__("query", this.getQuery);
  this.__defineSetter__("query", this.setQuery);
  this.__defineGetter__("format", this.getFormat);
  this.__defineSetter__("format", this.setFormat);
  this.__defineGetter__("name", this.getName);
  this.__defineSetter__("name", this.setName);
  this.initialize(obj);
};
Evernote.SavedSearch.javaClass = "com.evernote.edam.type.SavedSearch";
Evernote.inherit(Evernote.SavedSearch, Evernote.AppDataModel);
Evernote.SavedSearch.prototype._query = null;
Evernote.SavedSearch.prototype._format = 1;
Evernote.SavedSearch.prototype._name = null;

Evernote.SavedSearch.prototype.getQuery = function() {
  return this._query;
};
Evernote.SavedSearch.prototype.setQuery = function(q) {
  if (q == null)
    this._query = null;
  else
    this._query = q + "";
};
Evernote.SavedSearch.prototype.getFormat = function() {
  return this._format;
};
Evernote.SavedSearch.prototype.setFormat = function(f) {
  this._format = Math.max(parseInt(f), 1);
};
Evernote.SavedSearch.prototype.setName = function(name) {
  if (name == null) {
    this._name = null;
  } else {
    this._name = name + "";
  }
};
Evernote.SavedSearch.prototype.getName = function() {
  return this._name;
};

QueryFormat = {
  USER : 1,
  SEXP : 2
};

/*
 * Evernote.SyncChunk
 * Evernote
 *
 * Created by Pavel Skaldin on 3/10/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
/**
 * My instances represent Evernote.SyncChunk
 * 
 * @param obj
 * @return
 */
Evernote.SyncChunk = function SyncChunk(obj) {
  this.__defineGetter__("chunkHighUSN", this.getChunkHighUSN);
  this.__defineSetter__("chunkHighUSN", this.setChunkHighUSN);
  this.__defineGetter__("currentTime", this.getCurrentTime);
  this.__defineSetter__("currentTime", this.setCurrentTime);
  this.__defineGetter__("expungedNotebooks", this.getExpungedNotebooks);
  this.__defineSetter__("expungedNotebooks", this.setExpungedNotebooks);
  this.__defineGetter__("expungedNotes", this.getExpungedNotes);
  this.__defineSetter__("expungedNotes", this.setExpungedNotes);
  this.__defineGetter__("expungedSearches", this.getExpungedSearches);
  this.__defineSetter__("expungedSearches", this.setExpungedSearches);
  this.__defineGetter__("expungedTags", this.getExpungedTags);
  this.__defineSetter__("expungedTags", this.setExpungedTags);
  this.__defineGetter__("notebooks", this.getNotebooks);
  this.__defineSetter__("notebooks", this.setNotebooks);
  this.__defineGetter__("notes", this.getNotes);
  this.__defineSetter__("notes", this.setNotes);
  this.__defineGetter__("searches", this.getSearches);
  this.__defineSetter__("searches", this.setSearches);
  this.__defineGetter__("tags", this.getTags);
  this.__defineSetter__("tags", this.setTags);
  this.__defineGetter__("updateCount", this.getUpdateCount);
  this.__defineSetter__("updateCount", this.setUpdateCount);
  this.initialize(obj);
};
Evernote.SyncChunk.javaClass = "com.evernote.edam.notestore.SyncChunk";
Evernote.inherit(Evernote.SyncChunk, Evernote.AppModel);
Evernote.SyncChunk.prototype._chunkHighUSN = null;
Evernote.SyncChunk.prototype._currentTime = null;
Evernote.SyncChunk.prototype._expungedNotebooks = new Array();
Evernote.SyncChunk.prototype._expungedNotes = new Array();
Evernote.SyncChunk.prototype._expungedSearches = new Array();
Evernote.SyncChunk.prototype._expungedTags = new Array();
Evernote.SyncChunk.prototype._notebooks = new Array();
Evernote.SyncChunk.prototype._notes = new Array();
Evernote.SyncChunk.prototype._searches = new Array();
Evernote.SyncChunk.prototype._tags = new Array();
Evernote.SyncChunk.prototype._updateCount = null;

Evernote.SyncChunk.prototype.getChunkHighUSN = function() {
  return this._chunkHighUSN;
};
Evernote.SyncChunk.prototype.setChunkHighUSN = function(num) {
  this._chunkHighUSN = parseInt(num);
};
Evernote.SyncChunk.prototype.getCurrentTime = function() {
  return this._currentTime;
};
Evernote.SyncChunk.prototype.setCurrentTime = function(millis) {
  this._currentTime = parseInt(millis);
};
Evernote.SyncChunk.prototype.getExpungedNotebooks = function() {
  return this._expungedNotebooks;
};
Evernote.SyncChunk.prototype.setExpungedNotebooks = function(notebooks) {
  if (notebooks == null)
    this._expungedNotebooks = new Array();
  else
    this._expungedNotebooks = (notebooks instanceof Array) ? notebooks
        : [ notebooks ];
};
Evernote.SyncChunk.prototype.getExpungedNotes = function() {
  return this._expungedNotes;
};
Evernote.SyncChunk.prototype.setExpungedNotes = function(notes) {
  if (notes == null)
    this._expungedNotes = new Array();
  else
    this._expungedNotes = (notes instanceof Array) ? notes : [ notes ];
};
Evernote.SyncChunk.prototype.getExpungedSearches = function() {
  return this._expungedSearches;
};
Evernote.SyncChunk.prototype.setExpungedSearches = function(searches) {
  if (searches == null)
    this._expungedSearches = new Array();
  else
    this._expungedSearches = (searches instanceof Array) ? searches
        : [ searches ];
};
Evernote.SyncChunk.prototype.getExpungedTags = function() {
  return this._expungedTags;
};
Evernote.SyncChunk.prototype.setExpungedTags = function(tags) {
  if (tags == null)
    this._expungedTags = new Array();
  else
    this._expungedTags = (tags instanceof Array) ? tags : [ tags ];
};
Evernote.SyncChunk.prototype.getNotebooks = function() {
  return this._notebooks;
};
Evernote.SyncChunk.prototype.setNotebooks = function(notebooks) {
  if (notebooks == null)
    this._notebooks = new Array();
  else
    this._notebooks = (notebooks instanceof Array) ? notebooks : [ notebooks ];
};
Evernote.SyncChunk.prototype.getNotes = function() {
  return this._notes;
};
Evernote.SyncChunk.prototype.setNotes = function(notes) {
  if (notes == null)
    this._notes = new Array();
  else
    this._notes = (notes instanceof Array) ? notes : [ notes ];
};
Evernote.SyncChunk.prototype.getSearches = function() {
  return this._searches;
};
Evernote.SyncChunk.prototype.setSearches = function(searches) {
  if (searches == null)
    this._searches = new Array();
  else
    this._searches = (searches instanceof Array) ? searches : new Array();
};
Evernote.SyncChunk.prototype.getTags = function() {
  return this._tags;
};
Evernote.SyncChunk.prototype.setTags = function(tags) {
  if (tags == null)
    this._tags = new Array();
  else
    this._tags = (tags instanceof Array) ? tags : [ tags ];
};
Evernote.SyncChunk.prototype.getUpdateCount = function() {
  return this._updateCount;
};
Evernote.SyncChunk.prototype.setUpdateCount = function(num) {
  this._updateCount = parseInt(num);
};

Evernote.SyncChunk.prototype.setResources = function(resources) {
  // do nothing yet
};

Evernote.SyncChunk.prototype.toString = function() {
  return "Evernote.SyncChunk " + this.updateCount;
};

/*
 * Evernote.SyncState
 * Evernote
 *
 * Created by Pavel Skaldin on 2/25/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
/**
 * My instances represent Evernote.SyncState
 * 
 * @param obj
 * @return
 */
Evernote.SyncState = function SyncState(obj) {
  this.__defineGetter__("currentTime", this.getCurrentTime);
  this.__defineSetter__("currentTime", this.setCurrentTime);
  this.__defineGetter__("fullSyncBefore", this.getFullSyncBefore);
  this.__defineSetter__("fullSyncBefore", this.setFullSyncBefore);
  this.__defineGetter__("updateCount", this.getUpdateCount);
  this.__defineSetter__("updateCount", this.setUpdateCount);
  this.__defineGetter__("uploaded", this.getUploaded);
  this.__defineSetter__("uploaded", this.setUploaded);
  this.initialize(obj);
};
Evernote.SyncState.javaClass = "com.evernote.edam.notestore.SyncState";
Evernote.inherit(Evernote.SyncState, Evernote.AppModel);
Evernote.SyncState.prototype._currentTime = null;
Evernote.SyncState.prototype._fullSyncBefore = null;
Evernote.SyncState.prototype._updateCount = null;
Evernote.SyncState.prototype._uploaded = null;
Evernote.SyncState.prototype.getUpdateCount = function() {
  return this._updateCount;
};
Evernote.SyncState.prototype.setUpdateCount = function(num) {
  if (num == null)
    this._updateCount = null;
  else
    this._updateCount = parseInt(num);
};
Evernote.SyncState.prototype.getFullSyncBefore = function() {
  return this._fullSyncBefore;
};
Evernote.SyncState.prototype.setFullSyncBefore = function(num) {
  if (num == null)
    this._fullSyncBefore = null;
  else
    this._fullSyncBefore = parseInt(num);
};
Evernote.SyncState.prototype.getCurrentTime = function() {
  return this._currentTime;
};
Evernote.SyncState.prototype.setCurrentTime = function(num) {
  if (num == null)
    this._currentTime = null;
  else
    this._currentTime = parseInt(num);
};
Evernote.SyncState.prototype.getUploaded = function() {
  return this._uploaded;
};
Evernote.SyncState.prototype.setUploaded = function(num) {
  if (num == null)
    this._uploaded = null;
  else
    this._uploaded = parseInt(num);
};
Evernote.SyncState.prototype.isFullSyncRequired = function() {
  return (this.currentTime != null && this.fullSyncBefore != null && this.currentTime < this.fullSyncBefore);
};
Evernote.SyncState.prototype.toString = function() {
  return "Evernote.SyncState " + this.updateCount;
};


/*
 * Evernote.Tag
 * Evernote
 *
 * Created by Pavel Skaldin on 2/25/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.Tag = function Tag(obj) {
  this.__defineGetter__("name", this.getName);
  this.__defineSetter__("name", this.setName);
  this.initialize(obj);
};

Evernote.Tag.javaClass = "com.evernote.edam.type.Tag";
Evernote.inherit(Evernote.Tag, Evernote.AppDataModel);
Evernote.Tag.prototype._name = null;
Evernote.Tag.prototype.setName = function(tagName) {
  if (typeof tagName == 'undefined' || tagName == null) {
    this._name = null;
  } else {
    this._name = "" + tagName;
  }
};
Evernote.Tag.prototype.getName = function() {
  return this._name;
};
Evernote.Tag.prototype.toString = function() {
  return '[' + this.modelName + ':' + this.guid + ':' + this.name + ']';
};

/*
 * Evernote.User
 * Evernote
 *
 * Created by Pavel Skaldin on 2/25/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.User = function User(obj) {
  this.__defineGetter__("id", this.getId);
  this.__defineSetter__("id", this.setId);

  this.__defineGetter__("created", this.getCreated);
  this.__defineSetter__("created", this.setCreated);

  this.__defineGetter__("updated", this.getUpdated);
  this.__defineSetter__("updated", this.setUpdated);

  this.__defineGetter__("deleted", this.getDeleted);
  this.__defineSetter__("deleted", this.setDeleted);

  this.__defineGetter__("active", this.isActive);
  this.__defineSetter__("active", this.setActive);

  this.__defineGetter__("attributes", this.getAttributes);
  this.__defineSetter__("attributes", this.setAttributes);

  this.__defineGetter__("accounting", this.getAccounting);
  this.__defineSetter__("accounting", this.setAccounting);

  this.initialize(obj);
};
Evernote.User.javaClass = "com.evernote.edam.type.User";
Evernote.inherit(Evernote.User, Evernote.AppModel);
Evernote.User.prototype._id = null;
Evernote.User.prototype.username = null;
Evernote.User.prototype.email = null;
Evernote.User.prototype.name = null;
Evernote.User.prototype.timezone = null;
Evernote.User.prototype.privilege = null;
Evernote.User.prototype._created = null;
Evernote.User.prototype._updated = null;
Evernote.User.prototype._deleted = null;
Evernote.User.prototype._active = false;
Evernote.User.prototype.shardId = null;
Evernote.User.prototype._attributes = null;
Evernote.User.prototype._accounting = null;

Evernote.User.prototype.setId = function(id) {
  if (id == null) {
    this._id == null;
  } else if (typeof id == 'number') {
    this._id = parseInt(id);
  }
};
Evernote.User.prototype.getId = function() {
  return this._id;
};
Evernote.User.prototype.setActive = function(bool) {
  this._active = (bool) ? true : false;
};
Evernote.User.prototype.isActive = function() {
  return this._active;
};
Evernote.User.prototype.setCreated = function(num) {
  if (num == null) {
    this._created = null;
  } else if (typeof num == 'number') {
    this._created = parseInt(num);
  }
};
Evernote.User.prototype.getCreated = function() {
  return this._created;
};
Evernote.User.prototype.setUpdated = function(num) {
  if (num == null) {
    this._updated = null;
  } else if (typeof num == 'number') {
    this._updated = parseInt(num);
  }
};
Evernote.User.prototype.getUpdated = function() {
  return this._updated;
};
Evernote.User.prototype.setDeleted = function(num) {
  if (num == null) {
    this._deleted = null;
  } else if (typeof num == 'number') {
    this._deleted = parseInt(num);
  }
};
Evernote.User.prototype.getDeleted = function() {
  return this._deleted;
};
Evernote.User.prototype.setAccounting = function(accounting) {
  // do nothing for now
};
Evernote.User.prototype.getAccounting = function() {
  return this._accounting;
};
Evernote.User.prototype.setAttributes = function(attrs) {
  // do nothing for now
};
Evernote.User.prototype.getAttributes = function() {
  return this._attributes;
};

Evernote.Data = function Data(obj) {
  this.__definePositiveInteger__("size", 0);
  this.initialize(obj);
};
Evernote.Data.javaClass = "com.evernote.edam.type.Data";
Evernote.inherit(Evernote.Data, Evernote.AppDataModel);

Evernote.ResourceAttributes = function ResourceAttributes(obj) {
  this.__defineFloat__("altitude");
  this.__defineBoolean__("attachment", false);
  this.__defineString__("cameraMake");
  this.__defineString__("cameraModel");
  this.__defineBoolean__("clientWillIndex");
  this.__defineString__("fieldName");
  this.__defineFloat__("latitude");
  this.__defineFloat__("longitude");
  this.__defineString__("recoType");
  this.__defineString__("sourceUrl");
  this.__definePositiveInteger__("timestamp");
  this.initialize(obj);
};
Evernote.ResourceAttributes.javaClass = "com.evernote.edam.type.ResourceAttributes";
Evernote.inherit(Evernote.ResourceAttributes, Evernote.AppDataModel);

Evernote.Resource = function Resource(obj) {
  this.__defineBoolean__("active", false);
  this.__defineType__("attributes", Evernote.ResourceAttributes);
  this.__defineType__("data", "Data");
  this.__definePositiveInteger__("duration", 0);
  this.__definePositiveInteger__("height", 0);
  this.__definePositiveInteger__("width", 0);
  this.__defineString__("mime");
  this.__defineString__("noteGuid");
  this.initialize(obj);
};
Evernote.Resource.javaClass = "com.evernote.edam.type.Resource";
Evernote.inherit(Evernote.Resource, Evernote.AppDataModel);

Evernote.Resource.prototype.getThumbnailUrl = function(shardUrl, size) {
  shardUrl = shardUrl || "";
  var url = shardUrl + "/thm/res/" + this.guid;
  if (typeof size == 'number' && size > 0) {
    url += "?size=" + size;
  }
  return url;
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

Evernote.Utils = Evernote.Utils || new function Utils() {
};

Evernote.Utils.MESSAGE_ATTR = "message";
Evernote.Utils.MESSAGE_DATA_ATTR = "messagedata";
Evernote.Utils.LOCALIZED_ATTR = "localized";
Evernote.Utils.BADGE_AUTOSAVED_TEXT = "+";
Evernote.Utils.BADGE_NORMAL_COLOR = [ 255, 0, 0, 255 ];
Evernote.Utils.BADGE_UPLOADING_COLOR = [ 255, 255, 0, 255 ];

Evernote.Utils.updateBadge = function(context, tabId) {
  var LOG = Evernote.chromeExtension.logger;
  LOG.debug("Utils.updateBadge");
  var sh = null;
  if (context) {
    if (context.clipProcessor.length > 0) {
      Evernote.Utils.setBadgeBackgroundColor(
          Evernote.Utils.BADGE_UPLOADING_COLOR, tabId);
      LOG.debug("Badge indicates pending notes: "
          + context.clipProcessor.length);
      Evernote.Utils.setBadgeText(context.clipProcessor.length, tabId);
      Evernote.Utils.setBadgeTitle(chrome.i18n
          .getMessage("BrowserActionTitlePending"), tabId);
    } else if (typeof tabId == 'number'
        && chrome.extension
        && typeof chrome.extension.getBackgroundPage().Evernote.SearchHelper != 'undefined'
        && (sh = chrome.extension.getBackgroundPage().Evernote.SearchHelper
            .getInstance(tabId)) && sh.hasResults()) {
      Evernote.Utils.setBadgeBackgroundColor(Evernote.Utils.BADGE_NORMAL_COLOR,
          tabId);
      LOG.debug("Badge indicates simsearch results: " + sh.result.totalNotes);
      Evernote.Utils.setBadgeText(sh.result.totalNotes, tabId);
      Evernote.Utils.setBadgeTitle(
          chrome.i18n.getMessage("BrowserActionTitle"), tabId);
    } else if (context.hasAutosavedNote()) {
      Evernote.Utils.setBadgeBackgroundColor(Evernote.Utils.BADGE_NORMAL_COLOR,
          tabId);
      LOG.debug("Badge indicates auto-saved note");
      Evernote.Utils.setBadgeText(Evernote.Utils.BADGE_AUTOSAVED_TEXT, tabId);
      Evernote.Utils.setBadgeTitle(chrome.i18n
          .getMessage("BrowserActionTitleUnsaved"), tabId);
    } else {
      LOG.debug("Clearing badge for there's nothing interesting to show");
      Evernote.Utils.clearBadge(tabId);
      Evernote.Utils.setBadgeTitle(
          chrome.i18n.getMessage("BrowserActionTitle"), tabId);
    }
  }
};

Evernote.Utils.clearBadge = function(tabId) {
  var o = {
    text : ""
  };
  if (typeof tabId == 'number') {
    o["tabId"] = tabId;
    chrome.browserAction.setBadgeText(o);
  } else {
    this.clearAllBadges();
  }
};

Evernote.Utils.clearAllBadges = function() {
  this.doInEveryNormalTab(function(tab) {
    chrome.browserAction.setBadgeText( {
      tabId : tab.id,
      text : ""
    });
  }, true);
};

Evernote.Utils.setBadgeBackgroundColor = function(color, tabId) {
  var o = {
    color : color
  };
  if (typeof tabId == 'number') {
    o["tabId"] = tabId;
    chrome.browserAction.setBadgeBackgroundColor(o);
  } else {
    this.doInEveryNormalTab(function(tab) {
      o.tabId = tab.id;
      chrome.browserAction.setBadgeBackgroundColor(o);
    }, true);
  }
};

Evernote.Utils.setBadgeText = function(txt, tabId) {
  if (txt) {
    var o = {
      text : "" + txt
    };
    if (typeof tabId == 'number') {
      o["tabId"] = tabId;
      chrome.browserAction.setBadgeText(o);
    } else {
      this.doInEveryNormalTab(function(tab) {
        console.log("Setting badge in tab id: " + tab.id);
        o.tabId = tab.id;
        chrome.browserAction.setBadgeText(o);
      }, true);
    }
  } else if (txt == null) {
    Evernote.Utils.clearBadge(tabId);
  }
};

Evernote.Utils.setBadgeTitle = function(title, tabId) {
  if (title) {
    var o = {
      title : "" + title
    };
    if (typeof tabId == 'number') {
      o["tabId"] = tabId;
      chrome.browserAction.setTitle(o);
    } else {
      this.doInEveryNormalTab(function(tab) {
        o.tabId = tab.id;
        chrome.browserAction.setTitle(o);
      }, true);
    }
  } else if (title == null) {
    Evernote.Utils.clearBadgeTitle(tabId);
  }
};

Evernote.Utils.clearBadgeTitle = function(tabId) {
  var o = {
    title : ""
  };
  if (typeof tabId == 'number') {
    o["tabId"] = tabId;
    chrome.browserAction.setTitle(o);
  } else {
    this.doInEveryNormalTab(function(tab) {
      o.tabId = tab.id;
      chrome.browserAction.setTitle(o);
    }, true);
  }
};

Evernote.Utils.doInEveryNormalTab = function(callback, onlySelected) {
  chrome.windows.getAll( {
    populate : true
  }, function(wins) {
    for ( var w = 0; w < wins.length; w++) {
      if (wins[w].type == "normal") {
        for ( var t = 0; t < wins[w].tabs.length; t++) {
          if (!onlySelected || wins[w].tabs[t].selected) {
            callback(wins[w].tabs[t], wins[w]);
          }
        }
      }
    }
  });
};

Evernote.Utils.localizeBlock = function(block) {
  if (block.attr(Evernote.Utils.MESSAGE_ATTR))
    Evernote.Utils.localizeElement(block);
  var siblings = block.find("[" + Evernote.Utils.MESSAGE_ATTR + "]");
  for ( var i = 0; i < siblings.length; i++) {
    var sibling = $(siblings.get(i));
    Evernote.Utils.localizeElement(sibling);
  }
};

Evernote.Utils.extractLocalizationField = function(element) {
  if (typeof element.attr == 'function'
      && element.attr(Evernote.Utils.MESSAGE_ATTR))
    return element.attr(Evernote.Utils.MESSAGE_ATTR);
  else
    return null;
};
Evernote.Utils.extractLocalizationDataField = function(element) {
  if (typeof element.attr == 'function'
      && element.attr(Evernote.Utils.MESSAGE_DATA_ATTR)) {
    var v = element.attr(Evernote.Utils.MESSAGE_DATA_ATTR);
    try {
      v = eval(v);
    } catch (e) {
    }
    if (!(v instanceof Array))
      v = [ v ];
    return v;
  } else {
    return null;
  }
};

Evernote.Utils.localizeElement = function(element, force) {
  if (!force && element.attr(Evernote.Utils.LOCALIZED_ATTR)
      && element.attr(Evernote.Utils.LOCALIZED_ATTR == "true")) {
    return;
  }
  var field = Evernote.Utils.extractLocalizationField(element);
  var fieldData = Evernote.Utils.extractLocalizationDataField(element);
  if (field) {
    if (fieldData) {
      var msg = chrome.i18n.getMessage(field, fieldData);
    } else {
      var msg = chrome.i18n.getMessage(field);
    }
    if (element.attr("tagName") == "INPUT") {
      element.val(msg);
    } else {
      element.html(msg);
    }
    element.attr(Evernote.Utils.LOCALIZED_ATTR, "true");
  }
};

Evernote.Utils.notifyExtension = function(requestMessage, callback) {
  chrome.windows.getCurrent(function(win) {
    chrome.tabs.getSelected(win.id, function(tab) {
      var o = {
        tab : tab,
        id : chrome.i18n.getMessage("@@extension_id")
      };
      var cb = callback || function() {
      };
      chrome.extension.onRequest.dispatch(requestMessage, o, cb);
      chrome.extension.sendRequest(requestMessage, cb);
    });
  });
};

Evernote.Utils._setDesktopNotificationAttributes = function(notification, attrs) {
  if (notification && typeof attrs == 'object' && attrs) {
    for ( var i in attrs) {
      notification[i] = attrs[i];
    }
  }
};
Evernote.Utils.notifyDesktop = function(title, message, timeout, attrs) {
  var notification = webkitNotifications.createNotification(
      'images/en_app_icon-48.png', title, message);
  this._setDesktopNotificationAttributes(notification, attrs);
  notification.show();
  if (typeof timeout == 'number') {
    setTimeout(function() {
      notification.cancel();
    }, timeout);
  }
  return notification;
};
Evernote.Utils.notifyDesktopWithHTML = function(filePath, timeout, attrs) {
  var notification = webkitNotifications.createHTMLNotification(filePath);
  this._setDesktopNotificationAttributes(notification, attrs);
  notification.show();
  if (typeof timeout == 'number') {
    setTimeout(function() {
      notification.cancel();
    }, timeout);
  }
  return notification;
};
Evernote.Utils.openWindow = function(url) {
  var bg = chrome.extension.getBackgroundPage();
  bg.Evernote.chromeExtension.openWindow(url);
};
Evernote.Utils.getPostData = function(queryString) {
  if (typeof queryString == 'undefined') {
    queryString = window.location.search.replace(/^\?/, "");
  }
  var result = {};
  if (queryString) {
    var parts = queryString.split("&");
    for ( var i = 0; i < parts.length; i++) {
      var kv = parts[i].split("=");
      var k = unescape(kv[0]);
      var v = (kv[1]) ? unescape(kv[1]) : null;
      if (v) {
        try {
          result[k] = JSON.parse(v);
        } catch (e) {
          result[k] = v;
        }
      } else {
        result[k] = v;
      }
    }
  }
  return result;
};
Evernote.Utils.getLocalizedMessage = function(messageKey, params) {
  if (typeof chrome != 'undefined'
      && typeof chrome.i18n.getMessage == 'function') {
    return chrome.i18n.getMessage(messageKey, params);
  } else {
    return messageKey;
  }
};
Evernote.Utils.extractHttpErrorMessage = function(xhr, textStatus, error) {
  if (this.quiet)
    return;
  if (xhr.readyState == 4) {
    var msg = this.getLocalizedMessage("Error_HTTP_Transport", [
        ("" + xhr.status), ((typeof error == 'string') ? error : "") ]);
  } else {
    var msg = this.getLocalizedMessage("Error_HTTP_Transport", [
        ("readyState: " + xhr.readyState), "" ]);
  }
  return msg;
};
Evernote.Utils.extractErrorMessage = function(e, defaultMessage) {
  var msg = (typeof defaultMessage != 'undefined') ? defaultMessage : null;
  if (e instanceof Evernote.EvernoteError
      && typeof e.errorCode == 'number'
      && typeof e.parameter == 'string'
      && this.getLocalizedMessage("EDAMError_" + e.errorCode + "_"
          + e.parameter.replace(/[^a-zA-Z0-9_]+/g, "_"))) {
    msg = this.getLocalizedMessage("EDAMError_" + e.errorCode + "_"
        + e.parameter.replace(/[^a-zA-Z0-9_]+/g, "_"));
  } else if (e instanceof Evernote.EDAMResponseException
      && typeof e.errorCode == 'number'
      && this.getLocalizedMessage("EDAMResponseError_" + e.errorCode)) {
    if (typeof e.parameter == 'string') {
      msg = this.getLocalizedMessage("EDAMResponseError_" + e.errorCode,
          e.parameter);
    } else {
      msg = this.getLocalizedMessage("EDAMResponseError_" + e.errorCode);
    }
  } else if (e instanceof Evernote.EvernoteError
      && typeof e.errorCode == 'number'
      && this.getLocalizedMessage("EDAMError_" + e.errorCode)) {
    if (typeof e.parameter == 'string') {
      msg = this.getLocalizedMessage("EDAMError_" + e.errorCode, e.parameter);
    } else {
      msg = this.getLocalizedMessage("EDAMError_" + e.errorCode);
    }
  } else if (e instanceof Evernote.EvernoteError
      && typeof e.message == 'string') {
    msg = e.message;
  } else if ((e instanceof Error || e instanceof Error)
      && typeof e.message == 'string') {
    msg = e.message;
  } else if (typeof e == 'string') {
    msg = e;
  }
  return msg;
};

Evernote.Utils.isForbiddenUrl = function(url) {
  if (typeof url == 'string'
      && (url.toLowerCase().indexOf("chrome.google.com/extensions") >= 0 || url
          .toLowerCase().indexOf("chrome.google.com/webstore") >= 0)) {
    return true;
  }
  return false;
};


(function() {
  var LOG = null;

  Evernote.ProcessLog = function ProcessLog() {
    LOG = Evernote.chromeExtension.logger;
    this.__defineGetter__("transcript", this.getTranscript);
    this.__defineSetter__("transcript", this.setTranscript);
    this.__defineGetter__("length", this.getLength);
    this.initialize();
  };
  Evernote.ProcessLog.fromObject = function(obj) {
    if (obj instanceof Evernote.ProcessLog) {
      return obj;
    } else {
      var log = new Evernote.ProcessLog();
      if (typeof obj == 'object' && obj) {
        log.transcript = obj;
      }
      return log;
    }
  };
  Evernote.ProcessLog.prototype._transcript = null;
  Evernote.ProcessLog.prototype._length = 0;
  Evernote.ProcessLog.prototype.initialize = function() {
    this._transcript = {};
  };
  Evernote.ProcessLog.prototype.getTranscript = function() {
    return this._transcript;
  };
  Evernote.ProcessLog.prototype.setTranscript = function(transcript) {
    this.removeAll();
    if (typeof transcript == 'object' && transcript) {
      for ( var i in transcript) {
        var t = parseInt(i);
        if (!isNaN(t) && t > 0) {
          var vals = [].concat(transcript[i]);
          this._length += vals.length;
          if (typeof this._transcript[i] == 'undefined') {
            this._transcript[i] = vals;
          } else {
            this._transcript[i] = this._transcript[i].concat(vals);
          }
        }
      }
    }
  };
  Evernote.ProcessLog.prototype._milsFromObject = function(milsOrDate) {
    var t = 0;
    if (milsOrDate instanceof Date) {
      t = milsOrDate.getTime();
    } else if (typeof milsOrDate == 'number' && !isNaN(milsOrDate)) {
      t = milsOrDate;
    } else if (typeof milsOrDate == 'string') {
      t = parseInt(milsOrDate);
      if (isNaN(t) || t < 0) {
        t = 0;
      }
    }
    return t;
  };
  Evernote.ProcessLog.prototype.add = function(entry) {
    var d = new Date().getTime();
    if (typeof this.transcript[d] == 'undefined') {
      this.transcript[d] = [ entry ];
      this._length++;
    } else {
      this.transcript[d] = this.transcript[d].concat(entry);
      this._length++;
    }
  };
  Evernote.ProcessLog.prototype.remove = function(entry) {
    var indexes = [];
    var x = -1;
    for ( var i in this.transcript) {
      if ((x = this._transcript[i].indexOf(entry)) >= 0) {
        indexes.push( [ i, x ]);
      }
    }
    for ( var i = 0; i < indexes.length; i++) {
      var ix = indexes[i];
      delete this._transcript[ix[0]][ix[1]];
      if (this._transcript[ix[0]].length == 0) {
        delete this._transcript[ix[0]];
      }
      this._length--;
    }
  };
  Evernote.ProcessLog.prototype.removeAll = function() {
    this._transcript = {};
    this._length = 0;
  };
  Evernote.ProcessLog.prototype.get = function(entry) {
    var entries = [];
    var x = -1;
    for ( var i in this.transcript) {
      if ((x = this.transcript[i].indexOf(entry)) >= 0) {
        entries.push(this.transcript[i][x]);
      }
    }
    return (entries.length > 0) ? entries : null;
  };
  Evernote.ProcessLog.prototype.getAll = function() {
    var entries = [];
    for ( var i in this.transcript) {
      entries = entries.concat(this._transcript[i]);
    }
    return (entries.length > 0) ? entries : null;
  };
  Evernote.ProcessLog.prototype.getBefore = function(milsOrDate) {
    var t = this._milsFromObject(milsOrDate);
    var entries = [];
    for ( var i in this.transcript) {
      if (t > parseInt(i)) {
        entries = entries.concat(this.transcript[i]);
      }
    }
    return (entries.length > 0) ? entries : null;
  };
  Evernote.ProcessLog.prototype.getAfter = function(milsOrDate) {
    var t = this._milsFromObject(milsOrDate);
    var entries = [];
    for ( var i in this.transcript) {
      if (t < parseInt(i)) {
        entries = entries.concat(this.transcript[i]);
      }
    }
    return (entries.length > 0) ? entries : null;
  };
  Evernote.ProcessLog.prototype.removeBefore = function(milsOrDate) {
    var t = this._milsFromObject(milsOrDate);
    var indexes = [];
    for ( var i in this.transcript) {
      if (t > parseInt(i)) {
        indexes = indexes.concat(this.transcript[i]);
      }
    }
    for ( var i = 0; i < indexes.length; i++) {
      this._length -= this._transcript[indexes[i]].length;
      delete this._transcript[indexes[i]];
    }
  };
  Evernote.ProcessLog.prototype.removeAfter = function(milsOrDate) {
    var t = this._milsFromObject(milsOrDate);
    var indexes = [];
    for ( var i in this.transcript) {
      if (t < parseInt(i)) {
        indexes = indexes.concat(this.transcript[i]);
      }
    }
    for ( var i = 0; i < indexes.length; i++) {
      this._length -= this._transcript[indexes[i]].length;
      delete this._transcript[indexes[i]];
    }
  };
  Evernote.ProcessLog.prototype.getBetween = function(fromDate, toDate) {
    var from = this._milsFromObject(fromDate);
    var to = this._milsFromObject(toDate);
    var entries = [];
    for ( var i in this.transcript) {
      var ii = parseInt(i);
      if (from <= ii && ii <= to) {
        entries = entries.concat(this.transcript[i]);
      }
    }
    return (entries.length > 0) ? entries : null;
  };
  Evernote.ProcessLog.prototype.removeBetween = function(fromDate, toDate) {
    var from = this._milsFromObject(fromDate);
    var to = this._milsFromObject(toDate);
    var indexes = [];
    for ( var i in this.transcript) {
      var ii = parseInt(i);
      if (from <= ii && ii <= to) {
        indexes = indexes.concat(i);
      }
    }
    for ( var i = 0; i < indexes.length; i++) {
      this._length -= this._transcript[indexes[i]].length;
      delete this._transcript[indexes[i]];
    }
  };
  Evernote.ProcessLog.prototype.filter = function(fn) {
    var entries = [];
    for ( var i in this.transcript) {
      var ii = parseInt(i);
      for ( var x = 0; x < this._transcript[i].length; x++) {
        if (fn(ii, this._transcript[i][x])) {
          entries = entries.concat(this._transcript[i][x]);
        }
      }
    }
    return (entries.length > 0) ? entries : null;
  };
  Evernote.ProcessLog.prototype.getLength = function() {
    return this._length;
  };
  Evernote.ProcessLog.prototype.toJSON = function() {
    return this.transcript;
  };
})();

(function() {
  var LOG = null;
  Evernote.PayloadManager = function PayloadManager() {
    LOG = Evernote.chromeExtension.logger;
    this.__defineGetter__("pool", this.getPool);
    this.__defineGetter__("length", this.getLength);
    this.initialize();
  };
  Evernote.PayloadManager.prototype._pool = null;
  Evernote.PayloadManager.prototype._eventHandler = null;
  Evernote.PayloadManager.prototype._length = 0;
  Evernote.PayloadManager.prototype.initialize = function() {
    this._pool = {};
  };
  Evernote.PayloadManager.prototype.getPool = function() {
    return this._pool;
  };
  Evernote.PayloadManager.prototype.getLength = function() {
    return this._length;
  };
  Evernote.PayloadManager.prototype.add = function(payload) {
    if (payload) {
      var guid = Evernote.UUID.generateGuid();
      this._pool[guid] = payload;
      this._length++;
      LOG.debug("Added payload under guid: " + guid);
      return guid;
    }
    return undefined;
  };
  Evernote.PayloadManager.prototype.remove = function(payload) {
    var ret = null;
    if (payload) {
      for ( var i in this._pool) {
        if (this._pool[i] == payload) {
          ret = this._pool[i];
          delete this._pool[i];
          this._length--;
        }
      }
    }
    return ret;
  };
  Evernote.PayloadManager.prototype.removeByGuid = function(guid) {
    var ret = null;
    if (typeof this._pool[guid] != 'undefined') {
      ret = this._pool[guid];
      delete this._pool[guid];
      this._length--;
    }
    return ret;
  };
  Evernote.PayloadManager.prototype.get = function(payload) {
    if (payload) {
      for ( var i in this._pool) {
        if (this._pool[i] == payload) {
          return this._pool[i];
        }
      }
    }
    return undefined;
  };
  Evernote.PayloadManager.prototype.getByGuid = function(guid) {
    return this._pool[guid];
  };
})();

Evernote.DesktopNotifier = function(url, delay, timeout, options) {
  var self = this;
  this.__defineSetter__("url", this.setUrl);
  this.__defineGetter__("url", function() {
    return self.getUrl();
  });
  this.__definePositiveInteger__("delay", null);
  this.__definePositiveInteger__("timeout", null);
  this.__defineType__("options", Object, null);
  this.initialize(url, delay, timeout, options);
};

Evernote.mixin(Evernote.DesktopNotifier, Evernote.DefiningMixin);

Evernote.DesktopNotifier.prototype._url = null;
Evernote.DesktopNotifier.prototype.count = null;
Evernote.DesktopNotifier.prototype.timer = null;

Evernote.DesktopNotifier.prototype.initialize = function(url, delay, timeout,
    options) {
  this.url = url;
  this.delay = delay;
  this.timeout = timeout;
  this.options = options;
};
Evernote.DesktopNotifier.prototype.setUrl = function(url) {
  this._url = url;
};
Evernote.DesktopNotifier.prototype.getUrl = function() {
  return this._url;
};
Evernote.DesktopNotifier.prototype.clearTimer = function() {
  if (this.timer) {
    clearTimeout(this.timer);
  }
  this.timer = null;
};
Evernote.DesktopNotifier.prototype.notify = function(immediately) {
  var self = this;
  this.count++;
  if (typeof this.delay == 'number' && !immediately) {
    this.clearTimer();
    this.timer = setTimeout(function() {
      self._notify();
      self.count = 0;
    }, this.delay);
  } else {
    this._notify();
  }
};
Evernote.DesktopNotifier.prototype._notify = function() {
  Evernote.Utils.notifyDesktopWithHTML(this.url, this.timeout, this.options);
};


(function() {
  var LOG = null;
  Evernote.BasicClipProcessor = function BasicClipProcessor(path, size,
      interval, gracePeriod, success, error) {
    LOG = Evernote.Logger.getInstance();
    this.initialize(path, size, interval, gracePeriod, success, error);
  };
  Evernote.inherit(Evernote.BasicClipProcessor,
      Evernote.PersistentQueueProcessor);

  Evernote.BasicClipProcessor.prototype.initialize = function(path, size,
      interval, gracePeriod, success, error) {
    LOG.debug("BasicClipProcessor.initialize");
    var self = this;
    var successCallback = function() {
      LOG.debug("BasicClipProcessor successfully initialized");
      if (typeof success == 'function') {
        LOG.debug("Applying custom success handler");
        success.apply(this, arguments);
      }
      self._updateBadge();
    };
    Evernote.BasicClipProcessor.parent.initialize.apply(this, [ path, size,
        interval, gracePeriod, successCallback, error ]);
  };
  Evernote.BasicClipProcessor.prototype.add = function(item) {
    LOG.debug("BasicClipProcessor.add");
    if (item && item.constructor.name != 'FileEntry'
        && !(item instanceof Evernote.ClipNote)) {
      item = new Evernote.ClipNote(item);
    }
    Evernote.BasicClipProcessor.parent.add.apply(this, [ item ]);
    this._updateBadge();
  };
  Evernote.BasicClipProcessor.prototype._onprocess = function(item, processor,
      data) {
    LOG.debug("BasicClipProcessor._onprocess");
    item.processResponse = data;
    Evernote.BasicClipProcessor.parent._onprocess.apply(this, arguments);
    this._updateBadge();
  };
  Evernote.BasicClipProcessor.prototype._onprocesserror = function(item,
      processor, data) {
    LOG.debug("BasicClipProcessor._onprocesserror");
    item.processResponse = data;
    Evernote.BasicClipProcessor.parent._onprocesserror.apply(this, arguments);
    this._updateBadge();
  };
  Evernote.BasicClipProcessor.prototype._onreaderror = function(item, error) {
    LOG.debug("BasicClipProcessor._onreaderror");
    Evernote.BasicClipProcessor.parent._onreaderror.apply(this, arguments);
    this._updateBadge();
  };

  Evernote.BasicClipProcessor.prototype._updateBadge = function() {
    LOG.debug("BasicClipProcessor._updateBadge");
    LOG.debug("Updating badge as a result of intializing BasicClipProcessor ("
        + this.queue.length + " restored clips)");
    Evernote.Utils.updateBadge(Evernote.context);
  };
})();

(function() {
  var LOG = null;
  Evernote.ClipProcessor = function ClipProcessor(path, size, interval,
      gracePeriod, success, error) {
    LOG = Evernote.chromeExtension.logger;
    // this.__definePositiveInteger__("clipProc", 0);
    this.__defineType__("clipProc", XMLHttpRequest);
    var self = this;
    this.initialize(path, size, interval, gracePeriod, success, error);
  };

  Evernote.inherit(Evernote.ClipProcessor, Evernote.BasicClipProcessor);

  Evernote.ClipProcessor.prototype.initialize = function(path, size, interval,
      gracePeriod, success, error) {
    Evernote.ClipProcessor.parent.initialize.apply(this, arguments);
    if (typeof gracePeriod == 'number') {
      this.HTTP_GRACE_PERIOD = gracePeriod;
      this.processTimeout = gracePeriod;
    }
  };

  Evernote.ClipProcessor.prototype.stop = function() {
    LOG.debug("ClipProcessor.stop");
    if (this.clipProc && typeof this.clipProc.abort == 'function') {
      LOG.debug("Aborting clipProc...");
      this.clipProc.abort();
    }
    Evernote.ClipProcessor.parent.stop.apply(this, []);
  };

  Evernote.ClipProcessor.prototype.isInitializableFileEntry = function(
      fileEntry) {
    LOG.debug("ClipProcessor.isInitializableFileEntry");
    if (LOG.isDebugEnabled()) {
      LOG.dir(fileEntry);
    }
    var ret = Evernote.ClipProcessor.parent.isInitializableFileEntry.apply(
        this, [ fileEntry ]);
    var processLog = Evernote.context.processLog;
    LOG.debug("Checking if there's an entry for " + fileEntry.name
        + " in the processLog");
    var processLogEntry = processLog.get(fileEntry.name);
    LOG.debug("ProcessLogEntry: " + processLogEntry);
    if (ret && processLogEntry) {
      LOG
          .info("Ignoring "
              + fileEntry.name
              + " because it was already processed. Let's try to remove it again...");
      fileEntry.remove();
      return false;
    }
    return ret;
  };

  Evernote.ClipProcessor.prototype.HTTP_GRACE_PERIOD = 60 * 60 * 1000;
  Evernote.ClipProcessor.prototype.HTTP_MAX_ATTEMPTS = 2;
  Evernote.ClipProcessor.prototype.MAX_ATTEMPTS = 1;

  Evernote.ClipProcessor.prototype._testQueue = function() {
    for ( var i = 0; i < this.queue.length; i++) {
      var payload = this.queue[i];
      LOG.debug(">>>> Testing clipProcessor queue: " + i);
      LOG.dir(payload);
      var processed = this.isPayloadProcessed(payload);
      LOG.debug(">>> Processed: " + processed);
      var abortable = this.isPayloadAbortable(payload);
      LOG.debug(">>> Abortable: " + abortable);
      var inGrace = this.isPayloadInGrace(payload);
      LOG.debug(">>> In Grace: " + inGrace);
      var retry = this.isPayloadRetriable(payload);
      LOG.debug(">>> Retriable: " + retry);
      var procable = this.isPayloadProcessable(payload);
      LOG.debug(">>> Proccessable: " + procable);
    }
  };

  Evernote.ClipProcessor.prototype.isPayloadProcessed = function(payload) {
    LOG.debug("ClipProcessor.isPayloadProcessed");
    var ret = Evernote.ClipProcessor.parent.isPayloadProcessed.apply(this,
        [ payload ]);
    if (ret
        || (payload && payload.processResponse && this
            ._isResponseSuccess(payload))) {
      LOG.debug("Payload is processed");
      return true;
    } else {
      LOG.debug("Payload is not processed");
      return false;
    }
  };

  Evernote.ClipProcessor.prototype.isPayloadInGrace = function(payload) {
    LOG.debug("ClipProcessor.isPayloadInGrace");
    if (!payload.processed && payload.lastProcessed > 0) {
      var now = new Date().getTime();
      if ((!payload.processResponse || this
          ._isResponseHTTPRetryError(payload.processResponse))
          && payload.attempts < this.HTTP_MAX_ATTEMPTS
          && (now - payload.lastProcessed) < this.HTTP_GRACE_PERIOD) {
        LOG.debug("Payload is in grace period");
        return true;
      } else if (payload.processResponse
          && this._isResponseRetryError(payload.processResponse)
          && payload.attempts < this.MAX_ATTEMPTS
          && (now - payload.lastProcessed) < this.GRACE_PERIOD) {
        LOG.debug("Payload is in grace period");
        return true;
      }
    }
    LOG.debug("Payload is not in grace period");
    return false;
  };

  Evernote.ClipProcessor.prototype.isPayloadAbortable = function(payload) {
    LOG.debug("ClipProcessor.isPayloadAbortable");
    if (payload && payload.processResponse
        && this._isResponseAbortError(payload.processResponse)) {
      LOG
          .debug("Payload is abortable because its response contains abortable error");
      return true;
    } else if (payload && payload.processResponse) {
      if (this._isResponseHTTPRetryError(payload.processResponse)) {
        if (payload.attempts >= this.HTTP_MAX_ATTEMPTS) {
          LOG
              .debug("Payload is abortable because its HTTP response indicates a retriable error, but number of allowed attempts has been exceeded");
          return true;
        } else {
          LOG
              .debug("Payload is not abortable because its HTTP response indicates a retriable error, but it hasn't exceeded allowed attempts");
          return false;
        }
      } else if (this._isResponseRetryError(payload.processResponse)) {
        if (payload.attempts >= this.MAX_ATTEMPTS) {
          LOG
              .debug("Payload is abortable because its response indicates a retriable error, but number of allowed attempts has been exceeded");
          return true;
        } else {
          LOG
              .debug("Payload is not abortable because its response indicates a retriable error, but it hasn't exceed allowed attempts");
          return false;
        }
      }
    } else if (payload && !payload.processResponse
        && payload.attempts >= this.HTTP_MAX_ATTEMPTS) {
      LOG
          .debug("Payload is abortable because it has no response after max number of attempts");
      return true;
    } else {
      LOG
          .debug("Payload is not abortable because it doesn't contains a response indicating an abortable error");
      return false;
    }
  };

  Evernote.ClipProcessor.prototype.isPayloadRetriable = function(payload) {
    LOG.debug("ClipProcessor.isPayloadRetriable");
    if (payload && payload.processResponse
        && this._isResponseRetryError(payload.processResponse)
        && !this.isPayloadInGrace(payload)) {
      if (this._isResponseHTTPRetryError(payload.processResponse)) {
        if (payload.attempts >= this.HTTP_MAX_ATTEMPTS) {
          LOG
              .debug("Payload is not retriable despite its retriable HTTP response because it exceeded allowed attempts");
          return false;
        } else {
          LOG
              .debug("Payload is retriable because it indicates retriable HTTP error and hasn't exceeded allowed attempts");
          return true;
        }
      } else if (this._isResponseRetryError(payload.processResponse)) {
        if (payload.attempts >= this.MAX_ATTEMPTS) {
          LOG
              .debug("Payload is not retriable despite its retriable response because it exceeded allowed attempts");
          return false;
        } else {
          LOG
              .debug("Payload is retriable because it contains a response indicating a retriable error and it's no long in grace");
          return true;
        }
      }
    } else if (payload && !payload.processed && payload.lastProcessed
        && !payload.processResponse
        && payload.attempts < this.HTTP_MAX_ATTEMPTS
        && !this.isPayloadInGrace(payload)) {
      LOG
          .debug("Payload is retriable because it has no processResponse although attempted before, but doesn't exceed max attempts, and it's no longer in grace");
      return true;
    } else {
      LOG
          .debug("Payload is not retriable because it doesn't contain a response indicating a retriable error or it's still gracing");
      return false;
    }
  };

  Evernote.ClipProcessor.prototype.isPayloadProcessable = function(payload) {
    LOG.debug("ClipProcessor.isPayloadProcessable");
    if (this.isPayloadProcessed(payload)) {
      LOG
          .debug("Payload is not processable because it was already processed successfully");
      return false;
    } else if (payload.processResponse) {
      if (this.isPayloadAbortable(payload)) {
        LOG.debug("Payload is not processable and to be aborted");
        return false;
      } else if (this.isPayloadRetriable(payload)) {
        LOG.debug("Payload is processable because it needs to be retried");
        return true;
      }
    }
    var ret = Evernote.ClipProcessor.parent.isPayloadProcessable.apply(this,
        [ payload ]);
    if (ret) {
      LOG.debug("Payload is processable");
    } else {
      LOG.debug("Payload is not processable");
    }
    return ret;
  };

  Evernote.ClipProcessor.prototype._isResponseSuccess = function(response) {
    LOG.debug("ClipProcessor._isResponseSuccess");
    if (typeof response == 'object' && response
        && this._isResponseHTTPSuccess(response)
        && typeof response.response == 'object' && response.response) {
      var edamResponse = Evernote.EDAMResponse.fromObject(response.response);
      if (edamResponse.isResult()) {
        LOG.debug("Response indicates successful result");
        return true;
      }
    }
    LOG.debug("Response is not successful");
    return false;
  };

  Evernote.ClipProcessor.prototype._isResponseAbortError = function(response) {
    LOG.debug("ClipProcessor._isResponseAbortError");
    if (this._isResponseHTTPAbortError(response)) {
      LOG.debug("Response indicates an abortable error due to HTTP transport");
      return true;
    } else if (this._isResponseSuccess(response)) {
      LOG
          .debug("Response does not indicate abortable error because it's a successful response with a result");
      return false;
    } else if (this._isResponseRetryError(response)) {
      LOG
          .debug("Response does not indicate abortable error because it contains retriable errors");
      return false;
    }
    LOG.debug("Response indicates abortable error");
    return true;
  };

  Evernote.ClipProcessor.prototype._isResponseRetryError = function(response) {
    LOG.debug("ClipProcessor._isResponseRetryError");
    if (this._isResponseHTTPRetryError(response)) {
      LOG.debug("Response indicates a retriable error due to HTTP transport");
      return true;
    }
    LOG.debug("Response does not indicate a retriable error");
    return false;
  };

  Evernote.ClipProcessor.prototype._isResponseHTTPSuccess = function(response) {
    LOG.debug("ClipProcessor._isResponseHTTPSuccess");
    if (typeof response == 'object' && response && response.xhr
        && response.xhr.readyState == 4 && response.xhr.status != 0
        && response.textStatus == "success") {
      LOG.debug("Response is a successful HTTP response");
      return true;
    }
    LOG.debug("Response is not a successful HTTP response");
    return false;
  };

  Evernote.ClipProcessor.prototype._isResponseHTTPAbortError = function(
      response) {
    LOG.debug("ClipProcessor._isResponseHTTPAbortError");
    if (this._isResponseHTTPSuccess(response)
        || this._isResponseHTTPRetryError(response)) {
      LOG.debug("Response does not indicate an abortable HTTP error");
      return false;
    }
    LOG.debug("Response indicates an abortable HTTP error");
    return true;
  };

  Evernote.ClipProcessor.prototype._isResponseHTTPRetryError = function(
      response) {
    LOG.debug("ClipProcessor._isResponseHTTPRetryError");
    if (typeof response == 'object'
        && response
        && response.xhr
        && (response.xhr.readyState != 4 || (response.xhr.status == 0
            || response.xhr.status == 503 || response.xhr.status == 504))) {
      if (response.xhr.readyState == 4) {
        LOG.debug("Response indicates a retriable HTTP error: "
            + response.xhr.status);
      } else {
        LOG
            .debug("Response indicates a retriable HTTP error due to readyState: "
                + response.xhr.readyState);
      }
      return true;
    }
    LOG.debug("Response does not indicate a retriable HTTP error");
    return false;
  };

  Evernote.ClipProcessor.prototype._onprocesserror = function(payload,
      processor, data) {
    LOG.debug("ClipProcessor._onprocesserror");
    Evernote.ClipProcessor.parent._onprocesserror.apply(this, [ payload,
        processor, data ]);
    if (this.isPayloadProcessable(payload) || this.isPayloadInGrace(payload)) {
      LOG
          .debug("Payload is processable or in grace period, so let's keep it...");
    } else {
      LOG.debug("Payload is not processable, let's get rid of it...");
      if (LOG.isDebugEnabled()) {
        LOG.dir(payload);
      }
      this.removePayload(payload);
      if (payload.path) {
        LOG.debug("Logging path of aborted payload: " + payload.path);
        Evernote.context.processLog.add(payload.path);
        Evernote.context.updateProcessLog();
      }
    }
    // at this point, we should have the failed payload back in the queue if
    // it's going to be reprocessed, so, if it's not - there's going to be
    // nothing to proceses, might as well stop the damn processing...
    if (this.queue.length == 0) {
      LOG.debug("Stopping ClipProcessor because the queue is empty");
      this.stop();
    }
  };

  Evernote.ClipProcessor.prototype._onprocess = function(payload, processor,
      data) {
    LOG.debug("ClipProcessor._onprocess");
    Evernote.ClipProcessor.parent._onprocess.apply(this, arguments);
    if (payload && payload.path) {
      LOG.debug("Logging path of successful payload: " + payload.path);
      Evernote.context.processLog.add(payload.path);
      Evernote.context.updateProcessLog();
    }
    if (this.isEmpty()) {
      LOG.debug("Stopping ClipProcessor because the queue is empty");
      this.stop();
    }
  };

  Evernote.ClipProcessor.prototype._onprocesstimeout = function() {
    LOG.debug("ClipProcessor._onprocesstimeout");
    if (this.clipProc && typeof this.clipProc.abort == 'function') {
      this.clipProc.abort();
    }
    Evernote.ClipProcessor.parent._onprocesstimeout.apply(this, []);
  };

  Evernote.ClipProcessor.prototype.add = function(item) {
    LOG.debug("ClipProcessor.add");
    Evernote.ClipProcessor.parent.add.apply(this, arguments);
    if (!this.isStarted()) {
      LOG
          .debug("Starting queue processor because it was stopped and we added an item to the queue");
      this.start(true);
    }
  };

  Evernote.ClipProcessor.prototype.onreadystatechange = function() {
    LOG.debug("ClipProcessor.onreadystatechange");
    if (this.clipProc && this.clipProc.readyState) {
      LOG.debug(">>>> READYSTATE: " + this.clipProc.readyState);
    }
    if (this.clipProc && this.clipProc.readyState == 2) {
      if (this.currentItem) {
        if (this.currentItem.path) {
          LOG.debug("Logging path of uploaded (but not processed) payload: "
              + this.currentItem.path);
          Evernote.context.processLog.add(this.currentItem.path);
          Evernote.context.updateProcessLog();
        } else {
          LOG
              .warn("Not recording current payload in processLog because there's no path associated with it");
        }
      } else {
        LOG
            .warn("Cannot find currentItem... not doing anything about readystatechange");
      }
    }
  };

  Evernote.ClipProcessor.prototype.remove = function(item, dontRemoveFile) {
    LOG.debug("ClipProcessor.remove");
    if (this.currentItem && this.currentItem.data == item) {
      if (this.clipProc && typeof this.clipProc.abort == 'function') {
        LOG
            .debug("Aborting current clip process because its data was asked to be removed");
        this.clipProc.abort();
      }
    }
    Evernote.ClipProcessor.parent.remove.apply(this, [ item, dontRemoveFile ]);
  };

  Evernote.ClipProcessor.prototype.removePayload = function(payload,
      dontRemoveFile) {
    LOG.debug("ClipProcessor.removePayload");
    if (this.currentItem && this.currentItem == payload) {
      if (this.clipProc && typeof this.clipProc.abort == 'function') {
        LOG
            .debug("Aborting current clip process because its payload was asked to be removed");
        this.clipProc.abort();
      }
    }
    Evernote.ClipProcessor.parent.removePayload.apply(this, [ payload,
        dontRemoveFile ]);
  };

  Evernote.ClipProcessor.prototype.removeAll = function(dontRemoveFiles) {
    LOG.debug("ClipProcessor.removeAll");
    if (this.clipProc && typeof this.clipProc.abort == 'function') {
      LOG
          .debug("Aborting current clip process because its payload was asked to be removed");
      this.clipProc.abort();
    }
    Evernote.ClipProcessor.parent.removeAll.apply(this, [ dontRemoveFiles ]);
  };

  Evernote.ClipProcessor.prototype.processor = function(clipNote,
      successCallback, errorCallback) {
    LOG.debug("ClipProcessor.processor");
    if (!(clipNote instanceof Evernote.ClipNote)) {
      LOG.debug("Tried to process unexpected object, ignoring...");
      return;
    }
    var self = this;
    this.clipProc = Evernote.context.remote.clip(clipNote, function(response,
        textStatus, xhr) {
      LOG.debug("ClipProcessor successfully clipped a note");
      var respData = {
        response : response,
        textStatus : textStatus,
        xhr : xhr
      };
      if (xhr.readyState == 4 && xhr.status != 0 && textStatus == "success"
          && response.isResult() && typeof successCallback == 'function') {
        LOG.debug("Executing success callback");
        successCallback(respData);
      } else if (typeof errorCallback == 'function') {
        LOG.debug("Executing error callback");
        errorCallback(respData);
      }
    }, function(xhr, textStatus, err) {
      if (xhr.readyState == 4) {
        LOG.error("ClipProcessor encountered an error while clipping note "
            + " [readyState: " + xhr.readyState + "; status: " + xhr.status
            + "]");
      } else {
        LOG.error("ClipProcessor encountered an error while clipping note "
            + " [readyState: " + xhr.readyState + "]");
      }
      if (typeof errorCallback == 'function') {
        errorCallback( {
          xhr : xhr,
          textStatus : textStatus,
          error : err
        });
      }
    }, true);
    this.clipProc.onreadystatechange = function() {
      LOG.debug("clipProc readyStateChange: " + self.clipProc.readyState);
      self.onreadystatechange();
    };
  };
})();

(function() {
  var LOG = null;

  Evernote.AutosaveProcessor = function AutosaveProcessor(path, size, interval,
      gracePeriod, success, error) {
    LOG = Evernote.chromeExtension.logger;
    this.initialize(path, size, interval, gracePeriod, success, error);
  };
  Evernote.inherit(Evernote.AutosaveProcessor, Evernote.BasicClipProcessor);

  Evernote.AutosaveProcessor.prototype.initializeWithEntries = function(entries) {
    LOG.debug("AutosaveProcessor.initializeWithEntries");
    var self = this;
    if (entries && entries.length > 0) {
      for ( var i = 0; i < entries.length; i++) {
        if (entries[i].isFile) {
          LOG.debug("Initializing file: " + entries[i].fullPath);
          var r = entries[i].file(function(file) {
            self.fsa.readTextFromFile(file, function(reader, file) {
              LOG.debug("Successfully retrieved autosaved file on init");
              var clipNote = Evernote.AppModel
                  .unserializeStorable(reader.result);
              LOG.debug("Adding resulting clipNote to clipProcessor");
              if (LOG.isDebugEnabled()) {
                LOG.dir(clipNote);
              }
              Evernote.context.clipProcessor.add(clipNote);
              self.fsa.removeFile(self.rootPath + "/" + file.fileName,
                  function() {
                    LOG.debug("Successfully removed autosaved file");
                  }, self._onfsaerror);
            }, self._onfsaerror);
          });
          Evernote.context.clipProcessor.add(entries[i]);
        }
      }
    }
  };
  Evernote.AutosaveProcessor.prototype.add = function(item) {
    LOG.debug("AutosaveProcessor.add");
    this.removeAll(true);
    Evernote.AutosaveProcessor.parent.add.apply(this, [ item ]);
  };
  Evernote.AutosaveProcessor.prototype.processor = function(clipNote, success,
      error) {
    LOG.debug("AutosaveProcessor.processor");
    if (LOG.isDebugEnabled()) {
      LOG.dir(clipNote);
    }
    if (clipNote) {
      LOG.debug("Adding autosaved note to clipProcessor");
      Evernote.context.clipProcessor.add(clipNote);
      LOG.debug("Removing all previously stored versions of autosaved note");
      this.removeAll();
    }
  };
})();

Evernote.EventHandler = function EventHandler(scope) {
  this.initialize(scope);
};

Evernote.EventHandler.prototype._scope = null;
Evernote.EventHandler.prototype._map = null;
Evernote.EventHandler.prototype.initialize = function(scope) {
  this.__defineGetter__("scope", this.getScope);
  this.__defineSetter__("scope", this.setScope);
  this.__defineGetter__("defaultHandler", this.getDefaultHandler);
  this.__defineSetter__("defaultHandler", this.setDefaultHandler);
  this._map = {};
  this.scope = scope;
};
Evernote.EventHandler.prototype._defaultHandler = null;
Evernote.EventHandler.prototype.getDefaultHandler = function() {
  return this._defaultHandler;
};
Evernote.EventHandler.prototype.setDefaultHandler = function(fn) {
  if (typeof fn == 'function') {
    this._defaultHandler = fn;
  }
};
Evernote.EventHandler.prototype.getScope = function() {
  return this._scope;
};
Evernote.EventHandler.prototype.setScope = function(scope) {
  if (typeof scope == 'object') {
    this._scope = scope;
  }
};
Evernote.EventHandler.prototype.add = function(eventName, fn, scope) {
  if (!this._map[eventName]) {
    this._map[eventName] = [];
  }
  this._map[eventName].push( {
    fn : fn,
    scope : scope
  });
};
Evernote.EventHandler.prototype.addAll = function(map, scope) {
  for ( var eventName in map) {
    this.add(eventName, map[eventName], scope);
  }
};
Evernote.EventHandler.prototype.remove = function(eventName, fn) {
  if (this._map[eventName]) {
    if (fn) {
      for ( var i = 0; i < this._map[eventName].length; i++) {
        if (this._map[eventName][i].fn == fn) {
          delete this._map[eventName][i];
          break;
        }
      }
    } else {
      delete this._map[eventName];
    }
  }
};
Evernote.EventHandler.prototype.removeAll = function() {
  this._map = {};
};
Evernote.EventHandler.prototype.handleEvent = function(eventName, args) {
  if (this._map[eventName]) {
    for ( var i = 0; i < this._map[eventName].length; i++) {
      var fn = this._map[eventName][i].fn;
      var scope = this._map[eventName][i].scope || this.scope;
      fn.apply(scope, args);
    }
  } else {
    this.handleDefaultEvent.apply(this, args);
  }
};
Evernote.EventHandler.prototype.handleDefaultEvent = function(args) {
  if (typeof this._defaultHandler == 'function') {
    this._defaultHandler.apply(this.scope, args);
  }
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

/*
 * Evernote
 * ChromeExtension
 * 
 * Created by Pavel Skaldin on 2/10/11
 * Copyright 2011 Evernote Corp. All rights reserved.
 */
(function() {
  var LOG = null;
  Evernote.getChromeExtension = function() {
    if (!Evernote._chromeExtInstance) {
      // Evernote._chromeExtInstance = new Evernote.ChromeExtension();
      var bg = chrome.extension.getBackgroundPage();
      if (window == bg) {
        Evernote._chromeExtInstance = new Evernote.ChromeExtension();
      } else {
        Evernote._chromeExtInstance = bg.Evernote.chromeExtension;
      }
    }
    return Evernote._chromeExtInstance;
  };
  Evernote.__defineGetter__("chromeExtension", Evernote.getChromeExtension);

  Evernote.ChromeExtension = function ChromeExtension() {
    this.initialize();
    // setup global LOG at the end!
    LOG = this.logger;
    this.__defineGetter__("searchHelperContentScripting",
        this.getSearchHelperContentScripting);
    this.__defineGetter__("clipperContentScripting",
        this.getClipperContentScripting);
  };

  Evernote.ChromeExtension.CLIP_PROCESSOR_PATH = "/uploads";
  Evernote.ChromeExtension.CLIP_PROCESSOR_STORAGE_SIZE = Evernote.Constants.Limits.CLIP_NOTE_CONTENT_LEN_MAX * 100;
  Evernote.ChromeExtension.CLIP_PROCESSOR_INTERVAL = 30 * 1000;
  Evernote.ChromeExtension.CLIP_PROCESSOR_GRACE_PERIOD = 60 * 60 * 1000;
  Evernote.ChromeExtension.CLIP_PROCESSOR_PROCESS_TIMEOUT = 10 * 60 * 1000;
  Evernote.ChromeExtension.CLIP_PROCESSOR_KICK_DELAY = 1200;
  Evernote.ChromeExtension.AUTOSAVE_PROCESSOR_PATH = "/autosave";
  Evernote.ChromeExtension.AUTOSAVE_PROCESSOR_STORAGE_SIZE = Evernote.Constants.Limits.CLIP_NOTE_CONTENT_LEN_MAX * 2;
  Evernote.ChromeExtension.AUTOSAVE_PROCESSOR_INTERVAL = 30 * 1000;
  Evernote.ChromeExtension.AUTOSAVE_PROCESSOR_GRACE_PERIOD = 5 * 60 * 1000;
  Evernote.ChromeExtension.ERROR_NOTIFICATION_HTML_PATH = "/errornotification.html";
  Evernote.ChromeExtension.QUOTA_EXCEEDED_NOTIFICATION_HTML_PATH = "/quotareached.html";
  Evernote.ChromeExtension.UPLOAD_NOTIFICATION_HTML_PATH = "/noteupload.html";
  Evernote.ChromeExtension.UPLOAD_NOTIFICATION_PAYLOAD_GUID_PARAM = "payload";
  Evernote.ChromeExtension.DEFAULT_DESKTOP_NOTIFICATION_TIMEOUT = 18000;

  Evernote.ChromeExtension.prototype._localStore = null;
  Evernote.ChromeExtension.prototype._logger = null;
  Evernote.ChromeExtension.prototype._eventHandler = null;
  Evernote.ChromeExtension.prototype._clipProcessor = null;
  Evernote.ChromeExtension.prototype._autosaveProcessor = null;
  Evernote.ChromeExtension.prototype._searchHelperContentScripting = null;
  Evernote.ChromeExtension.prototype._clipperContentScripting = null;
  Evernote.ChromeExtension.prototype._payloadManager = null;
  Evernote.ChromeExtension.prototype._tabSemas = null;
  Evernote.ChromeExtension.prototype._desktopNotifications = null;

  Evernote.ChromeExtension.prototype.initialize = function() {
    this.__defineGetter__("localStore", this.getLocalStore);
    this.__defineGetter__("logger", this.getLogger);
    this.__defineGetter__("clipProcessor", this.getClipProcessor);
    this.__defineGetter__("autosaveProcessor", this.getAutosaveProcessor);
    this.__defineGetter__("payloadManager", this.getPayloadManager);
    this.__defineGetter__("defaultDesktopNotificationTimeout",
        this.getDefaultDesktopNotificationTimeout);
    this._desktopNotifications = {};
    this.initTabSemas();
    this.initEventHandler();
    this.initBindings();
    this.initClipProcessor();
    this.showIntro();
    var self = this;
    setTimeout(function() {
      self.startUp();
    }, 600);
  };
  Evernote.ChromeExtension.prototype.destroy = function() {
    LOG.debug("ChromeExtension.destroy");
    LOG.info("-------- TERMINTATING --------");
    if (this._clipProcessor) {
      this._clipProcessor.stop();
    }
  };
  Evernote.ChromeExtension.prototype.showIntro = function() {
    if (this.localStore && !this.localStore.get("introShown")) {
      chrome.tabs.create( {
        url : chrome.i18n.getMessage("introPageUrl"),
        selected : true
      });
      this.localStore.put("introShown", "true");
    }
  };
  Evernote.ChromeExtension.prototype.startUp = function() {
    LOG.debug("ChromeExtension.startUp");
    // get syncState straight away, this will indicate whether we are already
    // logged in, pull in all the necessary user-data and make it look like
    // we've ran before...
    var syncState = Evernote.context.syncState;
    Evernote.context.remote
        .getSyncState(
            ((syncState) ? syncState.updateCount : 0),
            function(response, status, xhr) {
              LOG
                  .debug("Successfully obtained syncState during ChromeExtension initialization");
            },
            function(xhr, status, error) {
              LOG
                  .debug("Failed to obtain syncState during ChromeExtension during initialization");
            }, true);
  };
  Evernote.ChromeExtension.prototype.getLogger = function(scope) {
    var logLevel = Evernote.Logger.LOG_LEVEL_ERROR;
    if (this.localStore) {
      var opts = this.localStore.get("options");
      if (opts && typeof opts["debugLevel"] != 'undefiend') {
        logLevel = opts['debugLevel'];
      }
      if (opts && typeof opts["keepLogs"] == 'number') {
        Evernote.FileLoggerImpl.prototype._keepFiles = opts["keepLogs"];
      }
      if (opts && opts["debugEnabled"]) {
        logLevel = Evernote.Logger.LOG_LEVEL_DEBUG;
        Evernote.Logger.enableImplementor(Evernote.FileLoggerImpl);
      } else {
        Evernote.Logger.disableImplementor(Evernote.FileLoggerImpl);
      }
    }
    var logger = Evernote.Logger.getInstance(scope || arguments.callee.caller);
    logger.level = logLevel;
    return logger;
  };
  Evernote.ChromeExtension.prototype.getLocalStore = function() {
    if (!this._localStore) {
      this._localStore = new Evernote.LocalStore(null,
          new Evernote.LocalStore.HTML5_LOCALSTORAGE_IMPL(localStorage));
    }
    return this._localStore;
  };
  Evernote.ChromeExtension.prototype.getClipProcessor = function() {
    if (!this._clipProcessor) {
      var self = this;
      this._clipProcessor = new Evernote.ClipProcessor(
          this.constructor.CLIP_PROCESSOR_PATH,
          this.constructor.CLIP_PROCESSOR_STORAGE_SIZE,
          this.constructor.CLIP_PROCESSOR_INTERVAL,
          this.constructor.CLIP_PROCESSOR_GRACE_PERIOD, function() {
            LOG.debug("Successfully initialized clip processor");
            if (LOG.isDebugEnabled()) {
              LOG.debug("Clearing processLog ("
                  + Evernote.context.processLog.length + ")");
            }
            // let's clear our processLog, cuz it shouldn't be needed at this
          // point
          Evernote.context.processLog.removeAll();
          Evernote.context.updateProcessLog();
          LOG.debug("Softly starting clipProcessor");
          this.processTimeout = self.constructor.CLIP_PROCESSOR_PROCESS_TIMEOUT;
          self.startClipProcessor();
        }, function(e) {
          LOG.debug("Error initializing clip processor: " + e.code);
          self.handleClipProcessorInitError(e);
          new Evernote.RequestMessage(
              Evernote.Constants.RequestType.CLIP_PROCESSOR_INIT_ERROR, e)
              .send();
        });
      this._clipProcessor.onprocess = function(payload, processor, data) {
        LOG.debug("Handling successfully processed payload");
        var guid = self.payloadManager.add(payload);
        var notification = Evernote.Utils.notifyDesktopWithHTML(
            self.constructor.UPLOAD_NOTIFICATION_HTML_PATH + "?"
                + self.constructor.UPLOAD_NOTIFICATION_PAYLOAD_GUID_PARAM + "="
                + guid, self.constructor.DEFAULT_DESKTOP_NOTIFICATION_TIMEOUT);
        notification.payloadGuid = guid;
        notification.onclose = function() {
          LOG.debug("Closing upload sucess notification for guid: "
              + this.payloadGuid + ". Let's remove that payload");
          self.payloadManager.removeByGuid(this.payloadGuid);
        };
        self._desktopNotifications[guid] = notification;
      };
      this._clipProcessor.onprocesserror = function(payload, processor, data) {
        if (this.isPayloadProcessable(payload)
            || this.isPayloadInGrace(payload)) {
          LOG
              .debug("Payload can still be processed, not notifying user about anything...");
        } else {
          LOG
              .debug("Payload is abortable, let's notify user with desktop notification about it");
          var guid = self.payloadManager.add(payload);
          var notification = Evernote.Utils
              .notifyDesktopWithHTML(self.constructor.UPLOAD_NOTIFICATION_HTML_PATH
                  + "?"
                  + self.constructor.UPLOAD_NOTIFICATION_PAYLOAD_GUID_PARAM
                  + "=" + guid);
          notification.payloadGuid = guid;
          notification.onclose = function() {
            LOG.debug("Closing upload error notification for guid: "
                + this.payloadGuid + ". Let's remove that payload");
            self.payloadManager.removeByGuid(this.payloadGuid);
          };
          self._desktopNotifications[guid] = notification;
          // DO NOT REMOVE THIS LOG.dir line below... it makes crack-smoking
          // Chrome actually execute the damn onclose handler... go figure
          if (LOG.isDebugEnabled()) {
            LOG.dir(notification);
          }
        }
        this.__proto__.onprocesserror.apply(this, [ payload, processor, data ]);
      };
      this._clipProcessor.onreaderror = function(payload, error) {
        if (!self._clipProcessor.onreaderrorNotifier) {
          LOG.debug("Creating notifier");
          self._clipProcessor.onreaderrorNotifier = new Evernote.DesktopNotifier(
              self.constructor.ERROR_NOTIFICATION_HTML_PATH, 1600);
          self._clipProcessor.onreaderrorNotifier.getUrl = function() {
            var params = {
              title : chrome.i18n
                  .getMessage("desktopNotification_clipProcessorUnexpectedErrorTitle")
            };
            if (this.count > 1) {
              params.message = chrome.i18n
                  .getMessage(
                      "desktopNotification_clipProcessorUnexpectedErrorMessageWithCount",
                      [ error, this.count ]);
            } else {
              params.message = chrome.i18n.getMessage(
                  "desktopNotification_clipProcessorUnexpectedErrorMessage",
                  [ error ]);
            }
            return Evernote.Utils.appendSearchQueryToUrl(this._url, params);
          };
        }
        if (self._clipProcessor.onreaderrorNotifier.lastError
            && self._clipProcessor.onreaderrorNotifier.lastError != error
                .toString()) {
          self._clipProcessor.onreaderrorNotifier.lastError = error.toString();
          self._clipProcessor.onreaderrorNotifier.notify(true);
        } else {
          self._clipProcessor.onreaderrorNotifier.lastError = error.toString();
          self._clipProcessor.onreaderrorNotifier.notify();
        }
      };
    }
    return this._clipProcessor;
  };

  Evernote.ChromeExtension.prototype.getAutosaveProcessor = function() {
    var self = this;
    if (!this._autosaveProcessor) {
      this._autosaveProcessor = new Evernote.AutosaveProcessor(
          this.constructor.AUTOSAVE_PROCESSOR_PATH,
          this.constructor.AUTOSAVE_PROCESSOR_STORAGE_SIZE,
          this.constructor.AUTOSAVE_PROCESSOR_INTERVAL,
          this.constructor.AUTOSAVE_PROCESSOR_GRACE_PERIOD,
          function() {
            LOG.debug("Successfully initialized autosave processor.");
            if (Evernote.context.userKnown) {
              LOG
                  .debug("Starting autosaveProcessor after initializing since we have an active user");
              self.startAutosaveProcessor();
            } else {
              LOG
                  .debug("Not starting autosaveProcessor after initializing because we have no active user");
            }
          },
          function(e) {
            LOG.error("Error intializing autosave processor: " + e.code);
            self.handleAutosaveProcessorInitError(e);
            new Evernote.RequestMessage(
                Evernote.Constants.RequestType.AUTOSAVE_PROCESSOR_INIT_ERROR, e)
                .send();
          });
    }
    return this._autosaveProcessor;
  };

  Evernote.ChromeExtension.prototype.getPayloadManager = function() {
    var self = this;
    if (!this._payloadManager) {
      this._payloadManager = new Evernote.PayloadManager();
    }
    return this._payloadManager;
  };

  Evernote.ChromeExtension.prototype.getSearchHelperContentScripting = function() {
    if (!this._searchHelperContentScripting) {
      this._searchHelperContentScripting = new Evernote.SearchHelperContentScripting();
    }
    return this._searchHelperContentScripting;
  };
  Evernote.ChromeExtension.prototype.getClipperContentScripting = function() {
    if (!this._clipperContentScripting) {
      this._clipperContentScripting = new Evernote.ClipperContentScripting();
      this._clipperContentScripting.ontimeout = function() {
        LOG.warn("clippContentScripting timed out...");
        alert(chrome.i18n.getMessage("contentScriptTimedOut"));
      };
      this._clipperContentScripting.createInstance = function() {
        var code = "Evernote.ContentClipper.destroyInstance();";
        code += "(function(){";
        code += "var inst = Evernote.ContentClipper.getInstance();";
        code += "inst.PAGE_CLIP_SUCCESS = Evernote.Constants.RequestType.CONTEXT_PAGE_CLIP_SUCCESS;";
        code += "inst.PAGE_CLIP_CONTENT_TOO_BIG = Evernote.Constants.RequestType.CONTEXT_PAGE_CLIP_CONTENT_TOO_BIG;";
        code += "inst.PAGE_CLIP_CONTENT_SUCCESS = Evernote.Constants.RequestType.CONTEXT_PAGE_CLIP_CONTENT_SUCCESS;";
        code += "inst.PAGE_CLIP_CONTENT_FAILURE = Evernote.Constants.RequestType.CONTEXT_PAGE_CLIP_CONTENT_FAILURE;";
        code += "inst.PAGE_CLIP_FAILURE = Evernote.Constants.RequestType.CONTEXT_PAGE_CLIP_FAILURE;";
        code += "})();";
        return code;
      };
    }
    return this._clipperContentScripting;
  };

  Evernote.ChromeExtension.prototype.initTabSemas = function() {
    this._tabSemas = {};
  };

  Evernote.ChromeExtension.prototype.initEventHandler = function() {
    this._eventHandler = new Evernote.EventHandler(this);
    this._eventHandler.add(Evernote.Constants.RequestType.LOGOUT,
        this.handleLogout);
    this._eventHandler.add(Evernote.Constants.RequestType.AUTH_SUCCESS,
        this.handleAuthSuccess);
    this._eventHandler.add(Evernote.Constants.RequestType.AUTH_ERROR,
        this.handleAuthError);
    this._eventHandler.add(Evernote.Constants.RequestType.DATA_UPDATED,
        this.handleDataUpdated);
    this._eventHandler.add(Evernote.Constants.RequestType.OPTIONS_UPDATED,
        this.handleOptionsUpdate);
    this._eventHandler.add(
        Evernote.Constants.RequestType.SEARCH_HELPER_DISABLE,
        this.handleSearchHelperDisable);
    this._eventHandler.add(
        Evernote.Constants.RequestType.CONTEXT_PAGE_CLIP_CONTENT_SUCCESS,
        this.handlePageClipSuccess);
    this._eventHandler.add(
        Evernote.Constants.RequestType.CONTEXT_PAGE_CLIP_CONTENT_TOO_BIG,
        this.handlePageClipTooBig);
    this._eventHandler.add(
        Evernote.Constants.RequestType.CONTEXT_PAGE_CLIP_CONTENT_FAILURE,
        this.handlePageClipFailure);
    this._eventHandler.add(
        Evernote.Constants.RequestType.CONTEXT_PAGE_CLIP_FAILURE,
        this.handlePageClipFailure);
    this._eventHandler.add(
        Evernote.Constants.RequestType.CLIP_PROCESSOR_INIT_ERROR,
        this.handleClipProcessorInitError);
    this._eventHandler.add(Evernote.Constants.RequestType.GET_MANAGED_PAYLOAD,
        this.handleGetManagedPayload);
    this._eventHandler.add(
        Evernote.Constants.RequestType.RETRY_MANAGED_PAYLOAD,
        this.handleRetryManagedPayload);
    this._eventHandler.add(
        Evernote.Constants.RequestType.CANCEL_MANAGED_PAYLOAD,
        this.handleCancelManagedPayload);
    this._eventHandler.add(
        Evernote.Constants.RequestType.REVISIT_MANAGED_PAYLOAD,
        this.handleRevisitManagedPayload);
    this._eventHandler.add(
        Evernote.Constants.RequestType.VIEW_MANAGED_PAYLOAD_DATA,
        this.handleViewManagedPayloadData);
    this._eventHandler.add(
        Evernote.Constants.RequestType.EDIT_MANAGED_PAYLOAD_DATA,
        this.handleEditManagedPayloadData);
  };

  Evernote.ChromeExtension.prototype.initBindings = function() {
    var self = this;
    // tab updates
    chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
      LOG.debug("chrome.extension.onUpdated: " + tabId);
      self.handleTabUpdate(tabId, changeInfo, tab);
    });
    // extension requests
    chrome.extension.onRequest.addListener(function(request, sender,
        sendResponse) {
      LOG.debug("chrome.extension.onRequest");
      self.handleRequest(request, sender, sendResponse);
    });
    // tab selection changes
    chrome.tabs.onSelectionChanged.addListener(function(tabId, selectInfo) {
      LOG.debug("chrome.tabs.onSelectionChanged: " + tabId);
      self.handleTabSelectionChange(tabId, selectInfo);
    });
    chrome.tabs.onRemoved.addListener(function(tabId, removeInfo) {
      LOG.debug("chrome.tabs.onRemoved: " + tabId);
      self.handleTabRemoval(tabId, removeInfo);
    });
  };

  Evernote.ChromeExtension.prototype.initClipProcessor = function() {
    var self = this;
    setTimeout(function() {
      if (!self._clipProcessor) {
        LOG.debug("Initializing clipProcessor");
        self.clipProcessor;
      }
    }, 3000);
  };

  Evernote.ChromeExtension.prototype.initContextMenu = function() {
    var opts = Evernote.context.getOptions(true);
    if (opts.useContextMenu) {
      this._setupContextMenus();
    } else {
      this._removeContextMenus();
    }
  };

  Evernote.ChromeExtension.prototype._removeContextMenus = function() {
    chrome.contextMenus.removeAll();
  };

  Evernote.ChromeExtension.prototype._setupContextMenus = function() {
    var self = this;
    // Clip Full Page
    chrome.contextMenus
        .create(
            {
              title : chrome.i18n.getMessage("contextMenuClipPage"),
              contexts : [ "page", "image" ],
              documentUrlPatterns : [ "http://*/*", "https://*/*" ],
              onclick : function(info, tab) {
                self
                    .doAsUser(
                        function() {
                          LOG
                              .debug("Initiating page clip from menu item contextMenuClipPage");
                          self.clipPageFromTab(tab, true);
                        },
                        function() {
                          LOG
                              .info("Cannot clip from menu item contextMenuClipPage because no user is known");
                          alert(chrome.i18n
                              .getMessage("contextMenuPleaseLogin"));
                        });
              }
            },
            function() {
              if (chrome.extension.lastError) {
                LOG.error("Error creating menu item contextMenuClipPage: "
                    + chrome.extension.lastError);
              } else {
                LOG.debug("Successfully created menu item contextMenuClipPage");
              }
            });

    chrome.contextMenus
        .create(
            {
              title : chrome.i18n.getMessage("contextMenuClipSelection"),
              contexts : [ "selection" ],
              documentUrlPatterns : [ "http://*/*", "https://*/*" ],
              onclick : function(info, tab) {
                self
                    .doAsUser(
                        function() {
                          LOG
                              .debug("Initiating selection cli from menu item contextMenuClipSelection");
                          self.clipPageFromTab(tab, false);
                        },
                        function() {
                          LOG
                              .info("Cannot clip from menu item contextMenuClipSelection because no user is known");
                          alert(chrome.i18n
                              .getMessage("contextMenuPleaseLogin"));
                        });
              }
            },
            function() {
              if (chrome.extension.lastError) {
                LOG.error("Error creating menu item contextMenuClipSelection");
              } else {
                LOG
                    .debug("Successfully created menu item contextMenuClipSelection");
              }
            });

    // Clip Image
    chrome.contextMenus
        .create(
            {
              title : chrome.i18n.getMessage("contextMenuClipImage"),
              contexts : [ "image" ],
              targetUrlPatterns : [ "http://*/*", "https://*/*" ],
              onclick : function(info, tab) {
                if (info.srcUrl) {
                  self
                      .doAsUser(
                          function() {
                            LOG
                                .debug("Initiating image clip from menu item contextMenuClipImage");
                            self.clipImage(info.srcUrl, tab);
                          },
                          function() {
                            LOG
                                .info("Cannot clip from menu item contextMenuClipImage because no user is known");
                            alert(chrome.i18n
                                .getMessage("contextMenuPleaseLogin"));
                          });
                } else {
                  LOG.debug("Could not determine image url");
                }
              }
            },
            function() {
              if (chrome.extension.lastError) {
                LOG.error("Error creating menu item contextMenuClipImage");
              } else {
                LOG
                    .debug("Successfully created menu item contextMenuClipImage");
              }
            });

    // ---------------
    chrome.contextMenus.create( {
      type : 'separator',
      contexts : [ 'all' ]
    });

    // New Note
    chrome.contextMenus.create( {
      title : chrome.i18n.getMessage("contextMenuNewNote"),
      contexts : [ 'all' ],
      onclick : function(info, tab) {
        LOG.debug("Opening new note window on service side");
        self.openNoteWindow(Evernote.context.getNoteCreateUrl());
      }
    }, function() {
      if (chrome.extension.lastError) {
        LOG.error("Error creating menu item contextMenuNewNote");
      } else {
        LOG.debug("Successfully created menu item contextMenuNewNote");
      }
    });
  };

  Evernote.ChromeExtension.prototype.doAsUser = function(success, error) {
    LOG.debug("ChromeExtension.doAsUser");
    if (Evernote.context.userKnown && typeof success == 'function') {
      success();
    } else {
      var ok = function(response, status, xhr) {
        if (response.isResult() && typeof success == 'function') {
          success();
        } else if (typeof error == 'function') {
          error();
        }
      };
      var err = function() {
        if (typeof error == 'function') {
          error();
        }
      };
      Evernote.context.remote.getSyncState(0, ok, err, true);
    }
  };

  Evernote.ChromeExtension.prototype.openWindow = function(url) {
    var self = this;
    chrome.tabs.getSelected(null, function(tab) {
      var opts = {
        url : url
      };
      chrome.windows.create(opts);
    });
  };

  Evernote.ChromeExtension.prototype.openNoteWindow = function(noteUrl) {
    var self = this;
    chrome.tabs.getSelected(null, function(tab) {
      var opts = {
        url : noteUrl,
        width : 800,
        height : 550
      };
      if (tab) {
        opts.incognito = tab.incognito;
      }
      if (typeof opts["incognito"] != 'undefined' && opts.incognito) {
        Evernote.context.getCookie("auth", function(cookie) {
          if (typeof cookie == 'object' && cookie != null
              && typeof cookie["value"] == 'string'
              && typeof noteUrl == 'string') {
            opts.url = Evernote.context.getSetAuthTokenUrl(cookie.value,
                noteUrl.replace(/http.?:\/\/[^\/]+/i, ""));
          }
          chrome.windows.create(opts);
        }, function() {
          chrome.windows.create(opts);
        });
      } else {
        chrome.windows.create(opts);
      }
    });
  };

  Evernote.ChromeExtension.prototype.handleTabUpdate = function(tabId,
      changeInfo, tab) {
    LOG.debug("ChromeExtension.handleTabUpdate: " + tabId);
    var url = (typeof changeInfo == 'object' && changeInfo != null && changeInfo.url) ? changeInfo.url
        : tab.url;
    LOG.debug("Url: " + url);
    var useSearchHelper = Evernote.context.getOptions(true).isUseSearchHelper()
        && typeof url == 'string' && url.toLowerCase().indexOf("http") == 0
        && Evernote.SearchHelper.queryFromUrl(url) != null;
    LOG.debug(((useSearchHelper) ? "USING " : "NOT USING ") + " SearchHelper");
    if (changeInfo && changeInfo.status == "loading") {
      LOG.debug("Creating new semaphore for tab: " + tabId);
      this._tabSemas[tabId] = new Evernote.Semaphore();
      if (useSearchHelper) {
        LOG.debug("Performing simsearch while the page is loading");
        this.doSimSearch(tab, url);
      }
    } else if (changeInfo && changeInfo.status == "complete") {
      if (this._tabSemas[tabId]) {
        LOG.debug("Signaling tab semaphore, tab: " + tabId);
        this._tabSemas[tabId].signal();
      } else {
        LOG
            .debug("For some fucked up reason tab semaphore wasn't setup, creating mutex");
        this._tabSemas[tabId] = Evernote.Semaphore.mutex();
      }
      if (useSearchHelper) {
        var sh = Evernote.SearchHelper.getInstance(tabId);
        this.searchHelperContentScripting.clearContentMessages(tabId);
        if (sh) {
          if (sh.isActive()) {
            this.searchHelperContentScripting.prependContentMessage(tabId,
                chrome.i18n.getMessage("searchHelperSearching"));
          }
          LOG.debug("Signaling SearchHelper cuz the page is loaded");
          sh.signal();
        }
      }
    }
    Evernote.Utils.updateBadge(Evernote.context, tabId);
  };
  Evernote.ChromeExtension.prototype.handleTabSelectionChange = function(tabId,
      selectInfo) {
    LOG.debug("ChromeExtension.handleTabSelectionChange: " + tabId);
    Evernote.Utils.updateBadge(Evernote.context, tabId);
  };
  Evernote.ChromeExtension.prototype.handleTabRemoval = function(tabId,
      removeInfo) {
    LOG.debug("ChromeExtension.handleTabRemoval: " + tabId);
    if (this._tabSemas[tabId]) {
      LOG.debug("Destroying tab semaphore for tab: " + tabId);
      this._tabSemas[tabId] = null;
      delete this._tabSemas[tabId];
    }
    Evernote.SearchHelper.removeInstance(tabId);
  };
  Evernote.ChromeExtension.prototype.handleRequest = function(request, sender,
      sendResponse) {
    LOG.debug("ChromeExtension.handleRequest");
    if (typeof request == 'object' && request != null) {
      var requestMessage = Evernote.RequestMessage.fromObject(request);
      if (!requestMessage.isEmpty()) {
        this._eventHandler.handleEvent(requestMessage.code, [ request, sender,
            sendResponse ]);
      }
    }
  };
  Evernote.ChromeExtension.prototype.handleLogout = function(request, sender,
      sendResponse) {
    LOG.debug("ChromeExtension.handleLogout");
    var req = Evernote.RequestMessage.fromObject(request);
    Evernote.Utils.clearAllBadges();
    Evernote.SearchHelper.reset();
    Evernote.context.removeSessionCookies();
    Evernote.context.clipProcessor.removeAll();
    Evernote.context.clipProcessor.stop();
    if (req.message && request.message.resetOptions) {
      LOG.debug("Resetting options");
      var opts = Evernote.context.getOptions();
      opts.resetCredentials();
      opts.apply();
    }
    Evernote.context.destroy();
    sendResponse( {});
  };
  Evernote.ChromeExtension.prototype.handleAuthSuccess = function() {
    LOG.debug("ChromeExtension.handleAuthSucess");
    this.startClipProcessor(true);
    this.startAutosaveProcessor();
  };
  Evernote.ChromeExtension.prototype.handleAuthError = function() {
    LOG.debug("ChromeExtension.handleAuthError");
    this.stopClipProcessor();
    this.stopAutosaveProcessor();
  };
  Evernote.ChromeExtension.prototype.handleDataUpdated = function() {
    LOG.debug("ChromeExtension.handleDataUpdated");
    this.startClipProcessor();
    this.startAutosaveProcessor();
  };
  Evernote.ChromeExtension.prototype.handleOptionsUpdate = function(request,
      sender, sendResponse) {
    LOG.debug("ChromeExtension.handleOptionsUpdate");
    var opts = Evernote.context.getOptions(true);
    LOG.level = opts.debugLevel;
    var self = this;
    if (opts.debugEnabled) {
      Evernote.Logger.setLevel(Evernote.Logger.LOG_LEVEL_DEBUG);
      Evernote.Logger.enableImplementor(Evernote.FileLoggerImpl);
    } else {
      Evernote.Logger.setLevel(opts.debugLevel);
      Evernote.Logger.disableImplementor(Evernote.FileLoggerImpl);
    }
    if (opts && typeof opts.keepLogs == 'number') {
      Evernote.FileLoggerImpl.setProtoKeepFiles(opts.keepLogs);
    }
    for ( var i in Evernote.Logger._instances) {
      Evernote.Logger._instances[i].impl.fileLoggingEnabled = opts.debugEnabled;
    }
    chrome.contextMenus.removeAll(function() {
      if (opts.useContextMenu) {
        LOG.debug("Setting up context menus per updated option");
        self._setupContextMenus();
      } else {
        LOG.debug("Not setting up context menus per updated option");
      }
    });
    if (!opts.isUseSearchHelper()) {
      Evernote.Utils.updateBadge(Evernote.context);
      Evernote.SearchHelper.reset();
    }
    sendResponse( {});
  };
  Evernote.ChromeExtension.prototype.handleSearchHelperDisable = function(
      request, sender, sendResponse) {
    LOG.debug("ChromeExtension.handleSearchHelperDisable");
    if (confirm(chrome.i18n.getMessage("searchHelperConfirmDisable"))) {
      var opts = Evernote.context.getOptions(true);
      opts.setUseSearchHelper(false);
      // Evernote.context.setOptions(opts);
      opts.apply();
      this.searchHelperContentScripting.clearContentMessages();
    }
    sendResponse( {});
  };
  Evernote.ChromeExtension.prototype.handlePageClipSuccess = function(request,
      sender, sendResponse) {
    LOG.debug("ChromeExtension.handlePageClipSuccess");
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    var clipNote = new Evernote.ClipNote(requestMessage.message);
    clipNote.created = new Date().getTime();
    var preferredNotebook = Evernote.context.getPreferredNotebook();
    if (preferredNotebook) {
      clipNote.notebookGuid = preferredNotebook.guid;
    }
    LOG.debug("Clipped note's content length: " + clipNote.content.length);
    Evernote.chromeExtension.processClip(clipNote);
    sendResponse( {});
  };
  Evernote.ChromeExtension.prototype.handlePageClipTooBig = function(request,
      sender, sendResponse) {
    LOG.debug("ChromeExtension.handlePageClipTooBig");
    var msg = chrome.i18n.getMessage("fullPageClipTooBig");
    msg = $("<div>" + msg + "</div>").text();
    LOG.error(msg);
    alert(msg);
    sendResponse( {});
  };
  Evernote.ChromeExtension.prototype.handlePageClipFailure = function(request,
      sender, sendResponse) {
    LOG.debug("ChromeExtension.handlePageClipFailure");
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    var msg = (requestMessage.message) ? requestMessage.message : chrome.i18n
        .getMessage("fullPageClipFailure");
    msg = $("<div>" + msg + "</div>").text();
    LOG.error(msg);
    alert(msg);
    sendResponse( {});
  };
  Evernote.ChromeExtension.prototype.handleClipProcessorInitError = function(
      request, sender, sendResponse) {
    LOG.debug("ChromeExtension.handleClipProcessorInitError");
    if (typeof sendResponse == 'function') {
      sendResponse( {});
    }
  };

  Evernote.ChromeExtension.prototype.handleGetManagedPayload = function(
      request, sender, sendResponse) {
    LOG.debug("ChromeExtension.handleGetManagedUpload");
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    var payload = this.payloadManager.getByGuid(requestMessage.message);
    if (payload) {
      LOG.debug("Retrieved payload by guid: " + requestMessage.message);
    } else {
      LOG.debug("Could not find payload by guid: " + requestMessage.message);
    }
    Evernote.Utils.updateBadge(Evernote.context);
    sendResponse(payload);
  };
  Evernote.ChromeExtension.prototype.handleRetryManagedPayload = function(
      request, sender, sendResponse) {
    LOG.debug("ChromeExtension.handleRetryManagedUpload");
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    var payloadGuid = requestMessage.message;
    var payload = this.payloadManager.getByGuid(payloadGuid);
    if (payload) {
      LOG.debug("Retrying payload with guid: " + payloadGuid);
      if (LOG.isDebugEnabled()) {
        LOG.dir(payload);
      }
      if (payload.path) {
        LOG.debug("Removing payload from processLog: " + payload.path);
        Evernote.context.processLog.remove(payload.path);
        Evernote.context.updateProcessLog();
      }
      this.processClip(payload.data);
    } else {
      LOG.debug("Could not find payload by guid: " + payloadGuid);
    }
    if (this._desktopNotifications[requestMessage.message]) {
      this._desktopNotifications[requestMessage.message].cancel();
      delete this._desktopNotifications[requestMessage.message];
    }
    Evernote.Utils.updateBadge(Evernote.context);
    sendResponse( {});
  };
  Evernote.ChromeExtension.prototype.handleCancelManagedPayload = function(
      request, sender, sendResponse) {
    LOG.debug("ChromeExtension.handleCancelFailedUpload");
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    LOG.debug("Removing payload witih guid: " + requestMessage.message);
    this.payloadManager.removeByGuid(requestMessage.message);
    if (this._desktopNotifications[requestMessage.message]) {
      this._desktopNotifications[requestMessage.message].cancel();
      delete this._desktopNotifications[requestMessage.message];
    }
    Evernote.Utils.updateBadge(Evernote.context);
    sendResponse( {});
  };

  Evernote.ChromeExtension.prototype.handleRevisitManagedPayload = function(
      request, sender, sendResponse) {
    LOG.debug("ChromeExtension.handleRevisitManagedPayload");
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    var payload = this.payloadManager.getByGuid(requestMessage.message);
    if (payload && payload.data && payload.data.url) {
      Evernote.Utils.openWindow(payload.data.url);
    }
    if (this._desktopNotifications[requestMessage.message]) {
      this._desktopNotifications[requestMessage.message].cancel();
      delete this._desktopNotifications[requestMessage.message];
    }
    Evernote.Utils.updateBadge(Evernote.context);
    sendResponse( {});
  };

  Evernote.ChromeExtension.prototype.handleViewManagedPayloadData = function(
      request, sender, sendResponse) {
    LOG.debug("ChromeExtension.handleViewManagedPayloadData");
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    var payload = this.payloadManager.removeByGuid(requestMessage.message);
    if (payload && payload.processResponse && payload.processResponse.response) {
      var resp = Evernote.EDAMResponse
          .fromObject(payload.processResponse.response);
      if (resp.isResult() && resp.result.note && resp.result.note.guid) {
        Evernote.Utils.openWindow(Evernote.context
            .getNoteViewUrl(resp.result.note.guid));
      }
    }
    if (this._desktopNotifications[requestMessage.message]) {
      this._desktopNotifications[requestMessage.message].cancel();
      delete this._desktopNotifications[requestMessage.message];
    }
    sendResponse( {});
  };

  Evernote.ChromeExtension.prototype.handleEditManagedPayloadData = function(
      request, sender, sendResponse) {
    LOG.debug("ChromeExtension.handleEditManagedPayloadData");
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    var payload = this.payloadManager.removeByGuid(requestMessage.message);
    if (payload && payload.processResponse && payload.processResponse.response) {
      var resp = Evernote.EDAMResponse
          .fromObject(payload.processResponse.response);
      if (resp.isResult() && resp.result.note && resp.result.note.guid) {
        Evernote.Utils.openWindow(Evernote.context
            .getNoteEditUrl(resp.result.note.guid));
      }
    }
    if (this._desktopNotifications[requestMessage.message]) {
      this._desktopNotifications[requestMessage.message].cancel();
      delete this._desktopNotifications[requestMessage.message];
    }
    sendResponse( {});
  };

  Evernote.ChromeExtension.prototype.handleAutosaveProcessorInitError = function(
      request, sender, sendResponse) {
    LOG.debug("ChromeExtension.handleAutosaveProcessorInitError");
    if (typeof sendResponse == 'function') {
      sendResponse( {});
    }
  };
  Evernote.ChromeExtension.prototype.handleQuotaReached = function(request,
      sender, sendResponse) {
    LOG.debug("ChromeExtension.handleQuotaReached");
    Evernote.Utils
        .notifyDesktopWithHTML(this.constructor.QUOTA_EXCEEDED_NOTIFICATION_HTML_PATH);
    if (typeof sendResponse == 'function') {
      sendResponse( {});
    }
  };

  Evernote.ChromeExtension.prototype.startClipProcessor = function(force) {
    LOG.debug("ChromeExtension.prototype.startClipProcessor");
    if (Evernote.context.userKnown && this._clipProcessor
        && (!this._clipProcessor.isStarted() || force)
        && !this._clipProcessor.isEmpty()) {
      LOG.debug("Starting clip processor");
      if (force) {
        this._clipProcessor.refresh();
      }
      this._clipProcessor.start();
    } else if (!this._clipProcessor) {
      LOG
          .debug("Ignoring attempt to start clipProcessor because it doesn't exist (yet?)...");
    } else if (!Evernote.context.userKnown) {
      LOG
          .debug("Ignoring attempt to start clipProcessor because user is unknown");
    } else if (this._clipProcessor.isStarted()) {
      LOG
          .debug("Ignoring attempt to start clipProcessor because it's already started");
    } else if (this._clipProcessor.isEmpty()) {
      LOG.debug("Ignoring attempt to start clipProcessor because it's empty");
    } else {
      LOG.debug("Ignoring attempt to start clipProcessor for whatever reason");
    }
  };
  Evernote.ChromeExtension.prototype.stopClipProcessor = function() {
    LOG.debug("ChromeExtension.stopClipProcessor");
    if (this._clipProcessor && this._clipProcessor.isStarted()) {
      this._clipProcessor.stop();
    }
  };
  Evernote.ChromeExtension.prototype.startAutosaveProcessor = function() {
    LOG.debug("ChromeExtension.startAutosaveProcessor");
    if (this._autosaveProcessor && !this._autosaveProcessor.isStarted()) {
      // pasha: temporarily disabled while still using old autosaver
      // this._autosaveProcessor.start();
    }
  };
  Evernote.ChromeExtension.prototype.stopAutosaveProcessor = function() {
    LOG.debug("ChromeExtension.stopAutosaveProcessor");
    if (this._autosaveProcessor && this._autosaveProcessor.isStarted()) {
      // pasha: temporarily disabled while still using old autosaver
      // this._autosaveProcessor.stop();
    }
  };

  Evernote.ChromeExtension.prototype.clipImage = function(srcUrl, tab) {
    LOG.debug("ChromeExtension.clipImage");
    var n = new Evernote.ClipNote( {
      title : tab.title,
      content : "<img src=\"" + srcUrl + "\"/>",
      created : new Date().getTime(),
      url : tab.url
    });
    var preferredNotebook = Evernote.context.getPreferredNotebook();
    if (preferredNotebook) {
      n.notebookGuid = preferredNotebook.guid;
    }
    this.processClip(n);
  };

  Evernote.ChromeExtension.prototype.clipPageFromTab = function(tab, fullPage) {
    LOG.debug("ChromeExtension.clipPageFromTab");
    if (Evernote.Utils.isForbiddenUrl(tab.url)) {
      alert(chrome.i18n.getMessage("illegalUrlClipFailure"));
      return;
    }
    var self = this;
    if (!this._tabSemas[tab.id]) {
      LOG
          .warn("Looks like we don't have a semaphore for this tab... it is likely it was already open, so let's creat a mutex");
      this._tabSemas[tab.id] = Evernote.Semaphore.mutex();
    }
    this._tabSemas[tab.id].critical(function() {
      LOG.debug("Clipping content of a page in tab: " + tab.id);
      self.clipperContentScripting.perform(tab.id, fullPage, Evernote.context
          .getPreferredStylingStrategyQualifier(), true);
      if (self._tabSemas[tab.id]) {
        self._tabSemas[tab.id].signal();
      }
    });
  };

  Evernote.ChromeExtension.prototype.processClip = function(clip) {
    LOG.debug("ChromeExtension.processClip");
    var self = this;
    this.clipProcessor.add(clip);
    setTimeout(function() {
      LOG.debug("Kicking off clipProcessor after adding new clip...");
      self.clipProcessor.process();
    }, this.constructor.CLIP_PROCESSOR_KICK_DELAY);
  };

  Evernote.ChromeExtension.prototype.doSimSearch = function(tab, url) {
    LOG.debug("ChromeExtension.doSimSearch: " + tab.id + ":" + url);
    var self = this;
    Evernote.SearchHelper
        .search(
            tab.id,
            url,
            function(result, sh) {
              LOG.debug("Handling successful simsearch repsonse");
              if (result && result.totalNotes >= 0) {
                LOG.debug("Found " + result.totalNotes + " notes");
                Evernote.Utils.updateBadge(Evernote.context, tab.id);
                var f = function(theUrl) {
                  var msg = (result.totalNotes) ? chrome.i18n.getMessage(
                      "searchHelperFoundNotes", [ result.totalNotes, theUrl ])
                      : chrome.i18n.getMessage("searchHelperNotesNotFound");
                  self.searchHelperContentScripting.prependContentMessage(
                      tab.id, msg);
                  if (Evernote.context.options.useLinkHilites) {
                    self.searchHelperContentScripting.appendLinkedUrls(tab.id,
                        result.notes, sh.query);
                  }
                };
                Evernote.context.getCookie("auth", function(cookie) {
                  var _u = Evernote.context.getEvernoteSearchUrl(sh.query)
                      .replace(/^https?:\/\/[^\/]+/, "");
                  f(Evernote.context.getSetAuthTokenUrl(cookie.value, _u));
                });
              } else {
                LOG.debug("Found no notes");
                Evernote.Utils.updateBadge(Evernote.context, tab.id);
                self.searchHelperContentScripting.prependContentMessage(tab.id,
                    chrome.i18n.getMessage("searchHelperNotesNotFound"));
              }
            },
            function(sh) {
              LOG.debug("Handling erroneous simsearch reponse");
              if (sh.response && Evernote.context.isPersistentLogin()
                  && sh.response.isMissingAuthTokenError()) {
                LOG
                    .debug("Error searching for page query because our auth token isn't persisting");
                self.searchHelperContentScripting.prependContentErrorMessage(
                    tab.id, chrome.i18n.getMessage("authPersistenceError"));
                Evernote.Utils.updateBadge(Evernote.context, tab.id);
              } else if (sh.response && sh.response.hasAuthenticationError()) {
                LOG
                    .debug("Error searching for page query because an authentication attempt was made using invalid password");
                self.searchHelperContentScripting.prependContentErrorMessage(
                    tab.id, chrome.i18n
                        .getMessage("searchHelperLoginMessage", [
                            Evernote.context.getEvernoteLoginUrl(),
                            "javascript:" ]));
              } else if (!sh.isActive()) {
                LOG.debug("Error searching for page query");
                Evernote.Utils.updateBadge(Evernote.context, tab.id);
                self.searchHelperContentScripting.clearContentMessages(tab.id);
                if (sh.errors)
                  LOG.error("Error searching for page query");
              } else if (sh.isTransportError()) {
                LOG.debug("Transport error while performing simsearch");
                self.searchHelperContentScripting.prependContentErrorMessage(
                    tab.id, chrome.i18n
                        .getMessage("searchHelperNoTransportError"));
                Evernote.Utils.updateBadge(Evernote.context, tab.id);
              }
            }, true);
  };

  Evernote.ChromeExtension.prototype.getDefaultDesktopNotificationTimeout = function() {
    return this.constructor.DEFAULT_DESKTOP_NOTIFICATION_TIMEOUT;
  };

  Evernote.ChromeExtension.prototype.getCurrentTab = function(fn) {
    chrome.windows.getCurrent(function(win) {
      chrome.tabs.getSelected(win.id, fn);
    });
  };
  Evernote.ChromeExtension.prototype.executeContentScript = function(object,
      callback) {
    this.getCurrentTab(function(tab) {
      chrome.tabs.executeScript(tab.id, object, callback);
    });
  };
})();


/*
 * Evernote
 * ChromeExtensionRemote
 * 
 * Created by Pavel Skaldin on 2/10/11
 * Copyright 2011 Evernote Corp. All rights reserved.
 */
(function() {
  var LOG = null;
  Evernote.ChromeExtensionRemote = function ChromeExtensionRemote() {
    LOG = Evernote.chromeExtension.logger;
    this.initialize();
  };
  Evernote.inherit(Evernote.ChromeExtensionRemote, Evernote.EvernoteRemote,
      true);
  /**
   * Flag indicating whether relogin was attempted using stored credentials.
   * This is used to avoid re-processing requests that results in authentication
   * errors.
   */
  Evernote.ChromeExtensionRemote.prototype._reloginAttempted = false;

  /**
   * Overridden authenticate method. It will notify the extension of
   * authentication status.
   * 
   * @param username
   * @param password
   * @param rememberMe
   * @param success
   * @param failure
   * @param processResponse
   * @return
   */
  Evernote.ChromeExtensionRemote.prototype.authenticate = function(username,
      password, rememberMe, success, failure, processResponse) {
    var successCallback = function(authResponse, authTextStatus, authXhr) {
      if (typeof success == 'function') {
        success(authResponse, authTextStatus, authXhr);
      }
      if (authResponse.hasAuthenticationError()) {
        Evernote.Utils.notifyExtension(new Evernote.RequestMessage(
            Evernote.Constants.RequestType.AUTH_ERROR, authResponse));
      } else {
        Evernote.Utils.notifyExtension(new Evernote.RequestMessage(
            Evernote.Constants.RequestType.AUTH_SUCCESS, authResponse));
      }
    };
    return Evernote.ChromeExtensionRemote.parent.authenticate.apply(this, [
        username, password, rememberMe, successCallback, failure,
        processResponse ]);
  };
  /**
   * Overridden getSyncState method that ensures that if there are stored
   * credentials, its operation is executed on behalf of that user
   * 
   * @param updateCount
   * @param success
   * @param failure
   * @param processResponse
   * @return
   */
  Evernote.ChromeExtensionRemote.prototype.getSyncState = function(updateCount,
      success, failure, processResponse) {
    LOG.debug("ChromeExtensionRemote.getSyncState");
    var self = this;
    var args = arguments;
    var xhr = new Evernote.MutableXMLHttpRequest();
    this._ensureUser(Evernote.context.getOptions(true).username, function() {
      xhr.become(Evernote.ChromeExtensionRemote.parent.getSyncState.apply(self,
          args));
    });
    return xhr;
  };
  Evernote.ChromeExtensionRemote.prototype.clip = function(clipNote, success,
      failure, processResponse) {
    LOG.debug("ChromeExtensionRemote.clip");
    var self = this;
    var args = arguments;
    var xhr = new Evernote.MutableXMLHttpRequest();
    this._ensureUser(Evernote.context.getOptions(true).username, function() {
      xhr.become(Evernote.ChromeExtensionRemote.parent.clip.apply(self, args));
    });
    return xhr;
  };
  Evernote.ChromeExtensionRemote.prototype.file = function(note, success,
      failure, processResponse) {
    LOG.debug("ChromeExtensionRemote.file");
    var self = this;
    var args = arguments;
    var xhr = new Evernote.MutableXMLHttpRequest();
    this._ensureUser(Evernote.context.getOptions(true).username, function() {
      xhr.become(Evernote.ChromeExtensionRemote.parent.file.apply(self, args));
    });
    return xhr;
  };
  Evernote.ChromeExtensionRemote.prototype.deleteNote = function(note, success,
      failure, processResponse) {
    LOG.debug("ChromeExtensionRemote.deleteNote");
    var self = this;
    var args = arguments;
    var xhr = new Evernote.MutableXMLHttpRequest();
    this._ensureUser(Evernote.context.getOptions(true).username, function() {
      xhr.become(Evernote.ChromeExtensionRemote.parent.deleteNote.apply(self,
          args));
    });
    return xhr;
  };
  Evernote.ChromeExtensionRemote.prototype._findNotes = function(noteFilter,
      offset, maxNotes, success, failure, processResponse) {
    LOG.debug("ChromeExtensionRemote._findNotes");
    var self = this;
    var args = arguments;
    var xhr = new Evernote.MutableXMLHttpRequest();
    this._ensureUser(Evernote.context.getOptions(true).username, function() {
      xhr.become(Evernote.ChromeExtensionRemote.parent._findNotes.apply(self,
          args));
    });
    return xhr;
  };
  /**
   * Private method that will ensure that any operation provided by the callback
   * is executed by a user with given username if there are stored credentials.
   * 
   * This is required in order to avoid a situation where the user opts in to
   * store their credentials (expecting the extension to always operate on
   * behalf of that user), but then logs in as another user via the web,
   * replacing original session cookie and authToken. Once that happens, any
   * communication between the extension and the service will be on behalf of
   * the new user. This method will compare its current state and appropriate
   * cookies and will re-authenticate using stored credentials, if needed,
   * before executing the callback.
   * 
   * @param username
   * @param callback
   * @return
   */
  Evernote.ChromeExtensionRemote.prototype._ensureUser = function(username,
      callback) {
    LOG.debug("ChromeExtensionRemote._ensureUser");
    if (!Evernote.context.persistentLogin) {
      callback();
    } else {
      var self = this;
      var authAndExec = function() {
        LOG
            .debug("It appears that the extension isn't operating on behalf of the persistent user, let's try to re-authenticate and re-execute remote operation");
        Evernote.context.removeCookie("auth");
        setTimeout(function() {
          callback();
        }, 100);
      };
      Evernote.context
          .getAuthenticationToken(
              function(authToken) {
                if (Evernote.context.user
                    && Evernote.context.user.username == username
                    && Evernote.context.user.id == authToken.userId) {
                  LOG
                      .debug("Looks like we're operating as the persistent user, executing remote operation");
                  callback();
                } else {
                  authAndExec();
                }
              }, function() {
                authAndExec();
              });
    }
  };
  /**
   * Private method for handling re-authentication and re-processing of requests
   * that resulted in authentication errors. This method uses stored credentials
   * to re-authenticate.
   * 
   * @param origRequest
   * @return
   */
  Evernote.ChromeExtensionRemote.prototype._relogin = function(origRequest) {
    LOG.debug("ChromeExtensionRemote._relogin");
    var self = this;
    var opts = Evernote.context.getOptions(true);
    if (opts.username && opts.password) {
      LOG.debug("Attempting to relogin using stored credentials for: "
          + opts.username);
      this
          .authenticate(
              opts.username,
              Evernote.XORCrypt.decrypt(opts.password, opts.username),
              true,
              function(authResponse, authTextStatus, authXhr) {
                var origSuccess = origRequest.success;
                var origFailure = origRequest.failure;
                origRequest.success = function(r, t, x) {
                  self._reloginAttempted = false;
                  if (typeof origSuccess == 'function') {
                    origSuccess(r, t, x);
                  }
                };
                origRequest.failure = function(x, t, e) {
                  self._reloginAttempted = false;
                  if (typeof origFailure == 'function') {
                    origFailure(x, t, e);
                  }
                };
                if (authResponse && authResponse.isInvalidAuthentication()) {
                  LOG
                      .debug("Handling original success callback due to soft-failed authentication");
                  origRequest.success(authResponse, authTextStatus, authXhr);
                } else if (typeof origSuccess == 'function') {
                  LOG
                      .debug("Retrying original request after successful relogin");
                  self.doRequest.apply(self, origRequest.arguments);
                }
              },
              function(authXhr, authTextStatus, authError) {
                LOG
                    .debug("Failed to reauthenticate, handling original request's failure callback");
                self._reloginAttempted = false;
                if (typeof origRequest.failure == 'function') {
                  origRequest.failure(authXhr, authTextStatus, authError);
                }
              }, true);
      LOG.debug("Marking reloginAttempted");
      this._reloginAttempted = true;
      // we're throwing this to abort any kind of processing in the chain
      throw new Evernote.EvernoteRemoteException(
          Evernote.EvernoteRemoteErrors.ABORTED_RESPONSE_HANDLING);
    }
  };
  Evernote.ChromeExtensionRemote.prototype._dataMarshaller = function(data) {
    LOG.debug("Evernote.ChromeExtensionRemote._dataMarshaller");
    if (typeof Evernote.ChromeExtensionRemote.parent._dataMarshaller == 'function') {
      Evernote.ChromeExtensionRemote.parent._dataMarshaller.apply(this,
          [ data ]);
    }
  };
  Evernote.ChromeExtensionRemote.prototype._dataUnmarshaller = function(result) {
    LOG.debug("Evernote.ChromeExtensionRemote._dataUnmarshaller");
    if (typeof result == 'object') {
      var updated = false;
      for ( var resultKey in result) {
        LOG.debug("Unmarshalling " + resultKey);
        if (result[resultKey] != null) {
          var model = Evernote.AppModel.unmarshall(result[resultKey]);
          result[resultKey] = model;
        } else {
          var model = null;
        }
        switch (resultKey) {
          case "authenticationResult":
            LOG.debug(">>> AUTH RESULT: " + JSON.stringify(model));
            if (typeof model["user"] != "undefined") {
              LOG.debug("Remembering received user");
              Evernote.context.setUser(model["user"]);
            }
            updated = true;
            break;
          case "user":
            LOG.debug("Remembering received user");
            Evernote.context.setUser(model);
            updated = true;
            break;
          case "notebooks":
            LOG.debug("Remembering received notebooks");
            Evernote.context.setNotebooks(model);
            updated = true;
            break;
          case "tags":
            LOG.debug("Remembering received tags");
            Evernote.context.setTags(model);
            updated = true;
            break;
          case "searches":
            LOG.debug("Remembering received searches");
            Evernote.context.setSearches(model);
            updated = true;
            break;
          case "syncState":
            LOG.debug("Remembering received syncState");
            Evernote.context.setSyncState(model);
            updated = true;
            break;
          case "syncChunk":
            LOG.debug("Updating from SyncChunk");
            Evernote.context.processSyncChunk(model);
            updated = true;
            break;
        }
      }
      if (updated) {
        Evernote.Utils.notifyExtension(new Evernote.RequestMessage(
            Evernote.Constants.RequestType.DATA_UPDATED));
      }
    }
    return result;
  };
  Evernote.ChromeExtensionRemote.prototype._wrapSuccessMsgCallback = function(
      code, fn) {
    return function(response, textStatus, xhr) {
      LOG.debug("ChromeExtensionRemote._wrapSuccessMsgCallback");
      if (typeof fn == 'function') {
        // fn.apply(this, arguments);
        fn(response, textStatus, xhr);
      }
      new Evernote.RequestMessage(code, response).send();
    };
  };
  Evernote.ChromeExtensionRemote.prototype._wrapFailureMsgCallback = function(
      code, fn) {
    return function(xhr, textStatus, error) {
      LOG.debug("ChromeExtensionRemote._wrapFailureMsgCallback");
      if (typeof fn == 'function') {
        // fn.apply(this, arguments);
        fn(xhr, textStatus, error);
      }
      new Evernote.RequestMessage(code, xhr).send();
    };
  };
  /**
   * Overridden handleHttpSuccess handler that intercepts successful HTTP
   * responses, inspects them and if there is an authentication problem, while
   * using persistent authentication, will relogin using stored credentials and
   * reprocess original request.
   * 
   * @param data
   * @param textStatus
   * @param xhr
   * @param origRequest
   * @return
   */
  Evernote.ChromeExtensionRemote.prototype.handleHttpSuccess = function(data,
      textStatus, xhr, origRequest) {
    var response = Evernote.ChromeExtensionRemote.parent.handleHttpSuccess
        .apply(this, [ data, textStatus, xhr, origRequest ]);
    if (response.isMissingAuthTokenError() && !this._reloginAttempted
        && origRequest.url != Evernote.getContext().getLoginUrl()) {
      this._relogin(origRequest);
    } else if (response.hasErrorCode(Evernote.EDAMErrorCode.QUOTA_REACHED)) {
      Evernote.Utils.notifyExtension(new Evernote.RequestMessage(
          Evernote.Constants.RequestType.QUOTA_REACHED));
    }
    return response;
  };
})();

/*
 * Evernote
 * EvernoteContext
 * 
 * Created by Pavel Skaldin on 2/23/10
 * Copyright 2010 Evernote Corp. All rights reserved.
 */
(function() {
  var LOG = null;
  Evernote.getContext = function() {
    if (Evernote._context == null) {
      Evernote._context = new Evernote.EvernoteContext();
    }
    return Evernote._context;
  };
  Evernote.__defineGetter__("context", Evernote.getContext);
  Evernote.__defineGetter__("contextInitialized", function() {
    return (Evernote._context) ? true : false;
  });

  /** ************** Evernote.EvernoteContext *************** */

  /**
   * Evernote.EvernoteContext
   * 
   * @return
   */
  Evernote.EvernoteContext = function EvernoteContext() {
    LOG = Evernote.chromeExtension.logger;
    this.__defineGetter__("tags", this.getTags);
    this.__defineSetter__("tags", this.setTags);
    this.__defineGetter__("searches", this.getSearches);
    this.__defineSetter__("searches", this.setSearches);
    this.__defineGetter__("notebooks", this.getNotebooks);
    this.__defineSetter__("notebooks", this.setNotebooks);
    this.__defineGetter__("defaultNotebook", this.getDefaultNotebook);
    this.__defineSetter__("defaultNotebook", this.setDefaultNotebook);
    this.__defineGetter__("syncState", this.getSyncState);
    this.__defineSetter__("syncState", this.setSyncState);
    this.__defineGetter__("user", this.getUser);
    this.__defineSetter__("user", this.setUser);
    this.__defineGetter__("noteFilter", this.getNoteFilter);
    this.__defineSetter__("noteFilter", this.setNoteFilter);
    this.__defineGetter__("remote", this.getRemote);
    this.__defineSetter__("remote", this.setRemote);
    this.__defineGetter__("shardId", this.getShardId);
    this.__defineGetter__("shardedUrl", this.getShardedUrl);
    this.__defineGetter__("store", this.getStore);
    this.__defineSetter__("store", this.setStore);
    this.__defineGetter__("clipProcessor", this.getClipProcessor);
    this.__defineSetter__("clipProcessor", this.setClipProcessor);
    this.__defineGetter__("autosaveProcessor", this.getAutosaveProcessor);
    this.__defineSetter__("autosaveProcessor", this.setAutosaveProcessor);
    this.__defineGetter__("insecureProto", this.getInsecureProto);
    this.__defineSetter__("insecureProto", this.setInsecureProto);
    this.__defineGetter__("secureProto", this.getSecureProto);
    this.__defineSetter__("secureProto", this.setSecureProto);
    this.__defineGetter__("serviceDomain", this.getServiceDomain);
    this.__defineSetter__("serviceDomain", this.setServiceDomain);
    this.__defineGetter__("extensionId", this.getExtensionId);
    this.__defineGetter__("extensionPath", this.getExtensionPath);
    this.__defineGetter__("options", this.getOptions);
    this.__defineSetter__("options", this.setOptions);
    this.__defineGetter__("logLevel", this.getLogLevel);
    this.__defineGetter__("state", this.getState);
    this.__defineSetter__("state", this.setState);
    this.__defineGetter__("autoSavedNote", this.getAutoSavedNote);
    this.__defineSetter__("autoSavedNote", this.setAutoSavedNote);
    this.__defineGetter__("locale", this.getLocale);
    this.__defineSetter__("locale", this.setLocale);
    this.__defineGetter__("persistentLogin", this.isPersistentLogin);
    this.__defineGetter__("userKnown", this.isUserKnown);
    this.__defineGetter__("processLog", this.getProcessLog);
    this.__defineSetter__("processLog", this.setProcessLog);
  };

  Evernote.EvernoteContext.INSECURE_PROTO = "http://";
  Evernote.EvernoteContext.SECURE_PROTO = "https://";
  Evernote.EvernoteContext.SERVICE_DOMAIN = "www.evernote.com";
  Evernote.EvernoteContext.LOGIN_PATH = "/jclip.action?login";
  Evernote.EvernoteContext.LOGOUT_PATH = "/jclip.action?logout";
  Evernote.EvernoteContext.CLIPPER_PATH = "/jclip.action?clip";
  Evernote.EvernoteContext.SYNC_STATE_PATH = "/jclip.action?syncState";
  Evernote.EvernoteContext.REGISTRATION_PATH = "/Registration.action";
  Evernote.EvernoteContext.HOME_PATH = "/";
  Evernote.EvernoteContext.FILE_NOTE_PATH = "/jclip.action?file";
  Evernote.EvernoteContext.DELETE_NOTE_PATH = "/jclip.action?delete";
  Evernote.EvernoteContext.FIND_NOTES_PATH = "/jclip.action?find";
  Evernote.EvernoteContext.EVERNOTE_SEARCH_PATH = "/Home.action";
  Evernote.EvernoteContext.EVERNOTE_PROFILE_PATH = "/User.action";
  Evernote.EvernoteContext.EVERNOTE_LOGIN_PATH = "/Login.action";
  Evernote.EvernoteContext.SHARD_PATH = "/shard";
  Evernote.EvernoteContext.NOTE_VIEW_PATH = "/view.jsp";
  Evernote.EvernoteContext.NOTE_CREATE_PATH = "/edit.jsp?newNote";
  Evernote.EvernoteContext.NOTE_EDIT_PATH = "/edit.jsp";
  Evernote.EvernoteContext.SET_AUTH_TOKEN_PATH = "/SetAuthToken.action";
  Evernote.EvernoteContext.EXTENSION_ID = null;
  Evernote.EvernoteContext.REGISTRATION_CODE = "jsclipper";
  Evernote.EvernoteContext.SESSION_COOKIES = [ "auth", "JSESSIONID" ];

  Evernote.EvernoteContext.prototype._store = null;
  Evernote.EvernoteContext.prototype._clipProcessor = null;
  Evernote.EvernoteContext.prototype._autosaveProcessor = null;
  Evernote.EvernoteContext.prototype._tags = null;
  Evernote.EvernoteContext.prototype._tagGuidMap = null;
  Evernote.EvernoteContext.prototype._tagNameMap = null;
  Evernote.EvernoteContext.prototype._notebookGuidMap = null;
  Evernote.EvernoteContext.prototype._notebookNameMap = null;
  Evernote.EvernoteContext.prototype._searches = null;
  Evernote.EvernoteContext.prototype._notebooks = null;
  Evernote.EvernoteContext.prototype._defaultNotebook = null;
  Evernote.EvernoteContext.prototype._syncState = null;
  Evernote.EvernoteContext.prototype._user = null;
  Evernote.EvernoteContext.prototype._insecureProto = null;
  Evernote.EvernoteContext.prototype._secureProto = null;
  Evernote.EvernoteContext.prototype._serviceDomain = null;
  Evernote.EvernoteContext.prototype._noteFilter = null;
  Evernote.EvernoteContext.prototype._options = null;
  Evernote.EvernoteContext.prototype._autoSavedNote = null;
  Evernote.EvernoteContext.prototype._locale = null;
  Evernote.EvernoteContext.prototype.destroy = function() {
    this.tags = null;
    this.notebooks = null;
    this.searches = null;
    this.noteFilter = null;
    this.defaultNotebook = null;
    this.syncState = null;
    this.user = null;
    this.state = null;
    this.autoSavedNote = null;
    this.clipProcessor = null;
    this.autosaveProcessor = null;
  };
  Evernote.EvernoteContext.PROTO_SUFFIX = "://";
  Evernote.EvernoteContext.isValidServiceProto = function(proto) {
    var re = new RegExp("^https?" + Evernote.EvernoteContext.PROTO_SUFFIX + "$");
    return (typeof proto == 'string' && proto.match(re)) ? true : false;
  };
  Evernote.EvernoteContext.formatServiceProto = function(proto) {
    if (typeof proto == 'string') {
      var re = new RegExp("(" + Evernote.EvernoteContext.PROTO_SUFFIX + ")?$");
      return proto.replace(/^\s+/, "").replace(/\s+$/, "").replace(re,
          Evernote.EvernoteContext.PROTO_SUFFIX);
    } else {
      return proto;
    }
  };
  Evernote.EvernoteContext.prototype.setInsecureProto = function(proto) {
    var changed = false;
    if (typeof proto == 'string' && this._insecureProto != proto) {
      proto = Evernote.EvernoteContext.formatServiceProto(proto);
      if (Evernote.EvernoteContext.isValidServiceProto(proto)
          && this._insecureProto != proto) {
        this._insecureProto = proto;
        changed = true;
      }
    } else if (proto == null && this._insecureProto != null) {
      this._insecureProto = null;
      changed = true;
    }
    if (changed && this.store) {
      this.store.put("insecureProto", this._insecureProto);
    }
  };
  Evernote.EvernoteContext.prototype.getInsecureProto = function() {
    if (this._insecureProto == null && this.store) {
      this._insecureProto = this.store.get("insecureProto");
    }
    return (this._insecureProto) ? this._insecureProto
        : Evernote.EvernoteContext.INSECURE_PROTO;
  };
  Evernote.EvernoteContext.prototype.setSecureProto = function(proto) {
    var changed = false;
    if (typeof proto == 'string' && this._secureProto != proto) {
      proto = Evernote.EvernoteContext.formatServiceProto(proto);
      if (Evernote.EvernoteContext.isValidServiceProto(proto)
          && this._secureProto != proto) {
        this._secureProto = proto;
        changed = true;
      }
    } else if (proto == null && this._secureProto != null) {
      this._secureProto = null;
      changed = true;
    }
    if (changed && this.store) {
      this.store.put("secureProto", this._secureProto);
    }
  };
  Evernote.EvernoteContext.prototype.getSecureProto = function() {
    if (this._secureProto == null && this.store) {
      this._secureProto = this.store.get("secureProto");
    }
    return (this._secureProto != null) ? this._secureProto
        : Evernote.EvernoteContext.SECURE_PROTO;
  };
  Evernote.EvernoteContext.prototype.setServiceDomain = function(domain) {
    var changed = false;
    if (typeof domain == 'string' && this._serviceDomain != domain) {
      this._serviceDomain = domain;
      changed = true;
    } else if (domain == null && this._serviceDomain != null) {
      this._serviceDomain = null;
      changed = true;
    }
    if (changed && this.store) {
      this.store.put("serviceDomain", this._serviceDomain);
    }
  };
  Evernote.EvernoteContext.prototype.getServiceDomain = function() {
    if (this._serviceDomain == null && this.store) {
      this._serviceDomain = this.store.get("serviceDomain");
    }
    return (this._serviceDomain != null) ? this._serviceDomain
        : Evernote.EvernoteContext.SERVICE_DOMAIN;
  };
  Evernote.EvernoteContext.prototype.getServiceUrl = function() {
    return this.insecureProto + this.serviceDomain;
  };
  Evernote.EvernoteContext.prototype.getSecureServiceUrl = function() {
    return this.secureProto + this.serviceDomain;
  };
  Evernote.EvernoteContext.prototype.getLoginUrl = function() {
    return this.getSecureServiceUrl() + Evernote.EvernoteContext.LOGIN_PATH;
  };
  Evernote.EvernoteContext.prototype.getLogoutUrl = function() {
    return this.getSecureServiceUrl() + Evernote.EvernoteContext.LOGOUT_PATH;
  };
  Evernote.EvernoteContext.prototype.getRegistrationUrl = function(code) {
    return this.getSecureServiceUrl()
        + Evernote.EvernoteContext.REGISTRATION_PATH + "?code="
        + Evernote.EvernoteContext.REGISTRATION_CODE;
  };
  Evernote.EvernoteContext.prototype.getHomeUrl = function() {
    return this.getSecureServiceUrl() + Evernote.EvernoteContext.HOME_PATH;
  };
  Evernote.EvernoteContext.prototype.getClipperUrl = function() {
    return this.getSecureServiceUrl() + Evernote.EvernoteContext.CLIPPER_PATH;
  };
  Evernote.EvernoteContext.prototype.getSyncStateUrl = function() {
    return this.getSecureServiceUrl()
        + Evernote.EvernoteContext.SYNC_STATE_PATH;
  };
  Evernote.EvernoteContext.prototype.getFileNoteUrl = function() {
    return this.getSecureServiceUrl() + Evernote.EvernoteContext.FILE_NOTE_PATH;
  };
  Evernote.EvernoteContext.prototype.getDeleteNoteUrl = function() {
    return this.getSecureServiceUrl()
        + Evernote.EvernoteContext.DELETE_NOTE_PATH;
  };
  Evernote.EvernoteContext.prototype.getFindNotesUrl = function() {
    return this.getSecureServiceUrl()
        + Evernote.EvernoteContext.FIND_NOTES_PATH;
  };
  Evernote.EvernoteContext.prototype.getShardId = function() {
    return (this.user instanceof Evernote.User) ? this.user.shardId : null;
  };
  Evernote.EvernoteContext.prototype.getShardedUrl = function() {
    if (this.shardId)
      return this.getSecureServiceUrl() + Evernote.EvernoteContext.SHARD_PATH
          + "/" + this.shardId;
    else
      return null;
  };
  Evernote.EvernoteContext.prototype.getNoteInNotebookUrl = function(noteGuid,
      notebookGuid, words) {
    // /Home.action#v=t&n=7deb1234-9f77-4414-859f-74eacc84e36d&b=344bba7c-ac5d-4505-9f50-70c1a096efb1&x=javascript+&z=d
    var noteUrl = this.getSecureServiceUrl()
        + Evernote.EvernoteContext.EVERNOTE_SEARCH_PATH + "#v=t&n=" + noteGuid
        + "&b=" + notebookGuid;
    if (words) {
      noteUrl += "&x=" + encodeURIComponent(words);
    }
    noteUrl += "&z=d";
    return noteUrl;
  };
  Evernote.EvernoteContext.prototype.getNoteViewUrl = function(noteGuid) {
    // /view.jsp?locale=default&shard=s1#v=t&n=8d3c87f9-6df9-4475-8ebc-45f336cf9757&b=0
    if (this.shardId) {
      return this.getSecureServiceUrl()
          + Evernote.EvernoteContext.NOTE_VIEW_PATH + "?shard=" + this.shardId
          + "#v=t&n=" + noteGuid;
    } else {
      return null;
    }
  };
  Evernote.EvernoteContext.prototype.getNoteCreateUrl = function() {
    return this.getSecureServiceUrl()
        + Evernote.EvernoteContext.NOTE_CREATE_PATH;
  };
  Evernote.EvernoteContext.prototype.getNoteEditUrl = function(noteGuid) {
    return this.getSecureServiceUrl() + Evernote.EvernoteContext.NOTE_EDIT_PATH
        + "?shard=" + this.shardId + "#v=t&n=" + noteGuid;
  };
  Evernote.EvernoteContext.prototype.getEvernoteSearchUrl = function(words,
      isAny) {
    // /Home.action#v=t&b=0&x=javascript+examples
    var q = (typeof words == 'string') ? words.replace(/\s+/g, " ") : "";
    return this.getSecureServiceUrl()
        + Evernote.EvernoteContext.EVERNOTE_SEARCH_PATH + "#v=t&b=0&o="
        + ((isAny) ? "n" : "l") + "&x=" + encodeURIComponent(q);
  };
  Evernote.EvernoteContext.prototype.getEvernoteLoginUrl = function() {
    return this.getSecureServiceUrl()
        + Evernote.EvernoteContext.EVERNOTE_LOGIN_PATH;
  };
  Evernote.EvernoteContext.prototype.getEvernoteProfileUrl = function() {
    return this.getSecureServiceUrl()
        + Evernote.EvernoteContext.EVERNOTE_PROFILE_PATH;
  };
  Evernote.EvernoteContext.prototype.getSetAuthTokenUrl = function(authToken,
      url) {
    var authUrl = this.getSecureServiceUrl()
        + Evernote.EvernoteContext.SET_AUTH_TOKEN_PATH;
    authUrl += "?auth=" + encodeURIComponent(authToken) + "&targetUrl="
        + encodeURIComponent(url);
    return authUrl;
  };
  Evernote.EvernoteContext.prototype.getLocale = function() {
    if (!this._locale) {
      this._locale = chrome.i18n.getMessage("@@ui_locale");
    }
    return this._locale;
  };
  Evernote.EvernoteContext.prototype.setLocale = function(locale) {
    this._locale = (typeof locale == 'string' && locale.length > 0) ? locale
        : null;
  };
  Evernote.EvernoteContext.prototype.isPersistentLogin = function() {
    var opts = this.getOptions(true);
    return (opts && opts.username && opts.password) ? true : false;
  };
  Evernote.EvernoteContext.prototype.isUserKnown = function() {
    return ((this.user && this.user.username) || this.isPersistentLogin()) ? true
        : false;
  };
  Evernote.EvernoteContext.prototype.getExtensionId = function() {
    if (Evernote.EvernoteContext.EXTENSION_ID == null) {
      var bgUrl = chrome.extension.getBackgroundPage().location.href;
      if (bgUrl) {
        var extensionId = bgUrl.replace(/^chrome-extension:\/\/([^\/]+).*$/,
            "$1");
        if (extensionId != null && typeof extensionId != 'undefined') {
          Evernote.EvernoteContext.EXTENSION_ID = extensionId;
        }
      }
    }
    return Evernote.EvernoteContext.EXTENSION_ID;
  };
  Evernote.EvernoteContext.prototype.getExtensionPath = function(path) {
    return "chrome-extension://" + this.extensionId + "/"
        + ((typeof path == 'string') ? path : "");
  };
  /**
   * This is a Google Chrome specific implementation. Pay attention!!! Required
   * arguments are 'cookieName', 'success' and 'fail'. If the cookie with
   * cookieName is found - 'success' function will be called, with found Cookie
   * as the only argument; otherwise 'fail' function will be called.
   * 
   * Optionally, you can specify 'storeId' which would indicate which
   * CookieStore will be searched for the named cookie. If it is not specified,
   * all of the CookieStore's will be searched. In which case, while iterating
   * thru every CookieStore, this function will be called with the same
   * arguments, except current storeId will be specified and 'stores' parameter
   * will contain an exhausting array of CookieStore's that haven't been
   * iterated yet.
   * 
   * In other words - use this method with three arguments if you need to search
   * all the CookieStore's; or with four parameters if you are after a specific
   * CookieStore.
   * 
   * @param cookieName
   *          Name of the cookie to retrieve - required!
   * @param success
   *          Function to call if the named cookie was found
   * @param fail
   *          Function to call if the named cookie was not found
   * @param cookieId
   *          String id of CookieStore from which to retreive cookies. If not
   *          specified, all the stores will be searched.
   * @param stores
   *          Array of CookieStore objects. This is used when iterating thru all
   *          the CookieStore's.
   */
  Evernote.EvernoteContext.prototype.getCookie = function(cookieName, success,
      fail, storeId, stores) {
    var self = this;
    if (typeof chrome == 'object' && chrome != null && chrome.cookies) {
      var opts = {
        url : this.getSecureServiceUrl(),
        name : cookieName
      };
      if (storeId) {
        opts.storeId = storeId;
        chrome.cookies.get(opts, function(cookie) {
          if (typeof cookie == 'object' && cookie != null && cookie.value) {
            success(cookie);
          } else if (stores instanceof Array && stores.length > 0) {
            var store = stores.pop();
            self.getCookie(cookieName, success, fail, store.id, stores);
          } else {
            fail();
          }
        });
      } else {
        chrome.cookies.getAllCookieStores(function(stores) {
          if (stores instanceof Array && stores.length > 0) {
            var store = stores.pop();
            self.getCookie(cookieName, success, fail, store.id, stores);
          } else {
            fail();
          }
        });
      }
    } else if (typeof fail == 'function') {
      setTimeout(fail, 0);
    }
  };
  Evernote.EvernoteContext.prototype.removeCookie = function(cookieName,
      storeId) {
    if (typeof chrome == 'object' && chrome != null && chrome.cookies) {
      var self = this;
      var opts = {
        url : this.getSecureServiceUrl(),
        name : cookieName
      };
      if (storeId) {
        opts.storeId = storeId;
        chrome.cookies.remove(opts);
      } else {
        chrome.cookies.getAllCookieStores(function(stores) {
          if (stores instanceof Array) {
            for ( var s = 0; s < stores.length; s++) {
              self.removeCookie(cookieName, stores[s].id);
            }
          }
        });
      }
    }
  };
  Evernote.EvernoteContext.prototype.setCookie = function(cookieName,
      cookieValue, expiry, secure, storeId) {
    if (typeof chrome == 'object' && chrome != null && chrome.cookies) {
      var self = this;
      var opts = {
        url : this.getSecureServiceUrl(),
        name : cookieName,
        value : cookieValue,
        path : "/"
      };
      if (secure) {
        opts.secure = true;
      } else {
        opts.secure = false;
      }
      var expires = parseInt(expiry);
      if (!isNaN(expires)) {
        opts.expirationDate = expires;
      }
      if (storeId) {
        opts.storeId = storeId;
      }
      chrome.cookies.set(opts);
    }
  };
  Evernote.EvernoteContext.prototype.removeSessionCookies = function() {
    for ( var i = 0; i < Evernote.EvernoteContext.SESSION_COOKIES.length; i++) {
      this.removeCookie(Evernote.EvernoteContext.SESSION_COOKIES[i]);
    }
  };
  Evernote.EvernoteContext.prototype.getAuthenticationToken = function(success,
      error) {
    this.getCookie("auth", function(cookie) {
      var authToken = Evernote.AuthenticationToken.decode(cookie.value);
      if (typeof success == 'function') {
        success(authToken);
      }
    }, error);
  };
  Evernote.EvernoteContext.prototype.setRemote = function(remote) {
    if (remote instanceof Evernote.EvernoteRemote) {
      this._remote = remote;
    }
  };
  Evernote.EvernoteContext.prototype.getRemote = function() {
    if (!this._remote) {
      this._remote = new Evernote.ChromeExtensionRemote();
    }
    return this._remote;
  };
  Evernote.EvernoteContext.prototype.setStore = function(store) {
    if (store instanceof Evernote.LocalStore)
      this._store = store;
    else if (store == null)
      this._store = null;
  };
  Evernote.EvernoteContext.prototype.getStore = function() {
    if (!this._store && Evernote.chromeExtension.localStore) {
      this._store = Evernote.chromeExtension.localStore;
    }
    return this._store;
  };
  Evernote.EvernoteContext.prototype.setClipProcessor = function(processor) {
    if (processor instanceof Evernote.QueueProcessor || processor == null) {
      this._clipProcessor = processor;
    }
  };
  Evernote.EvernoteContext.prototype.getClipProcessor = function() {
    if (!this._clipProcessor) {
      this._clipProcessor = Evernote.chromeExtension.clipProcessor;
    }
    return this._clipProcessor;
  };
  Evernote.EvernoteContext.prototype.isClipProcessorStarted = function() {
    return (this._clipProcessor && this._clipProcessor.isStarted());
  };
  Evernote.EvernoteContext.prototype.setAutosaveProcessor = function(processor) {
    if (processor instanceof Evernote.QueueProcessor || processor == null) {
      this._autosaveProcessor = processor;
    }
  };
  Evernote.EvernoteContext.prototype.getAutosaveProcessor = function() {
    if (!this._autosaveProcessor) {
      this._autosaveProcessor = Evernote.chromeExtension.autosaveProcessor;
    }
    return this._autosaveProcessor;
  };
  Evernote.EvernoteContext.prototype.isAutosaveProcessorStarted = function() {
    return (this._autosaveProcessor && this._autosaveProcessor.isStarted());
  };
  Evernote.EvernoteContext.prototype.hasAutosavedNote = function() {
    return (this.getAutoSavedNote(true)) ? true : false;
    // pasha: commented out for now because we're not using autosaveProcessor at
    // the moment
    // return (this.autosaveProcessor.queue.length > 0);
  };
  Evernote.EvernoteContext.prototype.isInSync = function() {
    return (this.getSyncState()) ? true : false;
  };
  Evernote.EvernoteContext.prototype.setUser = function(user) {
    var changed = false;
    if (user instanceof Evernote.User) {
      this._user = user;
      changed = true;
    } else if (user == null) {
      this._user = null;
      changed = true;
    }
    if (this.store && changed) {
      if (this._user != null)
        this.store.put("user", this._user);
      else
        this.store.remove("user");
    }
  };
  Evernote.EvernoteContext.prototype.getUser = function(force) {
    if ((this._user == null || force) && this.store != null) {
      var user = this.store.get("user");
      if (user) {
        this._user = new Evernote.User(user);
      } else {
        this._user = null;
      }
    }
    return this._user;
  };
  Evernote.EvernoteContext.prototype.getTags = function() {
    if (this._tags == null && this.store != null) {
      var tags = this.store.get("tags");
      if (tags && typeof tags.length == 'number') {
        this._tags = new Array();
        for ( var i = 0; i < tags.length; i++) {
          var tag = new Evernote.Tag(tags[i]);
          this._tags.push(tag);
        }
      }
    }
    return this._tags;
  };
  Evernote.EvernoteContext.prototype.setTags = function(tags) {
    var changed = false;
    if (tags == null) {
      this._tags = null;
      changed = true;
    } else if (tags instanceof Evernote.Tag) {
      this._tags = [ tags ];
      changed = true;
    } else if (tags instanceof Array) {
      this._tags = tags;
      changed = true;
    }
    if (changed) {
      this._tagGuidMap = null;
      this._tagNameMap = null;
    }
    if (this.store && changed) {
      if (this._tags)
        this.store.put("tags", this._tags);
      else
        this.store.remove("tags");
    }
  };
  Evernote.EvernoteContext.prototype.getTagNames = function() {
    var tags = this.getTags();
    var tagNames = new Array();
    if (tags) {
      for ( var i = 0; i < tags.length; i++) {
        tagNames.push(tags[i].name);
      }
    }
    return tagNames;
  };
  Evernote.EvernoteContext.prototype.getTagByGuid = function(guid) {
    var tagMap = this.getTagGuidMap();
    if (typeof guid == 'string' && typeof tagMap[guid] != 'undefined')
      return tagMap[guid];
    return null;
  };
  Evernote.EvernoteContext.prototype.getTagByName = function(name) {
    if (typeof name == 'string') {
      var tagMap = this.getTagNameMap();
      return tagMap[name.toLowerCase()];
    }
    return null;
  };
  Evernote.EvernoteContext.prototype.getTagGuidMap = function() {
    if (this._tagGuidMap == null && this.tags) {
      this._tagGuidMap = {};
      for ( var i = 0; i < this._tags.length; i++) {
        this._tagGuidMap[this._tags[i].guid] = this._tags[i];
      }
    }
    return this._tagGuidMap;
  };
  Evernote.EvernoteContext.prototype.getTagNameMap = function() {
    if (this._tagNameMap == null && this.tags) {
      this._tagNameMap = {};
      for ( var i = 0; i < this._tags.length; i++) {
        this._tagNameMap[this._tags[i].name.toLowerCase()] = this._tags[i];
      }
    }
    return this._tagNameMap;
  };
  Evernote.EvernoteContext.prototype.getNotebooks = function() {
    if (this._notebooks == null && this.store != null) {
      var notebooks = this.store.get("notebooks");
      if (notebooks && typeof notebooks.length == 'number') {
        this._notebooks = new Array();
        for ( var i = 0; i < notebooks.length; i++) {
          this._notebooks.push(new Evernote.Notebook(notebooks[i]));
        }
      }
    }
    return this._notebooks;
  };
  Evernote.EvernoteContext.prototype.setNotebooks = function(notebooks) {
    var changed = false;
    if (notebooks == null) {
      this._notebooks = null;
      this._defaultNotebook = null;
      changed = true;
    } else if (notebooks instanceof Evernote.Notebook) {
      this._notebooks = [ notebooks ];
      this._defaultNotebook = null;
      changed = true;
    } else if (notebooks instanceof Array) {
      this._notebooks = this._sortModelsByField(notebooks, "name");
      this._defaultNotebook = null;
      changed = true;
    }
    if (changed) {
      this._notebookGuidMap = null;
      this._notebookNameMap = null;
    }
    if (this.store && changed) {
      if (this._notebooks) {
        this.store.put("notebooks", this._notebooks);
      } else {
        this.store.remove("notebooks");
      }
    }
  };
  Evernote.EvernoteContext.prototype.getNotebookNames = function() {
    var notebooks = this.getNotebooks();
    var notebookNames = new Array();
    if (notebooks) {
      for ( var i = 0; i < notebooks.length; i++) {
        notebookNames.push(notebooks[i].name);
      }
    }
    return notebookNames;
  };
  Evernote.EvernoteContext.prototype.getNotebookGuidMap = function() {
    if (this._notebookGuidMap == null && this.notebooks) {
      this._notebookGuidMap = {};
      for ( var i = 0; i < this._notebooks.length; i++) {
        this._notebookGuidMap[this._notebooks[i].guid] = this._notebooks[i];
      }
    }
    return this._notebookGuidMap;
  };
  Evernote.EvernoteContext.prototype.getNotebookNameMap = function() {
    if (this._notebookNameMap == null && this.notebooks) {
      this._notebookNameMap = {};
      for ( var i = 0; i < this._notebooks.length; i++) {
        this._notebookNameMap[this._notebooks[i].name] = this._notebooks[i];
      }
    }
    return this._notebookNameMap;
  };
  Evernote.EvernoteContext.prototype.getNotebookByGuid = function(guid) {
    if (typeof guid == 'string') {
      var guidMap = this.getNotebookGuidMap();
      if (guidMap) {
        return guidMap[guid];
      }
    }
    return null;
  };
  Evernote.EvernoteContext.prototype.getNotebookByName = function(name) {
    if (typeof name == 'string') {
      var nameMap = this.getNotebookNameMap();
      if (nameMap) {
        return nameMap[name];
      }
    }
    return null;
  };
  Evernote.EvernoteContext.prototype.getDefaultNotebook = function() {
    var userNotebooks = this.notebooks;
    if (this._defaultNotebook == null && userNotebooks instanceof Array) {
      for ( var i = 0; i < userNotebooks.length; i++) {
        if (userNotebooks[i].defaultNotebook) {
          this._defaultNotebook = userNotebooks[i];
          break;
        }
      }
    }
    return this._defaultNotebook;
  };
  Evernote.EvernoteContext.prototype.setDefaultNotebook = function(notebook) {
    if (notebook instanceof Evernote.Notebook)
      this._defaultNotebook = notebook;
  };
  Evernote.EvernoteContext.prototype.getPreferredNotebook = function() {
    var preferredNotebook = null;
    var stateNotebookGuid = null;
    if (this.options) {
      if (this.options.clipNotebook == Evernote.Options.CLIP_NOTEBOOK_OPTIONS.SELECT
          && this.options.clipNotebookGuid
          && this.getNotebookByGuid(this.options.clipNotebookGuid)) {
        preferredNotebook = this
            .getNotebookByGuid(this.options.clipNotebookGuid);
      } else if (this.options.clipNotebook == Evernote.Options.CLIP_NOTEBOOK_OPTIONS.REMEMBER
          && (stateNotebookGuid = this.getState(true).notebookGuid)) {
        preferredNotebook = this.getNotebookByGuid(stateNotebookGuid);
      }
    }
    return (preferredNotebook) ? preferredNotebook : this.getDefaultNotebook();
  };
  Evernote.EvernoteContext.prototype.setSearches = function(searches) {
    var changed = false;
    if (searches == null) {
      this._searches = null;
      changed = true;
    } else if (searches instanceof Evernote.SavedSearch) {
      this._searches = [ searches ];
      changed = true;
    } else if (searches instanceof Array) {
      this._searches = searches;
      changed = true;
    }
    if (this.store && changed) {
      if (this._searches)
        this.store.put("searches", this._searches);
      else
        this.store.remove("searches");
    }
  };
  Evernote.EvernoteContext.prototype.getSearches = function() {
    if (this._searches == null && this.store != null) {
      var searches = this.store.get("searches");
      if (searches && typeof searches.length == 'number') {
        this._searches = new Array();
        for ( var i = 0; i < searches.length; i++) {
          var search = new Evernote.SavedSearch(searches[i]);
          this._searches.push(search);
        }
      }
    }
    return this._searches;
  };
  Evernote.EvernoteContext.prototype.setNoteFilter = function(noteFilter) {
    var changed = false;
    if (noteFilter instanceof Evernote.NoteFilter) {
      this._noteFilter = noteFilter;
      changed = true;
    } else if (noteFilter == null) {
      this._noteFilter = null;
      changed = true;
    }
    if (changed && this.store) {
      if (this._noteFilter)
        this.store.put("noteFilter", this._noteFilter);
      else
        this.store.remove("noteFilter");
    }
  };
  Evernote.EvernoteContext.prototype.getNoteFilter = function() {
    if (this._noteFilter == null && this.store) {
      var noteFilter = this.store.get("noteFilter");
      if (noteFilter) {
        this._noteFilter = new Evernote.NoteFilter(noteFilter);
      }
    }
    if (this._noteFilter == null) {
      this._noteFilter = new Evernote.NoteFilter();
      this._noteFilter.fuzzy = true;
    }
    var sortOrder = this.options.noteSortOrder;
    if (sortOrder) {
      this._noteFilter.order = sortOrder.order;
      this._noteFilter.ascending = sortOrder.ascending;
    }
    return this._noteFilter;
  };
  Evernote.EvernoteContext.prototype.getSyncState = function() {
    if (this._syncState == null && this.store != null) {
      var syncState = this.store.get("syncState");
      if (syncState) {
        this._syncState = new Evernote.SyncState(syncState);
      }
    }
    return this._syncState;
  };
  Evernote.EvernoteContext.prototype.setSyncState = function(syncState) {
    if (syncState instanceof Evernote.SyncState) {
      this._syncState = syncState;
      if (this.store)
        this.store.put("syncState", this._syncState);
    } else if (syncState == null) {
      this._syncState = null;
      if (this.store)
        this.store.remove("syncState");
    }
  };
  Evernote.EvernoteContext.prototype.processSyncChunk = function(syncChunk) {
    if (syncChunk instanceof Evernote.SyncChunk) {
      if (syncChunk.expungedNotebooks.length > 0) {
        LOG.debug("Expunging " + syncChunk.expungedNotebooks.length
            + " notebooks");
        this.notebooks = this._expungeModels(this.notebooks,
            syncChunk.expungedNotebooks);
        LOG.debug("Now we have " + this.notebooks.length + " notebooks");
      }
      if (syncChunk.notebooks.length > 0) {
        LOG.debug("Merging " + syncChunk.notebooks.length + " notebooks");
        this.notebooks = this._mergeModels(this.notebooks, syncChunk.notebooks);
        LOG.debug("Now we have " + this.notebooks.length + " notebooks");
      }
      if (syncChunk.expungedTags.length > 0) {
        LOG.debug("Expunging " + syncChunk.expungedTags.length + " tags");
        this.tags = this._expungeModels(this.tags, syncChunk.expungedTags);
        LOG.debug("Now we have " + this.tags.length + " tags");
      }
      if (syncChunk.tags.length > 0) {
        LOG.debug("Merging " + syncChunk.tags.length + " tags");
        this.tags = this._mergeModels(this.tags, syncChunk.tags);
        LOG.debug("Now we have " + this.tags.length + " tags");
      }
      if (syncChunk.chunkHighUSN > 0 && this.syncState) {
        this.syncState.updateCount = syncChunk.chunkHighUSN;
        if (syncChunk.currentTime)
          this.syncState.currentTime = syncChunk.currentTime;
      }
    }
  };
  Evernote.EvernoteContext.prototype.resetSyncState = function() {
    LOG.debug("Resetting syncState");
    if (this._syncState != null) {
      this.setSyncState(null);
      this.setUser(null);
      this.setTags(null);
      this.setNotebooks(null);
      this.setDefaultNotebook(null);
    }
  };
  Evernote.EvernoteContext.prototype.setOptions = function(options) {
    var changed = false;
    if (options instanceof Evernote.Options) {
      this._options = options;
      changed = true;
    } else if (options == null) {
      this._options = null;
      changed = true;
    }
    if (changed && this.store) {
      if (this.options)
        this.store.put("options", this._options);
      else
        this.store.remove("options");
    }
  };
  Evernote.EvernoteContext.prototype.getOptions = function(force) {
    if (this.store && (this._options == null || force)) {
      var opts = this.store.get("options");
      if (opts) {
        this._options = new Evernote.Options(this, opts);
      }
    }
    if (this._options == null) {
      this._options = new Evernote.Options(this, {
        secureProto : this.secureProto,
        insecureProto : this.insecureProto,
        serviceDomain : this.serviceDomain
      });
    }
    return this._options;
  };
  Evernote.EvernoteContext.prototype.getLogLevel = function() {
    return this.options.debugLevel;
  };
  Evernote.EvernoteContext.prototype.setState = function(state) {
    var changed = false;
    if (state instanceof Evernote.AppState) {
      this._state = state;
      changed = true;
    } else if (state == null) {
      this._state = null;
      changed = true;
    }
    if (changed && this.store) {
      if (this._state)
        this.store.put("state", this._state);
      else
        this.store.remove("state");
    }
  };
  Evernote.EvernoteContext.prototype.getState = function(force) {
    if ((this._state == null || force) && this.store) {
      var state = this.store.get("state");
      if (state) {
        this._state = new Evernote.AppState(state);
      }
    }
    if (this._state == null) {
      this._state = new Evernote.AppState();
    }
    return this._state;
  };
  Evernote.EvernoteContext.prototype.setAutoSavedNote = function(clipNote) {
    var changed = false;
    if (clipNote instanceof Evernote.ClipNote) {
      this._autoSavedNote = clipNote;
      changed = true;
    } else if (clipNote == null) {
      this._autoSavedNote = null;
      changed = true;
    }
    if (changed && this.store) {
      if (this._autoSavedNote)
        this.store.put("autoSavedNote", this._autoSavedNote);
      else
        this.store.remove("autoSavedNote");
    }
  };
  Evernote.EvernoteContext.prototype.getAutoSavedNote = function(force) {
    if (this.store && (this._autoSavedNote == null || force)) {
      var clipNote = this.store.get("autoSavedNote");
      if (clipNote) {
        this._autoSavedNote = new Evernote.ClipNote(clipNote);
      } else {
        this._autoSavedNote = null;
      }
    }
    return this._autoSavedNote;
  };
  Evernote.EvernoteContext.prototype.getPreferredStylingStrategyName = function() {
    var opts = this.getOptions(true);
    var ss = null;
    if (opts && opts.clipStyle == Evernote.Options.CLIP_STYLE_OPTIONS.TEXT) {
      ss = "ClipTextStylingStrategy";
    } else if (opts
        && opts.clipStyle == Evernote.Options.CLIP_STYLE_OPTIONS.FULL) {
      ss = "ClipFullStylingStrategy";
    }
    return ss;
  };
  Evernote.EvernoteContext.prototype.getPreferredStylingStrategyQualifier = function() {
    var ss = this.getPreferredStylingStrategyName();
    if (ss) {
      return "Evernote." + ss;
    } else {
      return "null";
    }
  };
  Evernote.EvernoteContext.prototype.getProcessLog = function(force) {
    if (this.store && (!this._processLog || force)) {
      var log = this.store.get("processLog");
      if (log) {
        this._processLog = Evernote.ProcessLog.fromObject(log);
      } else {
        this._processLog = new Evernote.ProcessLog();
      }
    } else if (!this._processLog) {
      this._processLog = new Evernote.ProcessLog();
    }
    return this._processLog;
  };
  Evernote.EvernoteContext.prototype.setProcessLog = function(log) {
    var changed = false;
    if (log instanceof Evernote.ProcessLog || null) {
      this._processLog = log;
      changed = true;
    }
    if (changed) {
      this.updateProcessLog();
    }
  };
  Evernote.EvernoteContext.prototype.updateProcessLog = function() {
    if (this.store) {
      if (this._processLog) {
        this.store.put("processLog", this._processLog);
      } else {
        this.store.remove("processLog");
      }
    }
  };

  Evernote.EvernoteContext.prototype._expungeModels = function(models, guids) {
    if (models instanceof Array && guids instanceof Array) {
      var guidKeys = {};
      var result = new Array();
      for ( var i = 0; i < guids.length; i++) {
        LOG.debug("Adding guid: " + guids[i]);
        guidKeys[guids[i]] = guids[i];
      }
      for ( var i = 0; i < models.length; i++) {
        LOG.debug("Checking if we have: " + models[i].guid);
        if (typeof guidKeys[models[i].guid] == 'undefined') {
          LOG.debug("No we don't, keeping then...");
          result.push(models[i]);
        }
      }
      LOG.debug("Expunged " + (models.length - result.length) + " models");
      return result;
    }
    LOG.warn("There was nothing to expunge");
    return models;
  };
  Evernote.EvernoteContext.prototype._mergeModels = function(oldModels,
      newModels) {
    if (oldModels instanceof Array && newModels instanceof Array) {
      // return oldModels.concat(newModels);
      var map = {};
      var result = new Array();
      for ( var i = 0; i < newModels.length; i++) {
        if (typeof newModels[i]["guid"] != 'undefined')
          map[newModels[i].guid] = newModels[i];
      }
      var newModelCount = 0;
      var oldModelCount = 0;
      var updatedModelCount = 0;
      for ( var i = 0; i < oldModels.length; i++) {
        if (typeof map[oldModels[i].guid] != 'undefined') {
          updatedModelCount++;
          result.push(map[oldModels[i].guid]);
          delete map[oldModels[i].guid];
        } else {
          oldModelCount++;
          result.push(oldModels[i]);
        }
      }
      for ( var i in map) {
        newModelCount++;
        result.push(map[i]);
      }
      LOG.debug("Updated " + updatedModelCount + " models; Kept "
          + oldModelCount + " models; Added: " + newModelCount);
      return result;
    } else if (newModels instanceof Array) {
      LOG.warn("There were no models to merge into");
      return newModels;
    }
    LOG.warn("There were no models to merge");
    return oldModels;
  };
  Evernote.EvernoteContext.prototype._sortModelsByField = function(models,
      fieldName) {
    if (models instanceof Array) {
      return models.sort(function(a, b) {
        var aField = "";
        var bField = "";
        if (typeof a[fieldName] != 'undefined') {
          aField = a[fieldName].toLowerCase();
        }
        if (typeof b[fieldName] != 'undefined') {
          bField = b[fieldName].toLowerCase();
        }
        if (aField == bField)
          return 0;
        else if (aField < bField)
          return -1;
        else
          return 1;
      });
    }
    return models;
  };
})();

/*
 * Evernote.ViewManager
 * Evernote
 * 
 * Created by Pavel Skaldin on 2/23/10
 * Copyright 2010 Evernote Corp. All rights reserved.
 */
(function() {
  var LOG = null;
  Evernote.ViewManager = function ViewManager() {
    this.__defineGetter__("quiet", this.isQuiet);
    this.__defineSetter__("quiet", this.setQuiet);
    LOG = Evernote.chromeExtension.logger;
  };

  Evernote.ViewManager._instance = null;
  Evernote.ViewManager.FORM_FIELD_ERROR_CLASS = "error";
  Evernote.ViewManager.FORM_FIELD_ERROR_MESSAGE_CLASS = "error";
  Evernote.ViewManager.FORM_FIELD_ERROR_MESSAGE_ELEMENT = "div";
  Evernote.ViewManager.PAGE_HEIGHT_DELTA = 0;

  Evernote.ViewManager.getInstance = function() {
    if (!this._instance) {
      this._instance = new Evernote.ViewManager();
    }
    return this._instance;
  };

  // instance variables
  Evernote.ViewManager.prototype.currentView = null;
  Evernote.ViewManager.prototype.globalMessage = null;
  Evernote.ViewManager.prototype.globalErrorMessage = null;
  // whether messages will be shown
  Evernote.ViewManager.prototype._quiet = false;

  Evernote.ViewManager.prototype.setQuiet = function(bool) {
    this._quiet = (bool) ? true : false;
  };
  Evernote.ViewManager.prototype.isQuiet = function() {
    return this._quiet;
  };
  Evernote.ViewManager.prototype.getEffectiveHeight = function() {
    LOG.debug("Evernote.ViewManager.getEffectiveHeight");
    var h = 0;
    $("body > div").each(
        function(i, element) {
          var e = $(element);
          if (e.css("display") != "none" && !e.hasClass("banner")
              && !e.hasClass("drawer") && !e.hasClass("drawerHandleTitle")) {
            // LOG.debug(">>> " + e.attr("tagName")
            // +
            // "#" + e.attr("id") + "." +
            // e.attr("class") + ": " + e.innerHeight());
            h += e.innerHeight();
          }
        });
    h = h - this.constructor.PAGE_HEIGHT_DELTA;
    if (h < 0)
      h = 0;
    return h;
  };
  Evernote.ViewManager.prototype.updateBodyHeight = function(height) {
    // LOG.debug("Evernote.ViewManager.updateBodyHeight");
    var h = (typeof height == 'number') ? height : this.getEffectiveHeight();
    /*
     * $("body").css( { height : h + "px" });
     */
    $("body").animate( {
      height : h + "px"
    }, 10);
    // LOG.debug(">>> BODY HEIGHT: " + h + " : " +
    // $("body").height());
  };

  Evernote.ViewManager.prototype.showBlock = function(block, dataArray) {
    block.show();
    if (dataArray instanceof Array)
      block.trigger("show", dataArray);
    else
      block.trigger("show");
    this.updateBodyHeight();
  };
  Evernote.ViewManager.prototype.hideBlock = function(block, dataArray) {
    block.hide();
    if (dataArray instanceof Array)
      block.trigger("hide", dataArray);
    else
      block.trigger("hide");
    this.updateBodyHeight();
  };

  Evernote.ViewManager.prototype.showView = function(viewNameOrBlock, data) {
    if (viewNameOrBlock instanceof jQuery) {
      var view = viewNameOrBlock;
    } else {
      var view = $("#" + viewNameOrBlock);
    }
    if (view.length == 0)
      return null;
    this.showBlock(view, [ data ]);
    return view;
  };

  Evernote.ViewManager.prototype.hideView = function(viewNameOrBlock) {
    if (viewNameOrBlock instanceof jQuery) {
      var view = viewNameOrBlock;
    } else {
      var view = $("#" + viewNameOrBlock);
    }
    if (view.length == 0 || view.css("display") == "none")
      return null;
    this.hideBlock(view);
    if (this.currentView && view.attr("id") == this.currentView.attr("id")) {
      this.currentView = null;
    }
    return view;
  };

  Evernote.ViewManager.prototype.switchView = function(viewName, data) {
    LOG.debug("Evernote.ViewManager.switchView");
    var visibleView = null;
    var view = (viewName instanceof jQuery) ? viewName : $("#" + viewName);
    if (this.currentView && this.currentView.attr("id") == view.attr("id")) {
      LOG.debug("Already showing...");
      return;
    }
    if (this.currentView) {
      this.hideView(this.currentView.attr("id"));
    }
    if (visibleView = this.showView(viewName, data)) {
      this.currentView = visibleView;
    }
    return visibleView;
  };
  
  Evernote.ViewManager.prototype.switchElements = function(a, b) {
    a.hide();
    b.show();
  };

  Evernote.ViewManager.prototype.wait = function(msg) {
    var spinnerBlock = $("#spinner");
    spinnerBlock.find("#spinnerMessage").html(msg);
    spinnerBlock.show();
  };

  Evernote.ViewManager.prototype.clearWait = function() {
    var spinnerBlock = $("#spinner");
    spinnerBlock.hide();
  };

  Evernote.ViewManager.prototype.showMessage = function(message) {
    if (this.quiet)
      return;
    if (this.globalMessage) {
      this.globalMessage.addMessage(message);
      this.globalMessage.show();
    }
  };
  Evernote.ViewManager.prototype.hideMessage = function(message) {
    if (this.globalMessage) {
      this.globalMessage.removeMessage(message);
      if (this.globalMessage.length() > 0) {
        this.globalMessage.show();
      } else {
        this.globalMessage.hide();
      }
    }
  };
  Evernote.ViewManager.prototype.hideAllMessages = function() {
    if (this.globalMessage) {
      this.globalMessage.removeAllMessages();
      this.globalMessage.hide();
    }
  };

  Evernote.ViewManager.prototype.extractErrorMessage = function(e,
      defaultMessage) {
    LOG.debug("Evernote.ViewManager.extractErrorMessage");
    var msg = (typeof defaultMessage != 'undefined') ? defaultMessage : null;
    LOG
        .debug("Error: "
            + (typeof e == 'object' && e != null && typeof e["toString"] == 'function') ? e
            .toString()
            : e);
    if (e instanceof Evernote.EvernoteError
        && typeof e.errorCode == 'number'
        && typeof e.parameter == 'string'
        && this.getLocalizedMessage("EDAMError_" + e.errorCode + "_"
            + e.parameter.replace(/[^a-zA-Z0-9_]+/g, "_"))) {
      LOG
          .debug("Got parameterized localized message for Evernote.EvernoteError");
      msg = this.getLocalizedMessage("EDAMError_" + e.errorCode + "_"
          + e.parameter.replace(/[^a-zA-Z0-9_]+/g, "_"));
    } else if (e instanceof Evernote.EDAMResponseException
        && typeof e.errorCode == 'number'
        && this.getLocalizedMessage("EDAMResponseError_" + e.errorCode)) {
      LOG.debug("Got localized message for Evernote.EDAMResponseException");
      if (typeof e.parameter == 'string') {
        msg = this.getLocalizedMessage("EDAMResponseError_" + e.errorCode,
            e.parameter);
      } else {
        msg = this.getLocalizedMessage("EDAMResponseError_" + e.errorCode);
      }
    } else if (e instanceof Evernote.EvernoteError
        && typeof e.errorCode == 'number'
        && this.getLocalizedMessage("EDAMError_" + e.errorCode)) {
      LOG.debug("Got localized message for Evernote.EvernoteError");
      if (typeof e.parameter == 'string') {
        msg = this.getLocalizedMessage("EDAMError_" + e.errorCode, e.parameter);
      } else {
        msg = this.getLocalizedMessage("EDAMError_" + e.errorCode);
      }
    } else if (e instanceof Evernote.EvernoteError
        && typeof e.message == 'string') {
      LOG.debug("Resorting to message included in the error");
      msg = e.message;
    } else if ((e instanceof Error || e instanceof Error)
        && typeof e.message == 'string') {
      LOG.debug("Resorting to standard message");
      msg = e.message;
    } else if (typeof e == 'string') {
      LOG.debug("Error is a string, so using that...");
      msg = e;
    }
    return msg;
  };

  Evernote.ViewManager.prototype.showError = function(error) {
    LOG.debug("Evernote.ViewManager.showError");
    if (this.quiet)
      return;
    var msg = this.extractErrorMessage(error, this
        .getLocalizedMessage("UnknownError"));
    if (msg != null) {
      this.globalErrorMessage.message = msg;
      this.globalErrorMessage.show();
    }
  };
  Evernote.ViewManager.prototype.showErrors = function(errors) {
    LOG.debug("Evernote.ViewManager.showErrors");
    if (this.quiet)
      return;
    var errs = (errors instanceof Array) ? errors : [ errors ];
    if (errs.length == 1) {
      this.showError(errs[0]);
      return;
    }
    var errorTitle = this.getLocalizedMessage("multipleErrorsTitle");
    var messageList = $("<ul></ul>");
    for ( var i = 0; i < errs.length; i++) {
      var msg = this.extractErrorMessage(errors[i]);
      if (msg != null)
        messageList.append("<li>" + msg + "</li>");
    }
    if (messageList.children().length > 0) {
      var errorBlock = $("<div class='multiErrorTitle'></div>");
      errorBlock.append(errorTitle);
      errorBlock.append(messageList);
      this.globalErrorMessage.message = errorBlock;
      this.globalErrorMessage.show();
    }
  };
  Evernote.ViewManager.prototype.hideError = function() {
    this.globalErrorMessage.hide();
  };
  Evernote.ViewManager.prototype.hideErrors = function() {
    this.globalErrorMessage.hide();
  };
  Evernote.ViewManager.prototype.showHttpError = function(xhr, textStatus,
      error) {
    LOG.debug("Evernote.ViewManager.showHttpError");
    if (this.quiet)
      return;
    var msg = this.getLocalizedMessage("Error_HTTP_Transport", [
        ("" + xhr.status), ((typeof error == 'string') ? error : "") ]);
    this.showError(new Error(msg));
  };
  Evernote.ViewManager.prototype.getLocalizedMessage = function(messageKey,
      params) {
    if (typeof chrome != 'undefined'
        && typeof chrome.i18n.getMessage == 'function') {
      return chrome.i18n.getMessage(messageKey, params);
    } else {
      return messageKey;
    }
  };
  Evernote.ViewManager.prototype.showFormErrors = function(form, errors,
      callback) {
    LOG.debug("Evernote.ViewManager.showFormErrors(" + (typeof form) + ", "
        + (typeof errors) + ")");
    if (this.quiet)
      return;
    var f = (form instanceof jQuery) ? form : $(form);
    for ( var i = 0; i < errors.length; i++) {
      var e = errors[i];
      var msg = this.extractErrorMessage(e);
      LOG.debug(e.toString() + " => " + msg);
      if (typeof callback == 'function') {
        callback(((typeof e.parameter == 'string') ? e.parameter : null), msg);
      } else {
        var field = null;
        if (typeof e.parameter == 'string' && msg != null) {
          field = f.find("[name=" + e.parameter + "]");
          if (field.length == 0) {
            field = null;
          }
        }
        if (field) {
          this.showFormFieldErrors(field, msg);
        } else {
          this.showError(msg);
        }
      }
    }
  };
  Evernote.ViewManager.prototype.showFormFieldErrors = function(field,
      errorMessage) {
    LOG.debug("Evernote.ViewManager.showFormFieldError(" + field + ", "
        + errorMessage + ")");
    if (this.quiet)
      return;
    if (typeof field == 'undefined')
      return;
    if (!(field instanceof jQuery))
      field = $(field);
    if (!field.hasClass(this.constructor.FORM_FIELD_ERROR_CLASS))
      field.addClass(this.constructor.FORM_FIELD_ERROR_CLASS);
    if (field.next("." + this.constructor.FORM_FIELD_ERROR_MESSAGE_CLASS).length == 0) {
      field.after($("<" + this.constructor.FORM_FIELD_ERROR_MESSAGE_ELEMENT
          + " class='" + this.constructor.FORM_FIELD_ERROR_MESSAGE_CLASS + "'>"
          + errorMessage + "</"
          + this.constructor.FORM_FIELD_ERROR_MESSAGE_ELEMENT + ">"));
    } else {
      field.next("." + this.constructor.FORM_FIELD_ERROR_MESSAGE_CLASS).html(
          errorMessage);
    }
  };
  Evernote.ViewManager.prototype.clearFormArtifacts = function(form) {
    LOG.debug("Evernote.ViewManager.clearFormArtifacts");
    if (typeof form == 'undefined')
      return;
    if (!(form instanceof jQuery))
      form = $(form);
    LOG.debug("Removing error messages...");
    form.find("." + this.constructor.FORM_FIELD_ERROR_MESSAGE_CLASS).remove();
    LOG.debug("Removing error classes from fields");
    form.find("." + this.constructor.FORM_FIELD_ERROR_CLASS).removeClass(
        this.constructor.FORM_FIELD_ERROR_CLASS);
    LOG.debug("Done...");
  };

  /**
   * SimpleMessage
   * 
   * @param containerSelector
   */
  Evernote.ViewManager.SimpleMessage = function(containerSelector) {
    this.initialize(containerSelector);
  };
  Evernote.ViewManager.SimpleMessage.MESSAGE_CLASS = "simpleMessage";
  Evernote.ViewManager.SimpleMessage.prototype._container = null;
  Evernote.ViewManager.SimpleMessage.prototype._message = null;
  Evernote.ViewManager.SimpleMessage.prototype.initialize = function(
      containerSelector) {
    this.__defineGetter__("container", this.getContainer);
    this.__defineGetter__("message", this.getMessage);
    this.__defineSetter__("message", this.setMessage);
    if (typeof containerSelector != 'undefined' && containerSelector) {
      this._container = (containerSelector instanceof jQuery) ? containerSelector
          : $(containerSelector);
    }
  };
  Evernote.ViewManager.SimpleMessage.prototype.getContainer = function() {
    return this._container;
  };
  Evernote.ViewManager.SimpleMessage.prototype.setMessage = function(message) {
    this._message = message;
  };
  Evernote.ViewManager.SimpleMessage.prototype.getMessage = function() {
    return this._message;
  };
  Evernote.ViewManager.SimpleMessage.prototype.show = function() {
    if (this.message) {
      var msgBlock = this.createMessageBlock();
      msgBlock.append(this.message);
      this._container.empty();
      this._container.append(msgBlock);
    } else {
      this._container.empty();
    }
    this._container.show();
  };
  Evernote.ViewManager.SimpleMessage.prototype.hide = function() {
    this._container.hide();
  };
  Evernote.ViewManager.SimpleMessage.prototype.createMessageBlock = function() {
    return $("<div class='" + this.getMessageClass() + "'></div>");
  };
  Evernote.ViewManager.SimpleMessage.prototype.getMessageClass = function() {
    return Evernote.ViewManager.SimpleMessage.MESSAGE_CLASS;
  };

  /**
   * StackableMessage
   * 
   * @param containerSelector
   */
  Evernote.ViewManager.StackableMessage = function(containerSelector) {
    this.initialize(containerSelector);
  };
  Evernote.inherit(Evernote.ViewManager.StackableMessage,
      Evernote.ViewManager.SimpleMessage);
  Evernote.ViewManager.StackableMessage.MESSAGE_CLASS = "stackableMessage";
  Evernote.ViewManager.StackableMessage.prototype._messageStack = new Array();
  Evernote.ViewManager.StackableMessage.prototype.initialize = function(
      containerSelector) {
    Evernote.ViewManager.StackableMessage.parent.initialize.apply(this, arguments);
  };
  Evernote.ViewManager.StackableMessage.prototype.getMessage = function() {
    if (this._messageStack.length > 0)
      return this._messageStack[(this._messageStack.length - 1)];
    else
      return null;
  };
  Evernote.ViewManager.StackableMessage.prototype.setMessage = function(message) {
    this._messageStack = new Array();
    this.addMessage(message);
  };
  Evernote.ViewManager.StackableMessage.prototype.addMessage = function(msg) {
    this._messageStack.push(this._describeMessage(msg));
  };
  Evernote.ViewManager.StackableMessage.prototype.removeMessage = function(msg) {
    var msgDescription = this._describeMessage(msg);
    for ( var i = this._messageStack.length - 1; i >= 0; i--) {
      if (this._messageStack[i] == msgDescription) {
        this._messageStack.splice(i, 1);
        break;
      }
    }
  };
  Evernote.ViewManager.StackableMessage.prototype.removeAllMessages = function() {
    this._messageStack = new Array();
  };
  Evernote.ViewManager.StackableMessage.prototype.length = function() {
    return this._messageStack.length;
  };
  Evernote.ViewManager.StackableMessage.prototype._describeMessage = function(
      msg) {
    var str = "";
    if (typeof msg == 'string') {
      str = msg;
    } else if (msg instanceof jQuery) {
      msg.each(function(i, e) {
        str += this._describeMessage(e);
      });
    } else if (msg instanceof Text) {
      str += msg;
    } else if (msg instanceof HTMLElement) {
      str += msg.innerHTML;
    }
    return str;
  };
  Evernote.ViewManager.StackableMessage.prototype.getMessageClass = function() {
    return Evernote.ViewManager.StackableMessage.parent.getMessageClass.apply(this) + " "
        + Evernote.ViewManager.StackableMessage.MESSAGE_CLASS;
  };
})();

(function() {
  var LOG = null;
  Evernote.ChromeOptions = function ChromeOptions() {
    LOG = Evernote.chromeExtension.logger;
    this.init();
  };
  Evernote.ChromeOptions.SUBMIT_MESSAGE_TIMEOUT = 1000;
  Evernote.ChromeOptions.prototype.optionsForm = null;
  Evernote.ChromeOptions.prototype.options = null;
  Evernote.ChromeOptions.prototype.optionsValidator = null;
  Evernote.ChromeOptions.prototype.pageOptions = {};
  Evernote.ChromeOptions.prototype.init = function() {
    this.initPageOptions();
    this.initOptions();
    this.initViews();
    this.initForms();
    this.initKonami();
  };
  Evernote.ChromeOptions.prototype.initPageOptions = function() {
    var hash = document.location.search;
    function getHashValue(val) {
      if (typeof val == 'undefined' || val == null) {
        return null;
      } else if (val == "0") {
        return 0;
      } else if (parseInt(val) > 0) {
        return parseInt(val);
      } else if (val.toLowerCase() == "true") {
        return true;
      } else if (val.toLowerCase() == "false") {
        return false;
      } else {
        return val;
      }
    }
    if (typeof hash == 'string' && hash.length > 0) {
      hash = hash.substring(1);
      var parts = hash.split("&");
      for ( var i = 0; i < parts.length; i++) {
        var kv = parts[i].split("=", 2);
        this.pageOptions[kv[0]] = getHashValue(kv[1]);
      }
    }
  };
  Evernote.ChromeOptions.prototype.initOptions = function() {
    LOG.debug("Evernote.Options.initOptions");
    try {
      if (Evernote.context.store
          && Evernote.context.options instanceof Evernote.Options) {
        this.options = Evernote.context.options;
        LOG.level = options.debugLevel;
      }
    } catch (e) {
      LOG.warn("Could not retrieve options");
    }
  };

  Evernote.ChromeOptions.prototype.initForms = function() {
    LOG.debug("Evernote.Options.initForms");
    $.validator.addMethod("serviceProto",
        Evernote.EvernoteContext.isValidServiceProto, chrome.i18n
            .getMessage("invalidExpression"));
    $.validator.addMethod("fullPage",
        Evernote.Options.isValidFullPageOptionValue, chrome.i18n
            .getMessage("invalidExpression"));
    $.validator.addMethod("noteList",
        Evernote.Options.isValidNoteListOptionValue, chrome.i18n
            .getMessage("invalidExpression"));
    $.validator.addMethod("autoSaveClipNote",
        Evernote.Options.isValidAutoSaveClipNoteOptionValue, chrome.i18n
            .getMessage("invalidExpression"));
    $.validator.addMethod("formatServiceProto", function(value, element) {
      $(element).val(
          Evernote.EvernoteContext.formatServiceProto(value).toLowerCase());
      return true;
    }, chrome.i18n.getMessage("invalidExpression"));
    var form = $("form[name=optionsForm]");
    var self = this;
    var opts = {
      submitHandler : function(form) {
        self.submitOptionsForm();
      },
      errorClass : Evernote.ViewManager.FORM_FIELD_ERROR_MESSAGE_CLASS,
      errorElement : "div",
      onkeyup : false,
      onfocusout : false,
      onsubmit : true,
      rules : {
        insecureProto : {
          required : true,
          formatServiceProto : true,
          serviceProto : true
        },
        secureProto : {
          required : true,
          formatServiceProto : true,
          serviceProto : true
        },
        serviceDomain : {
          required : true,
          minlength : Evernote.Constants.Limits.SERVICE_DOMAIN_LEN_MIN,
          maxlength : Evernote.Constants.Limits.SERVICE_DOMAIN_LEN_MAX
        },
        fullPage : {
          fullPage : true
        },
        noteList : {
          noteList : true
        },
        autoSaveClipNote : {
          autoSaveClipNote : true
        }
      },
      messages : {
        insecureProto : {
          serviceProto : chrome.i18n.getMessage("invalidServiceProto")
        },
        secureProto : {
          serviceProto : chrome.i18n.getMessage("invalidServiceProto")
        },
        serviceDomain : {
          minlength : chrome.i18n.getMessage("valueTooShort", [
              chrome.i18n.getMessage("options_serviceDomain"),
              Evernote.Constants.Limits.SERVICE_DOMAIN_LEN_MIN ]),
          maxlength : chrome.i18n.getMessage("valueTooLong", [
              chrome.i18n.getMessage("options_serviceDomain"),
              Evernote.Constants.Limits.SERVICE_DOMAIN_LEN_MAX ])
        },
        fullPage : {
          fullPage : chrome.i18n.getMessage("invalidFullPageOptionValue")
        },
        noteList : {
          noteList : chrome.i18n.getMessage("invalidNoteListOptionValue")
        },
        autoSaveClipNote : {
          autoSaveClipNote : chrome.i18n
              .getMessage("invalidAutoSaveClipNoteOptionValue")
        }
      }
    };
    LOG.debug("Setting up validation on login form");
    this.optionsValidator = form.validate(opts);
    LOG.debug("OPTIONSVALIDATOR: " + this.optionsValidator);
    this.form = form.observeform( {
      onSubmit : function() {
        LOG.debug(">>>>>>> "
            + (self.optionsValidator && self.optionsValidator
                .numberOfInvalids() == 0));
        return (self.optionsValidator && self.optionsValidator
            .numberOfInvalids() == 0);
      }
    });
    this.optionsForm = Evernote.ModelForm.onForm(form);
    this.populateOptionsForm();
  };

  Evernote.ChromeOptions.prototype.initKonami = function() {
    Evernote.Konami.start(function() {
      $("#developerContainer").toggle();
    }, window);
  };

  Evernote.ChromeOptions.prototype.initViews = function() {
    LOG.debug("Evernote.Options.initViews");
    if (this.isDeveloperMode()) {
      $("#developerContainer").show();
    } else {
      $("#developerContainer").hide();
    }
    if (Evernote.context.isInSync()
        && Evernote.context.notebooks instanceof Array
        && Evernote.context.notebooks.length > 0) {
      var notebooks = Evernote.context.notebooks.sort(function(a, b) {
        return a.name.toLowerCase() > b.name.toLowerCase();
      });
      var notebookGuids = $("#clipNotebookGuid");
      for ( var i = 0; i < notebooks.length; i++) {
        var n = notebooks[i];
        var nName = $("<div/>").text(n.name).html();
        notebookGuids.append($("<option value='" + n.guid + "'>" + nName
            + "</option>"));
      }
      $("#clipNotebookSelect").show();
    } else {
      $("#clipNotebookSelect").hide();
    }
  };
  Evernote.ChromeOptions.prototype.isDeveloperMode = function() {
    if (typeof this.pageOptions['developerMode'] != 'undefined') {
      return (this.pageOptions['developerMode']) ? true : false;
    } else if (this.options) {
      return this.options.developerMode;
    }
    return false;
  };
  Evernote.ChromeOptions.prototype.populateOptionsForm = function() {
    if (this.options) {
      this.optionsForm.populateWith(this.options);
      if (this.options.noteSortOrder) {
        this.optionsForm.noteSortOrder = JSON
            .stringify(this.options.noteSortOrder);
      }
      var preferredNotebook = Evernote.context.getPreferredNotebook();
      if (preferredNotebook) {
        this.optionsForm.clipNotebookGuid = preferredNotebook.guid;
      }
    }
  };
  Evernote.ChromeOptions.prototype.updateOptions = function() {
    LOG.debug("Evernote.Options.updateOptions");
    try {
      if (this.optionsForm) {
        var o = this.optionsForm.toStorable();
        o.noteSortOrder = new Evernote.NoteSortOrder(JSON
            .parse(o.noteSortOrder));
        LOG.debug(">>> optionsForm: " + JSON.stringify(o));
        this.options = new Evernote.Options(Evernote.context, o);
        LOG.debug(">>> new options: " + JSON.stringify(this.options));
        this.options.apply();
        Evernote.context.options = this.options;
        if (this.options.autoSaveClipNote == Evernote.Options.AUTO_SAVE_CLIPNOTE_OPTIONS.NEVER) {
          Evernote.context.setAutoSavedNote(null);
        }
        this.populateOptionsForm();
        new Evernote.RequestMessage(
            Evernote.Constants.RequestType.OPTIONS_UPDATED).send();
        return true;
      } else {
        LOG.error("Cannot find options form");
      }
    } catch (e) {
      LOG.error("Could not save options: " + e.message);
    }
    return false;
  };
  Evernote.ChromeOptions.prototype.resetOptions = function() {
    LOG.debug("Evernote.Options.resetOptions");
    this.options.reset();
    LOG.debug(">>> Clean options: " + JSON.stringify(this.options));
    this.populateOptionsForm();
    return this.updateOptions();
  };
  Evernote.ChromeOptions.prototype.showSubmitMessage = function(msg) {
    var msgBlock = $("#submitMessage");
    msgBlock.html(msg);
    msgBlock.removeClass();
    msgBlock.addClass("success");
    msgBlock.show();
    this.hideSubmitMessage();
  };
  Evernote.ChromeOptions.prototype.showSubmitError = function(msg) {
    var msgBlock = $("#submitMessage");
    msgBlock.html(msg);
    msgBlock.removeClass();
    msgBlock.addClass("error");
    msgBlock.show();
    this.hideSubmitMessage();
  };
  Evernote.ChromeOptions.prototype.hideSubmitMessage = function() {
    setTimeout(function() {
      $("#submitMessage").fadeOut(300);
    }, Evernote.ChromeOptions.SUBMIT_MESSAGE_TIMEOUT);
  };
  Evernote.ChromeOptions.prototype.submitOptionsForm = function() {
    if (this.optionsValidator.numberOfInvalids() > 0) {
      LOG.debug("Not submitting options form cuz it has errors");
      return false;
    }
    LOG.info("Submitting options form");
    if (this.updateOptions()) {
      this.showSubmitMessage(chrome.i18n.getMessage("options_formSaved"));
    } else {
      this.showSubmitError(chrome.i18n.getMessage("options_failedToSave"));
    }
    Evernote.Utils.updateBadge(Evernote.context);
    chrome.tabs.getSelected(null, function(tab) {
      Evernote.Utils.updateBadge(Evernote.context, tab.id);
    });
    // preventing actual form submit
    return false;
  };
  Evernote.ChromeOptions.prototype.resetOptionsForm = function() {
    LOG.debug("Resetting options form");
    if (this.resetOptions()) {
      this.showSubmitMessage(chrome.i18n.getMessage("options_formReset"));
    } else {
      this.showSubmitError(chrome.i18n.getMessage("options_failedToSave"));
    }
    // preventing actual form submit
    return false;
  };
  Evernote.ChromeOptions.prototype.logout = function() {
    LOG.debug("Options.logout");
    LOG.info("Logging out...");
    var self = this;
    var localLogout = function() {
      Evernote.ViewManager.clearWait();
      new Evernote.RequestMessage().send(Evernote.Constants.RequestType.LOGOUT,
          {
            resetOptions : false
          });
    };
    var logoutProc = Evernote.context.getRemote().logout(
        function(response, textStatus) {
          if (response.isResult()) {
            LOG.info("Successfully logged out");
          } else if (result.isError()) {
            LOG.warn("Soft error logging out");
          } else {
            LOG.error("Got garbage response when tried to logout");
          }
          localLogout();
        },
        function(xhr, textStatus, error) {
          if (xhr && xhr.readyState == 4) {
            LOG.error("Failed to log out due to transport errors (status: "
                + xhr.status + ")");
          } else if (xhr) {
            LOG.error("Failed to log out due to transport errors (readyState: "
                + xhr.readyState + ")");
          } else {
            LOG.error("Failed to log out due to unknown transport error");
          }
          localLogout();
        }, true);
  };
})();

/**
 * ChromePopup - used as the main UI element for the extension. All user
 * operations are done thru it.
 */
(function() {
  var LOG = null;
  Evernote.ChromePopup = function ChromePopup() {
    LOG = Evernote.chromeExtension.logger;
    this.init();
  };

  /** ************** Constants *************** */
  Evernote.ChromePopup.DEFAULT_TIMEOUT = 300;
  Evernote.ChromePopup.AUTO_SAVE_DELAY = 600;
  Evernote.ChromePopup.VIEW_TRANSITION_TIME = 100;
  Evernote.ChromePopup.NOTELIST_PAYLOAD_SIZE = 20;
  Evernote.ChromePopup.NOTELIST_PAGE_SIZE = 6;
  Evernote.ChromePopup.NOTELIST_ITEM_HEIGHT = 102;
  Evernote.ChromePopup.NOTELIST_FETCH_TIMEOUT = 400;
  Evernote.ChromePopup.NOTELIST_SCROLLTO_DELAY = 200;
  Evernote.ChromePopup.CLIP_PAGE_CONTENT_TIMEOUT = 10000;
  Evernote.ChromePopup.LOADING_THUMB_IMG_URL = "/images/spinner.gif";
  // Evernote.ChromePopup.SIMPLE_DATE_FORMAT = "M/d/yy HH:mm a";
  Evernote.ChromePopup.SIMPLE_DATE_FORMAT = "M/d/yy";
  Evernote.ChromePopup.THUMBNAIL_SIZE = 100;
  Evernote.ChromePopup.THUMBNAIL_MIN_SIZE = 50;
  Evernote.ChromePopup.SNIPPET_MAX_LENGTH = 150;
  /**
   * Indicates whether to allow multiple selection of auto-complete things when
   * typing query for note search
   */
  Evernote.ChromePopup.NOTELIST_AC_MULTIPLE = false;
  Evernote.ChromePopup.QUICK_NOTE_VIEW_DEFAULTS = {
    clipNote : null,
    autoSaved : false,
    saveUrl : false,
    fullPage : false,
    saveUrlEnabled : true,
    fullPageEnabled : true,
    notebookGuid : null
  };
  Evernote.ChromePopup.POPUP_STATUS_CODES = {
    STARTUP : 0,
    STARTED : 1
  };
  Evernote.ChromePopup.SOURCE_URL_MAX_DISPLAY_LENGTH = 32;

  /** ************** Instance Variables *************** */
  Evernote.ChromePopup.prototype.viewManager = null;
  Evernote.ChromePopup.prototype.aborted = false;
  Evernote.ChromePopup.prototype.currentTab = null;
  Evernote.ChromePopup.prototype.options = null;
  Evernote.ChromePopup.prototype.loginValidator = null;
  Evernote.ChromePopup.prototype.quickNoteValidator = null;
  Evernote.ChromePopup.prototype.fileNoteValidator = null;
  Evernote.ChromePopup.prototype.quickNoteForm = null;
  Evernote.ChromePopup.prototype.fileNoteForm = null;
  Evernote.ChromePopup.prototype.notesSearchForm = null;
  Evernote.ChromePopup.prototype.loginProc = null;
  Evernote.ChromePopup.prototype.findProc = null;
  Evernote.ChromePopup.prototype.findContextProc = null;
  Evernote.ChromePopup.prototype.noteList = null;
  Evernote.ChromePopup.prototype.searchQueryPopulated = false;
  Evernote.ChromePopup.prototype.fileNoteChanged = false;
  Evernote.ChromePopup.prototype.noteListScrollTimer = null;
  Evernote.ChromePopup.prototype.quickNoteSubmitWait = null;
  Evernote.ChromePopup.prototype.searchDrawer = null;
  Evernote.ChromePopup.prototype.contextDrawer = null;
  Evernote.ChromePopup.prototype.drawersInitialized = false;
  Evernote.ChromePopup.prototype.noteContextFilter = null;
  Evernote.ChromePopup.prototype.searchHelper = null;
  Evernote.ChromePopup.prototype._eventHandler = null;
  Evernote.ChromePopup.prototype._clipperContentScripting = null;
  Evernote.ChromePopup.prototype.popupStatus = Evernote.ChromePopup.POPUP_STATUS_CODES.STARTUP;

  /** ************** Initialization *************** */
  Evernote.ChromePopup.prototype.init = function() {
    LOG.debug("Initializing...");
    this.initOptions();
    this.initEventHandler();
    this.initListeners();
    this.initViewManager();
    this.localizePopup();
    this.initSearchHelper();
    this.initViews();
    this.initForms();
    this.__defineGetter__("clipperContentScripting",
        this.getClipperContentScripting);
    LOG.debug("Clipper initialized...");
  };
  Evernote.ChromePopup.prototype.initOptions = function() {
    LOG.debug("Popup.initOptions");
    this.options = Evernote.context.options;
    if (this.options instanceof Evernote.Options) {
      LOG.level = this.options.debugLevel;
    }
  };
  Evernote.ChromePopup.prototype.initSearchHelper = function() {
    var bg = chrome.extension.getBackgroundPage();
    var self = this;
    bg.chrome.tabs.getSelected(null, function(tab) {
      self.searchHelper = bg.Evernote.SearchHelper.getInstance(tab.id);
    });
  };
  Evernote.ChromePopup.prototype.initEventHandler = function() {
    this._eventHandler = new Evernote.EventHandler(this);
    this._eventHandler.defaultHandler = function() {
      LOG.info("Popup ignores request: " + requestType);
    };
    this._eventHandler.add(
        Evernote.Constants.RequestType.POPUP_PAGE_CLIP_SUCCESS,
        this.handlePageClipSuccess);
    this._eventHandler.add(
        Evernote.Constants.RequestType.POPUP_PAGE_CLIP_CONTENT_SUCCESS,
        this.handlePageClipContentSuccess);
    this._eventHandler.add(
        Evernote.Constants.RequestType.POPUP_PAGE_CLIP_CONTENT_TOO_BIG,
        this.handlePageClipContentTooBig);
    this._eventHandler.add(
        Evernote.Constants.RequestType.POPUP_PAGE_CLIP_CONTENT_FAILURE,
        this.handlePageClipContentFailure);
    this._eventHandler.add(
        Evernote.Constants.RequestType.POPUP_PAGE_CLIP_FAILURE,
        this.handlePageClipFailure);
    this._eventHandler.add(
        Evernote.Constants.RequestType.CONTENT_SCRIPT_LOAD_TIMEOUT,
        this.handleCancelPageClipTimer);
  };
  Evernote.ChromePopup.prototype.initListeners = function() {
    LOG.debug("Popup.initListeners");
    var self = this;
    // make sure we instantly save changes to state
    $(window).bind(Evernote.AppState.CHANGE_EVENT_NAME,
        function(event, newState) {
          if (newState instanceof Evernote.AppState) {
            Evernote.context.setState(newState);
          }
        });
    chrome.extension.onRequest.addListener(function(request, sender,
        sendResponse) {
      self.handleRequest(request, sender, sendResponse);
    });
  };
  Evernote.ChromePopup.prototype.initViewManager = function() {
    LOG.debug("Popup.initViewManager");
    this.viewManager = Evernote.ViewManager.getInstance();
    this.viewManager.globalErrorMessage = new Evernote.ViewManager.SimpleMessage(
        $("#globalErrorMessage"));
    this.viewManager.globalMessage = new Evernote.ViewManager.StackableMessage(
        $("#globalMessage"));
  };
  Evernote.ChromePopup.prototype.initViews = function() {
    LOG.debug("Popup.initViews");
    this.bindViews();
  };
  Evernote.ChromePopup.prototype.initForms = function() {
    LOG.debug("Popup.initForms");
    this.quickNoteForm = Evernote.ClipNoteForm
        .onForm($("form[name=quickNoteForm]"));
    this.fileNoteForm = Evernote.NoteForm.onForm($("form[name=fileForm]"));
    this.notesSearchForm = Evernote.ModelForm
        .onForm($("form[name=notesSearchForm]"));
    this.bindForms();
  };
  Evernote.ChromePopup.prototype.initDrawers = function() {
    LOG.debug("Popup.initDrawers");
    if (!this.drawersInitialized) {
      // this.init search drawer
      this.searchDrawer = $("#searchDrawer").tabDrawer( {
        tabIndex : 0,
        groupElement : $("#drawers"),
        edge : $.tabDrawer.BOTTOM_EDGE,
        align : $.tabDrawer.RIGHT_ALIGN,
        visible : true,
        focused : true,
        handleElement : $("#notesSearchHandle"),
        handleTitleElement : $("#notesSearchTitle"),
        drawerElement : $("#notesSearchView"),
        drawerContentElement : $("#notesSearchContainer"),
        transitionTime : Evernote.ChromePopup.VIEW_TRANSITION_TIME
      });
      // this.init context drawer
      this.contextDrawer = $("#contextDrawer").tabDrawer( {
        tabIndex : 1,
        groupElement : $("#drawers"),
        edge : $.tabDrawer.BOTTOM_EDGE,
        align : $.tabDrawer.RIGHT_ALIGN,
        visible : false,
        handleElement : $("#notesContextHandle"),
        handleTitleElement : $("#notesContextTitle"),
        drawerElement : $("#notesContextView"),
        drawerContentElement : $("#notesContextContainer"),
        transitionTime : Evernote.ChromePopup.VIEW_TRANSITION_TIME
      });
      this.bindDrawers();
      this.drawersInitialized = true;
    }
  };

  Evernote.ChromePopup.prototype.getClipperContentScripting = function() {
    var self = this;
    if (!this._clipperContentScripting) {
      this._clipperContentScripting = new Evernote.ClipperContentScripting();
      this._clipperContentScripting.ontimeout = function() {
        LOG.warn("clipperContentScripting timed out...");
        self.handleCancelPageClipTimer();
      };
      this._clipperContentScripting.createInstance = function() {
        var code = "Evernote.ContentClipper.destroyInstance();";
        code += "(function(){";
        code += "var inst = Evernote.ContentClipper.getInstance();"
        code += "inst.PAGE_CLIP_SUCCESS = Evernote.Constants.RequestType.POPUP_PAGE_CLIP_SUCCESS;";
        code += "inst.PAGE_CLIP_CONTENT_TOO_BIG = Evernote.Constants.RequestType.POPUP_PAGE_CLIP_CONTENT_TOO_BIG;";
        code += "inst.PAGE_CLIP_CONTENT_SUCCESS = Evernote.Constants.RequestType.POPUP_PAGE_CLIP_CONTENT_SUCCESS;";
        code += "inst.PAGE_CLIP_CONTENT_FAILURE = Evernote.Constants.RequestType.POPUP_PAGE_CLIP_CONTENT_FAILURE;";
        code += "inst.PAGE_CLIP_FAILURE = Evernote.Constants.RequestType.POPUP_PAGE_CLIP_FAILURE;";
        code += "})();";
        return code;
      };
    }
    return this._clipperContentScripting;
  };

  /** ************** Listeners and Request Handlers *************** */
  Evernote.ChromePopup.prototype.handleRequest = function(request, sender,
      sendResponse) {
    LOG.debug("Popup.handleRequest");
    if (typeof request == 'object' && request != null) {
      var requestMessage = Evernote.RequestMessage.fromObject(request);
      if (!requestMessage.isEmpty()) {
        this._eventHandler.handleEvent(requestMessage.code, [ request, sender,
            sendResponse ]);
      }
    }
  };

  Evernote.ChromePopup.prototype.handlePageClipSuccess = function(request,
      sender, sendResponse) {
    this.viewManager.clearWait();
    LOG.info("Popup.handlePageClipSuccess");
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    var clipNote = new Evernote.ClipNote(requestMessage.message);
    LOG.debug("Popup received request from extension with clipNote: "
        + clipNote.toString());
    var options = Evernote.context.options;
    var self = this;
    if (clipNote.fullPage) {
      LOG.info("Prompting for filing info for full page clip");
      // clipNote.fullPage = false;
      var viewOpts = {
        clipNote : clipNote,
        autoSaved : false
      };
      if (this.options
          && this.options.fullPage == Evernote.Options.FULL_PAGE_OPTIONS.NEVER) {
        viewOpts.fullPage = false;
      } else if (this.options
          && this.options.fullPage == Evernote.Options.FULL_PAGE_OPTIONS.REMEMBER
          && typeof Evernote.context.state.fullPage == 'boolean') {
        viewOpts.fullPage = Evernote.context.state.fullPage;
      } else if (this.options
          && this.options.fullPage == Evernote.Options.FULL_PAGE_OPTIONS.ALWAYS) {
        viewOpts.fullPage = true;
      }
      this.viewManager.switchView("quickNoteView", viewOpts);
    } else {
      LOG.warn("Igoring request message (" + requestMessage.code
          + ") because it's not a full page clip");
    }
  };
  Evernote.ChromePopup.prototype.handlePageClipContentSuccess = function(
      request, sender, sendResponse) {
    LOG.debug("Popup.handlePageClipContentSuccess");
    var self = this;
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    var clipNote = new Evernote.ClipNote(requestMessage.message);
    LOG.debug("Clip length: " + clipNote.length);
    if (clipNote.fullPage && this.quickNoteForm) {
      LOG.debug("Setting retrieved content on quickNoteForm");
      this.quickNoteForm.content = clipNote.content;
      if (this.quickNoteSubmitWait == null
          && this.quickNoteForm.form.hasClass("changed")) {
        LOG.debug("Auto-saving since form was modified");
        this.autoSaveQuickNote();
      } else if (this.quickNoteSubmitWait != null) {
        clearTimeout(this.quickNoteSubmitWait);
        this.quickNoteSubmitWait = null;
        this.submitQuickNoteForm();
      }
    } else if (!clipNote.fullPage) {
      LOG.info("Submitting partial-page clip to the server");
      var preferredNotebook = Evernote.context.getPreferredNotebook();
      if (preferredNotebook instanceof Evernote.Notebook) {
        clipNote.notebookGuid = preferredNotebook.guid;
      }
      this
          .remoteClipNote(
              clipNote,
              function(response, textStatus) {
                var note = (typeof response.result["note"] != 'undefined' && response.result.note instanceof Evernote.Note) ? response.result.note
                    : null;
                if (note) {
                  LOG
                      .info("Received successful response from the server after clipping the note");
                  self.viewManager.switchView("fileView", {
                    "note" : note
                  });
                } else {
                  LOG
                      .warn("Cannot recognize a note in response after clipping the note: "
                          + note);
                  self.viewManager.showError(new Error(
                      Evernote.EDAMResponseErrorCode.INVALID_RESPONSE));
                  self.viewManager.switchView("quickNoteView", {
                    "clipNote" : clipNote
                  });
                }
              }, function(response, textStatus) {
                LOG.error("Failed to clip selection");
                if (response.errors.length > 1)
                  self.viewManager.showErrors(response.errors);
                else
                  self.viewManager.showError(response.errors[0]);
                // self.dismissPopup();
            });
    } else {
      LOG.warn("Igoring request message (" + requestMessage.code
          + ") because it doesn't represent a clip that we can deal with");
    }
  };
  Evernote.ChromePopup.prototype.handlePageClipContentTooBig = function(
      request, sender, sendResponse) {
    LOG.debug("Popup.handlePageClipContentTooBig");
    var viewManager = Evernote.ViewManager.getInstance();
    viewManager.clearWait();
    if (this.quickNoteForm.fullPage) {
      viewManager.showError(chrome.i18n.getMessage("fullPageClipTooBig"));
    }
    this.recoverFromPageClipContentFailure();
  };
  Evernote.ChromePopup.prototype.handlePageClipContentFailure = function(
      request, sender, sendResponse) {
    LOG.debug("Popup.handlePageClipContentFailure");
    var viewManager = Evernote.ViewManager.getInstance();
    viewManager.clearWait();
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    viewManager.showError((requestMessage.message) ? requestMessage.message
        : chrome.i18n.getMessage("fullPageClipFailure"));
    this.recoverFromPageClipContentFailure();
  };
  Evernote.ChromePopup.prototype.recoverFromPageClipContentFailure = function() {
    if (this.quickNoteForm) {
      this.quickNoteForm.fullPage = false;
      this.quickNoteForm.disableFullPage();
    }
    // clear submit timeout
    if (this.quickNoteSubmitWait != null) {
      clearTimeout(this.quickNoteSubmitWait);
      this.quickNoteSubmitWait = null;
    }
  };
  Evernote.ChromePopup.prototype.handlePageClipFailure = function(request,
      sender, sendResponse) {
    LOG.info("Popup received request with failed page clip");
    var requestMessage = Evernote.RequestMessage.fromObject(request);
    var viewManager = Evernote.ViewManager.getInstance();
    viewManager.clearWait();
    if (requestMessage.message) {
      viewManager.showError(requestMessage.message);
    }
    // check if we can at least capture the URL of the current tab,
    // and if so, fake a Evernote.ClipNote
    var currentTab = null;
    var self = this;
    chrome.tabs.getSelected(null, function(t) {
      if (self.currentTab == null) {
        self.currentTab = t;
      } else {
        return;
      }
      if (!self.currentTab.url || self.currentTab.url.indexOf("http") != 0) {
        if (!self.currentTab.url) {
          LOG.info("Tried to clip page without a URL");
        } else {
          LOG.info("Tried to clip page with invalid or unsupported URL: "
              + self.currentTab.url);
        }
        viewManager.showError(new Evernote.EvernoteError( {
          errorCode : Evernote.EDAMErrorCode.BAD_DATA_FORMAT,
          parameter : 'url'
        }));
      } else {
        LOG.info("Salvaging unclippable page");
        var clipNote = new Evernote.ClipNote( {
          url : self.currentTab.url,
          fullPage : false
        });
        if (self.currentTab.title)
          clipNote.title = self.currentTab.title;
        if (LOG.isDebugEnabled())
          LOG.debug("Faking Evernote.ClipNote: " + JSON.stringify(clipNote));
        viewManager.switchView("quickNoteView", {
          "clipNote" : clipNote
        });
        if (self.quickNoteForm) {
          self.quickNoteForm.disableFullPage();
        }
      }
    });
  };
  Evernote.ChromePopup.prototype.handleCancelPageClipTimer = function(request,
      sender, sendResponse) {
    LOG.debug("Popup.handleCancelPageClipTimer");
    var self = this;
    self.viewManager.clearWait();
    self.viewManager.showError(chrome.i18n.getMessage("contentScriptTimedOut"));
    chrome.windows.getCurrent(function(win) {
      chrome.tabs.getSelected(win.id, function(tab) {
        self.startUpWithQuickNote(tab);
      });
    });
  };

  Evernote.ChromePopup.prototype.getSelection = function(fullPageOnly, tabId) {
    LOG.debug("Popup.getSelection");
    if (typeof tabId != 'number')
      tabId = null;
    /*
     * Evernote.ViewManager.getInstance().wait(
     * chrome.i18n.getMessage("clippingPageContent"));
     */
    var _clipFullPageOnly = (fullPageOnly) ? true : false;
    var self = this;
    var fn = function(tabId) {
      self.clipperContentScripting.perform(tabId, _clipFullPageOnly,
          Evernote.context.getPreferredStylingStrategyQualifier(), false,
          function() {
            LOG.debug("Popup's request for page clip completed");
          });
    };
    if (!tabId) {
      chrome.windows.getCurrent(function(win) {
        chrome.tabs.getSelected(win.id, function(tab) {
          if (Evernote.Utils.isForbiddenUrl(tab.url)) {
            self.viewManager.clearWait();
            if (self.quickNoteForm.fullPage) {
              self.viewManager.showError(chrome.i18n
                  .getMessage("illegalUrlClipFailure"));
            }
            self.startUpWithQuickNote(tab);
          } else {
            fn(tab.id);
          }
        });
      });
    } else {
      chrome.tabs.get(tabId, function(tab) {
        if (Evernote.Utils.isForbiddenUrl(tab.url)) {
          self.viewManager.clearWait();
          if (self.quickNoteForm.fullPage) {
            self.viewManager.showError(chrome.i18n
                .getMessage("illegalUrlClipFailure"));
          }
          self.startUpWithQuickNote(tab);
        } else {
          fn(tabId);
        }
      });
    }
    LOG.debug("Waiting for page clip...");
  };
  Evernote.ChromePopup.prototype.dismissPopup = function(instant) {
    var self = this;
    if (typeof instant != 'undefined' && instant) {
      this.abort();
      window.close();
    } else {
      setTimeout(function() {
        self.abort();
        window.close();
      }, Evernote.ChromePopup.DEFAULT_TIMEOUT);
    }
  };
  Evernote.ChromePopup.prototype.goRegister = function() {
    chrome.tabs.create( {
      url : Evernote.context.getRegistrationUrl()
    });
    this.dismissPopup();
  };
  Evernote.ChromePopup.prototype.goHome = function() {
    if (this.quickNoteForm
        && (this.quickNoteForm.content.length > 0 || this.quickNoteForm.tagNames.length > 0)) {
      this.autoSaveQuickNote();
    }
    chrome.tabs.create( {
      url : Evernote.context.getHomeUrl()
    });
    this.dismissPopup();
  };
  Evernote.ChromePopup.prototype.openNoteWindow = function(noteUrl) {
    var self = this;
    chrome.tabs.getSelected(null, function(tab) {
      var opts = {
        url : noteUrl,
        width : 800,
        height : 550
      };
      if (tab) {
        opts.incognito = tab.incognito;
      }
      if (typeof opts["incognito"] != 'undefined' && opts.incognito) {
        Evernote.context.getCookie("auth", function(cookie) {
          if (typeof cookie == 'object' && cookie != null
              && typeof cookie["value"] == 'string'
              && typeof noteUrl == 'string') {
            opts.url = Evernote.context.getSetAuthTokenUrl(cookie.value,
                noteUrl.replace(/http.?:\/\/[^\/]+/i, ""));
          }
          chrome.windows.create(opts);
        }, function() {
          chrome.windows.create(opts);
        });
      } else {
        chrome.windows.create(opts);
      }
    });
  };

  /** ************** Utilities *************** */
  Evernote.ChromePopup.prototype.localizePopup = function() {
    LOG.debug("Popup.localizePopup");
    var allViews = $("body");
    for ( var i = 0; i < allViews.length; i++) {
      var v = $(allViews.get(i));
      Evernote.Utils.localizeBlock(v);
    }
  };

  Evernote.ChromePopup.prototype.populateNotebookSelection = function(sel) {
    LOG.debug("Popup.populateNotebookSelection");
    var notebooks = Evernote.context.getNotebooks();
    if (sel instanceof jQuery && notebooks instanceof Array) {
      LOG.debug("Updating notebook selection with " + notebooks.length
          + " notebooks");
      sel.empty();
      var preferredNotebook = Evernote.context.getPreferredNotebook();
      for ( var i = 0; i < notebooks.length; i++) {
        var n = notebooks[i];
        var nName = $("<div/>").text(n.name).html();
        var opt = $("<option value='" + n.guid + "'>" + nName + "</option>");
        if (n == preferredNotebook) {
          opt.attr("selected", "selected");
        }
        sel.append(opt);
      }
      // sel.unbind("change");
      var self = this;
      sel.bind("change", function(event) {
        LOG.debug(">>> SAVING NOTEBOOKGUID STATE: " + sel.val());
        Evernote.context.state.notebookGuid = sel.val();
      });
    } else {
      LOG.debug("Nothing to update");
    }
  };

  Evernote.ChromePopup.prototype.populateTagSelection = function(sel) {
    LOG.debug("Popup.populateTagSelection");
    var tags = Evernote.context.getTags();
    var self = this;
    if (tags && tags.length > 0) {
      if (sel instanceof jQuery && tags instanceof Array) {
        LOG.debug("Populating tag selection");
        sel.autocomplete(tags, {
          formatItem : function(tag) {
            return $("<div/>").text(tag.name).html();
          },
          formatResult : function(tag) {
            return tag.name;
          },
          matchContains : true,
          multiple : true,
          selectFirst : false
        });
      }
    }
  };

  Evernote.ChromePopup.prototype.populateSearchQueries = function(sel) {
    LOG.debug("Popup.populateSearchQueries");
    if (sel instanceof jQuery) {
      var searches = new Array();
      if (Evernote.context.getTags() instanceof Array) {
        if (LOG.isDebugEnabled())
          LOG.debug("Adding " + Evernote.context.getTags().length
              + " tags to searches");
        searches = searches.concat(Evernote.context.getTags());
      }
      if (Evernote.context.getSearches() instanceof Array) {
        if (LOG.isDebugEnabled())
          LOG.debug("Adding " + Evernote.context.getSearches().length
              + " saved searches to searches");
        searches = searches.concat(Evernote.context.getSearches());
      }
      if (Evernote.context.getNotebooks() instanceof Array) {
        if (LOG.isDebugEnabled())
          LOG.debug("Adding " + Evernote.context.getNotebooks().length
              + " notebooks to searches");
        searches = searches.concat(Evernote.context.getNotebooks());
      }
      LOG.debug("There are now " + searches.length + " searches");
      var noteFilter = Evernote.context.noteFilter;
      sel.autocomplete(searches, {
        formatItem : function(item, row, total) {
          var iconSrc = null;
          if (item instanceof Evernote.Tag) {
            iconSrc = "images/browse_tags_icon.png";
          } else if (item instanceof Evernote.Notebook) {
            iconSrc = "images/browse_books_icon.png";
          } else if (item instanceof Evernote.SavedSearch) {
            iconSrc = "images/browse_search_icon.png";
          }
          if (iconSrc) {
            return $("<div/>").text(item.name).html() + "<img src='" + iconSrc
                + "' class='listIcons'/>";
          } else {
            return $("<div/>").text(item.name).html();
          }
        },
        formatResult : function(item, row, total) {
          if (item instanceof Evernote.SavedSearch
              && noteFilter instanceof Evernote.NoteFilter) {
            noteFilter.fuzzy = false;
          } else if (noteFilter instanceof Evernote.NoteFilter) {
            noteFilter.fuzzy = true;
          }
          if (item instanceof Evernote.Tag) {
            return "tag:" + Evernote.NoteFilter.formatWord(item.name);
          } else if (item instanceof Evernote.Notebook) {
            return "notebook:" + Evernote.NoteFilter.formatWord(item.name);
          } else if (item instanceof Evernote.SavedSearch) {
            return item.query;
          } else {
            return Evernote.NoteFilter.formatWord(item.name);
          }
        },
        selectFirst : (!Evernote.ChromePopup.NOTELIST_AC_MULTIPLE),
        multiple : Evernote.ChromePopup.NOTELIST_AC_MULTIPLE,
        multipleSeparator : Evernote.NoteFilter.WORD_SEPARATOR
      });
    }
  };

  Evernote.ChromePopup.prototype.createPlaceholderNoteListItem = function() {
    var noteItem = $("<div class='noteListItem noteListItemPlaceholder' style='width: 100%'></div>");
    var noteInfo = $("<div class='noteListItemInfo'></div>");
    noteItem.append(noteInfo);
    noteInfo.append($("<div><img src='/images/spinner.gif'/></div>"));
    return noteItem;
  };

  Evernote.ChromePopup.prototype.createNoteListItem = function(note,
      searchWords) {
    var id = "";
    var cssClass = "noteListItem";
    if (note.guid && note.guid.length > 0) {
      id = "id='noteListItem_" + note.guid + "'";
    } else {
      cssClass += " noteListItemPlaceholder";
    }
    var noteItem = $("<div " + id + " class='" + cssClass + "'></div>");
    noteItem.css( {
      width : "100%"
    });
    var thumbUrl = null;
    if (note instanceof Evernote.SnippetNote && note.resourcesSize == 1
        && note.resources[0].mime) {
      var res = note.resources[0];
      var mime = res.mime.toLowerCase();
      if (mime.indexOf("image") >= 0
          && (res.width >= this.constructor.THUMBNAIL_MIN_SIZE || res.height >= this.constructor.THUMBNAIL_MIN_SIZE)) {
        thumbUrl = res.getThumbnailUrl(Evernote.context.getShardedUrl(),
            this.constructor.THUMBNAIL_SIZE);
      } else if (mime.indexOf("pdf") >= 0) {
        thumbUrl = res.getThumbnailUrl(Evernote.context.getShardedUrl(),
            this.constructor.THUMBNAIL_SIZE);
      }
    } else if (note instanceof Evernote.Note) {
      thumbUrl = note.getThumbnailUrl(Evernote.context.getShardedUrl(),
          this.constructor.THUMBNAIL_SIZE);
    }
    if (thumbUrl) {
      noteItem.append($("<div class='noteListItemThumb'><img src='" + thumbUrl
          + "' class='noteThumb' style='max-width: "
          + this.constructor.THUMBNAIL_SIZE + "; max-height: "
          + this.constructor.THUMBNAIL_SIZE + ";'/></div>"));
    }
    // note info
    var noteInfo = $("<div class='noteListItemInfo'></div>");
    noteItem.append(noteInfo);
    // note title
    var noteTitle = (note.title) ? $("<div/>").text(note.title).html() : "";
    noteInfo
        .append($("<div class='noteListItemTitle'>" + noteTitle + "</div>"));
    var sortField = Evernote.context.options.noteSortOrder.type.toLowerCase();
    // note date
    var noteDate = null;
    if (typeof note[sortField] == 'number') {
      var f = new SimpleDateFormat(Evernote.ChromePopup.SIMPLE_DATE_FORMAT);
      noteDate = f.format(new Date(note[sortField]));
    }
    var itemContent = $("<div class='noteListItemContent'></div>");
    noteInfo.append(itemContent);
    if (noteDate) {
      itemContent.append($("<div class='noteListItemDate'>" + noteDate
          + "</div>"));
    }
    if (note.snippet) {
      itemContent.append($("<div class='noteListItemSnippet'>" + note.snippet
          + "</div>"));
    } else if (note.attachmentFileName) {
      itemContent.append($("<div class='noteItemAttachmentFileName'>"
          + note.attachmentFileName + "</div>"));
    }
    // note source url
    if (note.attributes && typeof note.attributes.sourceURL == 'string'
        && note.attributes.sourceURL.length > 0) {
      var urlStr = Evernote.Utils.shortUrl(note.attributes.sourceURL,
          Evernote.ChromePopup.SOURCE_URL_MAX_DISPLAY_LENGTH);
      var urlAnchor = $("<a href='#' title='" + note.attributes.sourceURL
          + "'>" + urlStr + "</a>");
      urlAnchor.click(function(event) {
        event.preventDefault();
        event.stopPropagation();
        chrome.tabs.getSelected(null, function(tab) {
          chrome.tabs.create( {
            index : (tab.index + 1),
            url : note.attributes.sourceURL
          });
        });
      });
      var urlWrapper = $("<div class='noteListItemUrl'></div>");
      urlWrapper.append(urlAnchor);
      noteInfo.append(urlWrapper);
    }
    var self = this;
    if (note.guid) {
      noteItem.bind("click", {
        note : note,
        searchWords : searchWords
      }, function(event) {
        self.openNoteWindow(event.data.note.getNoteUrl(Evernote.context
            .getShardedUrl(), Evernote.context.getShardId(),
            event.data.searchWords, Evernote.context.getLocale()));
      });
    }
    return noteItem;
  };

  Evernote.ChromePopup.prototype.bindViews = function() {
    LOG.debug("Popup.bindViews");
    this.bindHeader();
    this.bindLoginView();
    this.bindFileView();
    this.bindQuickNoteView();
    this.bindViewsWithDrawer();
  };

  Evernote.ChromePopup.prototype.bindHeader = function() {
    var self = this;
    $("#header").bind("show", function(event, data) {
      LOG.debug("#header.onShow");
      var user = Evernote.context.getUser();
      if (user) {
        $("#headerUsername").text(user.username);
        $("#headerUsername").unbind("click");
        $("#headerUsername").bind("click", function() {
          Evernote.Utils.openWindow(Evernote.context.getEvernoteProfileUrl());
        });
        $("#headerUser").show();
        $("#headerNoUser").hide();
      } else {
        $("#headerUser").hide();
        $("#headerNoUser").show();
      }
    });
  };

  Evernote.ChromePopup.prototype.bindLoginView = function() {
    // Bind loginView to focus on username field
    var self = this;
    $("#loginView")
        .bind("show", function(event, data) {
          LOG.debug("#loginView.onShow");
          self.viewManager.showBlock($("#header"));
          $("#headerUser").hide();
          $("#headerNoUser").show();
          self.updateBadge();
          var view = $("#loginView");
          var loginForm = view.find("form[name=loginForm]");
          // populate with data or present clean form if no data
            if (typeof data == 'object' && data != null) {
              if (typeof data["username"] != 'undefined') {
                loginForm.find("input[name=username]").val(data["username"]);
              }
              if (typeof data["password"] != 'undefined') {
                loginForm.find("input[name=password]").val(data["password"]);
              }
            } else {
              loginForm.find("input[type=password]").val("");
            }
            // use search-helper?
            $("#useSearchHelper").attr(
                "checked",
                (Evernote.context.getOptions(true).useSearchHelper) ? true
                    : false);
            // focus and select appropriate field
            loginForm.find("input[name=username]").focus();
            self.loginValidator.focusInvalid();
          });
    $("#loginView").bind("hide", function(event) {
      LOG.debug("#loginView.onHide");
      self.viewManager.hideBlock($("#header"));
    });
  };

  Evernote.ChromePopup.prototype.bindFileView = function() {
    // Bind fileView to populate forms
    var self = this;
    $("#fileView")
        .bind(
            "show",
            function(event, data) {
              LOG.debug("#fileView.onShow");
              self.viewManager.showBlock($("#header"));
              var view = $("#fileView");
              // populate notebook selection
              self.populateNotebookSelection(view
                  .find("select[name=notebookGuid]"));
              self.populateTagSelection(view.find("input[name=tagNames]"));
              // populate note fields
              if (typeof data == 'object' && typeof data["note"] != "undefined") {
                var note = (data["note"] instanceof Evernote.Note) ? data["note"]
                    : new Evernote.Note(data["note"]);
                if (note && self.fileNoteForm) {
                  if (LOG.isDebugEnabled())
                    LOG.debug("Populating fileView with Note data: "
                        + JSON.stringify(note));
                  self.fileNoteForm.populateWithNote(Evernote.context, note);
                } else {
                  LOG
                      .warn("Cannot populate fileView with Note. Either no Note or no NoteForm is present");
                }
              }
              // focus on first tab element
              $("#fileView *[tabindex=1]").focus();
            });
    $("#fileView").bind("hide", function(event) {
      LOG.debug("#fileView.onHide");
      self.viewManager.hideBlock($("#header"));
    });
  };

  Evernote.ChromePopup.prototype.bindQuickNoteView = function() {
    // Bind quickNoteView to populate forms.
    // The form will be populated first using data.clipNote, if it's present
    // and finally all of the view options will be applied.
    // Typically this view will be revealed via
    // Evernote.ViewManager.switchView("quickNoteView")
    // in which case, adding an extra argument to that call will pass that
    // argument as data to the event handler
    // For example, Evernote.ViewManager.switchView("quickNoteView", {clipNote:
    // clipNoteObj, autoSaved: true, fullPageEnabled: true});
    // will populate the form with data taken from clipNoteObj, then mark the
    // form
    // as autoSaved and disable fullPage option.
    var self = this;
    $("#quickNoteView")
        .bind(
            "show",
            function(event, data) {
              LOG.debug("#quickNoteView.onShow");
              self.viewManager.showBlock($("#header"));

              var view = $("#quickNoteView");
              // populate notebook selection
              self.populateNotebookSelection(view
                  .find("select[name=notebookGuid]"));
              self.populateTagSelection(view.find("input[name=tagNames]"));

              // setup view options (defaults < options)
              var viewOpts = $.extend(true, {},
                  Evernote.ChromePopup.QUICK_NOTE_VIEW_DEFAULTS);
              // default notebook
              if (Evernote.context.getPreferredNotebook()) {
                viewOpts.notebookGuid = Evernote.context.getPreferredNotebook().guid;
              }
              // make sure we honor fullPage option
              if (Evernote.context.options.fullPage == Evernote.Options.FULL_PAGE_OPTIONS.ALWAYS) {
                viewOpts.fullPage = true;
              } else if (Evernote.context.options.fullPage == Evernote.Options.FULL_PAGE_OPTIONS.REMEMBER) {
                viewOpts.fullPage = (Evernote.context.state.fullPage) ? true
                    : false;
              }
              // populate form with default view options
              self.quickNoteForm.populateWith(viewOpts);

              // populate form with clipNote and/or specific options passed via
              // data
              if (data && typeof data == 'object') {
                LOG.debug("Overriding quick note form with passed arguments");
                if (typeof data["clipNote"] == 'object') {
                  LOG
                      .debug("Using supplied clipNote object to populate quick note form");
                  var clipNote = (data.clipNote instanceof Evernote.ClipNote) ? data.clipNote
                      : new Evernote.ClipNote(data.clipNote);
                  self.quickNoteForm.populateWithNote(Evernote.context,
                      clipNote);
                } else {
                  LOG
                      .debug("No clipNote object passed, using as a blank quick note");
                }
                var opts = $.extend(true, {}, data);
                if (typeof opts["clipNote"] != 'undefined') {
                  delete opts["clipNote"];
                }
                self.quickNoteForm.populateWith(opts);
                // if there's a mailTo addresses given, show them
                var mailTo = self.quickNoteForm
                    .getField(self.quickNoteForm.mailToFieldName);
                if (self.quickNoteForm.mailTo) {
                  $("#quickNote_mailTo").show();
                } else {
                  $("#quickNote_mailTo").hide();
                }
                $.extend(true, viewOpts, data);
              } else {
                LOG
                    .debug("No options were given, will operate as quick note with default options");
              }
              // make sure we get the right notebook
              var defaultNotebook = Evernote.context
                  .getNotebookByGuid(self.quickNoteForm.notebookGuid);
              if (!defaultNotebook) {
                defaultNotebook = Evernote.context.getPreferredNotebook();
              }
              if (defaultNotebook instanceof Evernote.Notebook) {
                self.quickNoteForm.notebookGuid = defaultNotebook.guid;
              }
              // classify as auto-saved or not
              if (viewOpts.autoSaved) {
                $("#quickNoteView h2").html(
                    chrome.i18n.getMessage("autoSavedNote"));
                $("#quickNoteView").addClass("autoSaved");
                $("#quickNoteView input[name=cancel]").val(
                    chrome.i18n.getMessage("quickNote_discard"));
              } else {
                $("#quickNoteView h2")
                    .html(chrome.i18n.getMessage("quickNote"));
                $("#quickNoteView").removeClass("autoSaved");
                $("#quickNoteView input[name=cancel]").val(
                    chrome.i18n.getMessage("quickNote_cancel"));
              }
              // open drawer if needed
              if (Evernote.context.options.noteList == Evernote.Options.NOTE_LIST_OPTIONS.ALWAYS
                  || (Evernote.context.options.noteList == Evernote.Options.NOTE_LIST_OPTIONS.REMEMBER && Evernote.context.state.noteList)) {
                setTimeout(function() {
                  self.searchDrawer.open();
                }, 100);
              }
              // focus on first tab element
              $("#quickNoteView *[tabindex=1]").focus();
            });
    $("#quickNoteView").bind("hide", function(event) {
      LOG.debug("#quickNoteView.onHide");
      self.viewManager.hideBlock($("#header"));
    });
  };

  Evernote.ChromePopup.prototype.bindViewsWithDrawer = function() {
    LOG.debug("Popup.bindViewsWithDrawer");
    var self = this;
    $(".viewWithDrawer").bind("show", function(event) {
      self.initDrawers();
      chrome.tabs.getSelected(null, function(tab) {
        if (tab && tab.url) {
          self.doNoteContextSearch(tab.url);
        } else {
          LOG.warn("Could not determine URL of selected tab");
        }
      });
      self.searchDrawer.show();
      if (self.searchHelper && self.searchHelper.hasResults()) {
        var nf = new Evernote.NoteFilter(self.searchHelper.noteFilter);
        self.doNoteSearch(nf);
        setTimeout(function() {
          var td = $.tabDrawer.groups[0][0];
          if (td && !td.isOpen()) {
            td.open();
          }
        }, Evernote.ChromePopup.DEFAULT_TIMEOUT);
      } else {
        self.doNoteSearch();
      }
    });
    $(".viewWithDrawer").bind("hide", function(event) {
      $.tabDrawer.hideAll();
    });
  };

  Evernote.ChromePopup.prototype.bindDrawers = function() {
    var self = this;
    $( [ this.searchDrawer.get(0), this.contextDrawer.get(0) ]).bind(
        "opendrawer", function() {
          LOG.debug("alldrawers.onopendrawer");
          // forcefully updating body height to fit the drawer (otherwise, the
        // underlying view may cause the drawer to end up lower than it needs to
        // be)
        self.viewManager.updateBodyHeight(350);
        if (!self.searchHelper || !self.searchHelper.hasResults())
          Evernote.context.state.noteList = true;
        if (self.viewManager.currentView) {
          // hide previous view when show drawer
          setTimeout(function() {
            self.viewManager.currentView.hide();
          }, Evernote.ChromePopup.VIEW_TRANSITION_TIME / 2);
        }
        // update body height in case there's something visible in the banner
        setTimeout(function() {
          var extraHeight = 0;
          $(".banner").each(function(i, e) {
            var $e = $(e);
            if ($e.css("display") != "none") {
              extraHeight += $e.height();
            }
          });
          if (extraHeight > 0) {
            var $body = $(document.body);
            $body.css( {
              height : ""
            });
            var newHeight = $body.height() + extraHeight;
            $body.css( {
              height : newHeight + "px !important"
            });
          }
        }, Evernote.ChromePopup.VIEW_TRANSITION_TIME + 100);
        if (!self.searchQueryPopulated) {
          self.populateSearchQueries($(".notelistSearchQuery"));
          self.searchQueryPopulated = true;
        }
      }).bind("closedrawer", function() {
      LOG.debug("alldrawers.closedrawer");
      self.viewManager.updateBodyHeight();
      Evernote.context.state.noteList = false;
      if (self.viewManager.currentView) {
        // show previous view when hiding drawer
        setTimeout(function() {
          self.viewManager.currentView.show();
        }, Evernote.ChromePopup.VIEW_TRANSITION_TIME / 2);
      }
      // update body height in case it was tweaked when the drawer opened
        setTimeout(function() {
          var $body = $(document.body);
          $body.css( {
            height : ""
          });
          self.viewManager.updateBodyHeight();
        }, Evernote.ChromePopup.VIEW_TRANSITION_TIME + 100);
      });
    // bind search view actions
    this.searchDrawer.bind("focusdrawer", function() {
      LOG.debug("searchdrawer.focusdrawer");
      $("#notesSearchQuery").focus();
      $("#notesSearchQuery").select();
      if (Evernote.context.state.noteListScrollTop) {
        setTimeout(function() {
          $("#notesList").scrollTo(Evernote.context.state.noteListScrollTop);
        }, Evernote.ChromePopup.NOTELIST_SCROLLTO_DELAY);
      }
    });
  };

  Evernote.ChromePopup.prototype.toggleDrawer = function(drawer) {
    LOG.debug("Popup.toggleDrawer");
    var drawerWasOpen = drawer.hasClass("openDrawer");
    LOG.debug("Drawer was" + ((drawerWasOpen) ? "" : " not") + " open");
    if (!drawerWasOpen) {
      // if opening drawer, toggle class on body first
      // otherwise do this at the end
      $("body").toggleClass("openDrawer",
          Evernote.ChromePopup.VIEW_TRANSITION_TIME);
      Evernote.context.state.noteList = true;
    } else {
      Evernote.context.state.noteList = false;
    }

    var self = this;
    if (this.viewManager.currentView) {
      LOG.debug("Handling previously opened view...");
      if (drawerWasOpen) {
        // show previous view when hiding drawer
        setTimeout(function() {
          self.viewManager.currentView.show();
        }, Evernote.ChromePopup.VIEW_TRANSITION_TIME / 2);
      } else {
        // hide previous view when show drawer
        setTimeout(function() {
          self.viewManager.currentView.hide();
        }, Evernote.ChromePopup.VIEW_TRANSITION_TIME / 2);
      }
    }
    drawer.toggleClass("openDrawer closedDrawer",
        Evernote.ChromePopup.VIEW_TRANSITION_TIME, function() {
          drawer.trigger((drawerWasOpen) ? "closedrawer" : "opendrawer");
        });
    $(".drawerHandle").toggleClass("openDrawer closedDrawer",
        Evernote.ChromePopup.VIEW_TRANSITION_TIME);
    // if closing the drawer toggle class on body last
    if (drawerWasOpen) {
      $("body").toggleClass("openDrawer",
          Evernote.ChromePopup.VIEW_TRANSITION_TIME);
    }
  };

  Evernote.ChromePopup.prototype.bindForms = function() {
    LOG.debug("Adding expression method");
    // adding regex validation method
    $.validator.addMethod("mask", $.fn.validate.methods.mask, chrome.i18n
        .getMessage("invalidMask"));

    // trim function - replaces value with trimmed value
    $.validator.addMethod("trim", $.fn.validate.methods.trim, "trim error");

    // separates value into parts and checks if total number of parts is within
    // given range
    $.validator.addMethod("totalPartsRange",
        $.fn.validate.methods.totalPartsRange, chrome.i18n
            .getMessage("totalPartsNotInRange"));

    // separates value into parts and checks whether individual parts are within
    // given range in length
    $.validator.addMethod("partLengthRange",
        $.fn.validate.methods.partLengthRange, chrome.i18n
            .getMessage("partLengthNotInRange"));

    // separates value into parts and checks whether individual parts match
    // given
    // mask
    $.validator.addMethod("partMask", $.fn.validate.methods.partMask);

    // custom callback validator. Useful for transforms...
    $.validator.addMethod("toLowerCase", $.fn.validate.methods.toLowerCase);

    // duck punching invalidate method
    $.validator.prototype.invalidate = function(fieldName, errorMessage) {
      var thisErr = {};
      thisErr[fieldName] = errorMessage;
      this.showErrors(thisErr);
    };

    // bind individual forms
    this.bindLoginForm();
    this.bindFileForm();
    this.bindQuickNoteForm();
    this.bindSearchForm();
  };

  Evernote.ChromePopup.prototype.bindLoginForm = function() {
    LOG.debug("Popup.bindLoginForm");
    var form = $("form[name=loginForm]");
    var self = this;
    if (form.length == 0) {
      LOG.warn("Could not find login form");
      return;
    }
    $("#useSearchHelper").bind("change", function(event) {
      // LOG.debug(checked);
        var opts = Evernote.context.getOptions();
        opts.useSearchHelper = this.checked;
        Evernote.context.setOptions(opts);
      });
    var opts = {
      submitHandler : function(form) {
        self.submitLoginForm();
      },
      errorClass : this.viewManager.FORM_FIELD_ERROR_MESSAGE_CLASS,
      errorElement : "div",
      onkeyup : false,
      onfocusout : false,
      invalidHandler : function() {
        self.viewManager.updateBodyHeight();
      },
      success : function() {
        self.viewManager.updateBodyHeight();
      },
      rules : {
        username : {
          required : true,
          toLowerCase : true,
          minlength : Evernote.Constants.Limits.EDAM_USER_USERNAME_LEN_MIN,
          maxlength : Evernote.Constants.Limits.EDAM_USER_USERNAME_LEN_MAX,
          mask : Evernote.Constants.Limits.EDAM_USER_USERNAME_REGEX
        },
        password : {
          required : true,
          minlength : Evernote.Constants.Limits.EDAM_USER_PASSWORD_LEN_MIN,
          maxlength : Evernote.Constants.Limits.EDAM_USER_PASSWORD_LEN_MAX,
          mask : Evernote.Constants.Limits.EDAM_USER_PASSWORD_REGEX
        }
      },
      messages : {
        username : {
          required : chrome.i18n.getMessage("valueNotPresent", chrome.i18n
              .getMessage("loginForm_username")),
          minlength : chrome.i18n.getMessage("valueTooShort", [
              chrome.i18n.getMessage("loginForm_username"),
              Evernote.Constants.Limits.EDAM_USER_USERNAME_LEN_MIN ]),
          maxlength : chrome.i18n.getMessage("valueTooLong", [
              chrome.i18n.getMessage("loginForm_username"),
              Evernote.Constants.Limits.EDAM_USER_USERNAME_LEN_MAX ]),
          mask : chrome.i18n.getMessage("invalidUsername")
        },
        password : {
          required : chrome.i18n.getMessage("valueNotPresent", chrome.i18n
              .getMessage("loginForm_password")),
          minlength : chrome.i18n.getMessage("valueTooShort", [
              chrome.i18n.getMessage("loginForm_password"),
              Evernote.Constants.Limits.EDAM_USER_PASSWORD_LEN_MIN ]),
          maxlength : chrome.i18n.getMessage("valueTooLong", [
              chrome.i18n.getMessage("loginForm_password"),
              Evernote.Constants.Limits.EDAM_USER_PASSWORD_LEN_MAX ]),
          mask : chrome.i18n.getMessage("invalidPassword")
        }
      }
    };
    LOG.debug("Setting up validation on login form");
    this.loginValidator = form.validate(opts);
  };

  Evernote.ChromePopup.prototype.bindQuickNoteForm = function() {
    LOG.debug("Popup.bindQuickNoteForm");
    var form = $("form[name=quickNoteForm]");
    if (form.length == 0) {
      LOG.warn("Could not find quickNoteForm");
      return;
    }
    var self = this;
    var opts = {
      submitHandler : function(form) {
        self.submitQuickNoteForm();
      },
      errorClass : this.viewManager.FORM_FIELD_ERROR_MESSAGE_CLASS,
      errorElement : "div",
      onkeyup : false,
      onfocusout : false,
      rules : {
        title : {
          trim : true,
          required : true,
          rangelength : [ Evernote.Constants.Limits.EDAM_NOTE_TITLE_LEN_MIN,
              Evernote.Constants.Limits.EDAM_NOTE_TITLE_LEN_MAX ],
          mask : Evernote.Constants.Limits.EDAM_NOTE_TITLE_REGEX
        },
        tagNames : {
          totalPartsRange : [ Evernote.Constants.Limits.EDAM_NOTE_TAGS_MIN,
              Evernote.Constants.Limits.EDAM_NOTE_TAGS_MAX ],
          partLengthRange : [ Evernote.Constants.Limits.EDAM_TAG_NAME_LEN_MIN,
              Evernote.Constants.Limits.EDAM_TAG_NAME_LEN_MAX ],
          partMask : Evernote.Constants.Limits.EDAM_TAG_NAME_REGEX
        },
        mailTo : {
          trim : true,
          totalPartsRange : [ 0,
              Evernote.Constants.Limits.EDAM_USER_RECENT_MAILED_ADDRESSES_MAX ],
          partLengthRange : [ Evernote.Constants.Limits.EDAM_EMAIL_LEN_MIN,
              Evernote.Constants.Limits.EDAM_EMAIL_LEN_MAX ],
          partMask : Evernote.Constants.Limits.EDAM_EMAIL_REGEX
        }
      },
      messages : {
        title : {
          rangelength : chrome.i18n.getMessage("valueNotInRange", [
              chrome.i18n.getMessage("quickNote_title"),
              Evernote.Constants.Limits.EDAM_NOTE_TITLE_LEN_MIN,
              Evernote.Constants.Limits.EDAM_NOTE_TITLE_LEN_MAX ]),
          mask : chrome.i18n.getMessage("invalidTitle")
        },
        tagNames : {
          totalPartsRange : chrome.i18n.getMessage("tagNamesNotInRange", [
              Evernote.Constants.Limits.EDAM_NOTE_TAGS_MIN,
              Evernote.Constants.Limits.EDAM_NOTE_TAGS_MAX ]),
          partLengthRange : chrome.i18n.getMessage("tagNameNotInRange", [
              Evernote.Constants.Limits.EDAM_TAG_NAME_LEN_MIN,
              Evernote.Constants.Limits.EDAM_TAG_NAME_LEN_MAX ]),
          partMask : chrome.i18n.getMessage("invalidTagName")
        },
        mailTo : {
          totalPartsRange : chrome.i18n
              .getMessage(
                  "mailTosNotInRange",
                  [
                      0,
                      Evernote.Constants.Limits.EDAM_USER_RECENT_MAILED_ADDRESSES_MAX ]),
          partLengthRange : chrome.i18n.getMessage("mailToNotInRange", [
              Evernote.Constants.Limits.EDAM_EMAIL_LEN_MIN,
              Evernote.Constants.Limits.EDAM_EMAIL_LEN_MAX ]),
          partMask : chrome.i18n.getMessage("invalidMailTo")
        }
      }
    };
    LOG.debug("Setting up validation on quicknote form");
    this.quickNoteValidator = form.validate(opts);
    $(this.quickNoteForm.getField(this.quickNoteForm.fullPageFieldName))
        .click(
            function() {
              var options = Evernote.context.options;
              if (self.options
                  && self.options.fullPage == Evernote.Options.FULL_PAGE_OPTIONS.REMEMBER) {
                Evernote.context.state.fullPage = self.quickNoteForm.fullPage;
              }
            });
    $("form[name=quickNoteForm] label[for=mailTo]").click(function(event) {
      var f = $("#quickNote_mailTo");
      if (f.length == 0) {
        return;
      }
      if (f.css("display") == "none") {
        f.show();
      } else {
        // f.hide();
      }
      self.viewManager.updateBodyHeight();
    });
    $("form[name=quickNoteForm]").observeform(
        {
          freezeSubmit : false,
          changeKeyboardDelay : Evernote.ChromePopup.AUTO_SAVE_DELAY,
          onChange : function(changeEvent, changeElement, changeForm,
              observeOptions) {
            var f = $("form[name=quickNoteForm]");
            f.addClass("changed");
            self.autoSaveQuickNote();
          }
        });
  };

  Evernote.ChromePopup.prototype.bindFileForm = function() {
    LOG.debug("Popup.bindFileForm");
    var form = $("form[name=fileForm]");
    if (form.length == 0) {
      LOG.warn("Could not find quickNoteForm");
      return;
    }
    var self = this;
    var opts = {
      submitHandler : function(form) {
        self.submitFileForm();
      },
      errorClass : this.viewManager.FORM_FIELD_ERROR_MESSAGE_CLASS,
      errorElement : "div",
      onkeyup : false,
      onfocusout : false,
      rules : {
        title : {
          trim : true,
          required : true,
          rangelength : [ Evernote.Constants.Limits.EDAM_NOTE_TITLE_LEN_MIN,
              Evernote.Constants.Limits.EDAM_NOTE_TITLE_LEN_MAX ],
          mask : Evernote.Constants.Limits.EDAM_NOTE_TITLE_REGEX
        },
        tagNames : {
          totalPartsRange : [ Evernote.Constants.Limits.EDAM_NOTE_TAGS_MIN,
              Evernote.Constants.Limits.EDAM_NOTE_TAGS_MAX ],
          partLengthRange : [ Evernote.Constants.Limits.EDAM_TAG_NAME_LEN_MIN,
              Evernote.Constants.Limits.EDAM_TAG_NAME_LEN_MAX ],
          partMask : Evernote.Constants.Limits.EDAM_TAG_NAME_REGEX
        },
        mailTo : {
          trim : true,
          totalPartsRange : [ 0,
              Evernote.Constants.Limits.EDAM_USER_RECENT_MAILED_ADDRESSES_MAX ],
          partLengthRange : [ Evernote.Constants.Limits.EDAM_EMAIL_LEN_MIN,
              Evernote.Constants.Limits.EDAM_EMAIL_LEN_MAX ],
          partMask : Evernote.Constants.Limits.EDAM_EMAIL_REGEX
        }
      },
      messages : {
        title : {
          rangelength : chrome.i18n.getMessage("valueNotInRange", [
              chrome.i18n.getMessage("quickNote_title"),
              Evernote.Constants.Limits.EDAM_NOTE_TITLE_LEN_MIN,
              Evernote.Constants.Limits.EDAM_NOTE_TITLE_LEN_MAX ]),
          mask : chrome.i18n.getMessage("invalidTitle")
        },
        tagNames : {
          totalPartsRange : chrome.i18n.getMessage("tagNamesNotInRange", [
              Evernote.Constants.Limits.EDAM_NOTE_TAGS_MIN,
              Evernote.Constants.Limits.EDAM_NOTE_TAGS_MAX ]),
          partLengthRange : chrome.i18n.getMessage("tagNameNotInRange", [
              Evernote.Constants.Limits.EDAM_TAG_NAME_LEN_MIN,
              Evernote.Constants.Limits.EDAM_TAG_NAME_LEN_MAX ]),
          partMask : chrome.i18n.getMessage("invalidTagName")
        },
        mailTo : {
          totalPartsRange : chrome.i18n
              .getMessage(
                  "mailTosNotInRange",
                  [
                      0,
                      Evernote.Constants.Limits.EDAM_USER_RECENT_MAILED_ADDRESSES_MAX ]),
          partLengthRange : chrome.i18n.getMessage("mailToNotInRange", [
              Evernote.Constants.Limits.EDAM_EMAIL_LEN_MIN,
              Evernote.Constants.Limits.EDAM_EMAIL_LEN_MAX ]),
          partMask : chrome.i18n.getMessage("invalidMailTo")
        }
      }
    };
    LOG.debug("Setting up validation on file form");
    this.fileNoteValidator = form.validate(opts);
    $("form[name=fileForm] label[for=mailTo]").click(function(event) {
      var f = $("#fileNote_mailTo");
      if (f.length == 0) {
        return;
      }
      if (f.css("display") == "none") {
        f.show();
      } else {
        // f.hide();
      }
      self.viewManager.updateBodyHeight();
    });
    $("form[name=fileForm]").observeform( {
      freezeSubmit : false,
      changeKeyboardDelay : Evernote.ChromePopup.AUTO_SAVE_DELAY,
      onChange : function() {
        LOG.debug("File note changed...");
        self.fileNoteChanged = true;
      }
    });
  };

  Evernote.ChromePopup.prototype.bindSearchForm = function() {
    // SEARCH QUERY BINDINGS
    var searchQueryField = $("#notesSearchQuery");
    var self = this;
    // make sure to set NoteFilter to fuzzy mode when first focused.
    searchQueryField.focus(function(event) {
      Evernote.context.noteFilter.fuzzy = true;
    });
    // make sure we hide autocomplete popup on ENTER
    searchQueryField.keyup(function(event) {
      if (event.keyCode == 13) {
        $(".ac_results").hide();
        if (!Evernote.ChromePopup.NOTELIST_AC_MULTIPLE) {
          self.submitNotesSearchForm();
        }
      }
    });
  };

  Evernote.ChromePopup.prototype.removeAutoSavedNote = function() {
    LOG.debug("ChromePopup.removeAutoSavedNote");
    Evernote.context.autoSavedNote = null;
    Evernote.chromeExtension.getCurrentTab(function(tab) {
      Evernote.Utils.updateBadge(Evernote.context, tab.id);
    });
  };

  Evernote.ChromePopup.prototype.autoSaveQuickNote = function() {
    LOG.debug("ChromePopup.autoSaveQuickNote");
    var options = Evernote.context.options;
    if (this.options
        && this.options.autoSaveClipNote == Evernote.Options.AUTO_SAVE_CLIPNOTE_OPTIONS.ALWAYS) {
      var clipNote = this.quickNoteForm.asClipNote();
      if (clipNote instanceof Evernote.ClipNote) {
        LOG.info("Auto-saving clipNote...");
        $("#quickNoteAutoSaveIndicator").show();
        try {
          Evernote.context.autoSavedNote = clipNote;
          // Evernote.context.autosaveProcessor.add(clipNote);
          this.updateBadge();
        } catch (e) {
          LOG.error("Popup could not auto-save quick note: " + e);
        }
        $("#quickNoteAutoSaveIndicator").fadeOut(300);
      } else {
        LOG.warn("Not auto-saving note because it is not a clipNote");
      }
    }
  };

  Evernote.ChromePopup.prototype.loginWithForm = function(form) {
    LOG.debug("ChromePopup.loginWithForm");
    var self = this;
    if (typeof form == 'object') {
      this.unabort();
      var username = form.find("[name=username]").val().toLowerCase();
      var password = form.find("[name=password]").val();
      var rememberMe = form.find("[name=rememberMe]").attr("checked");
      this.viewManager.wait(chrome.i18n.getMessage("loggingIn"));
      if (Evernote.context.user && Evernote.context.user.username != username) {
        LOG.info("Logging out old user (" + Evernote.context.user.username
            + ") and logging in as new user: " + username);
        this.logout(function() {
          self._login(username, password, rememberMe);
        });
      } else {
        LOG.info("Authenticating with remote as: " + username);
        this._login(username, password, rememberMe);
      }
    }
  };

  Evernote.ChromePopup.prototype._login = function(username, password,
      rememberMe) {
    LOG.debug("ChromePopup.login");
    var self = this;
    var form = this.getLoginForm();
    this.viewManager.wait(chrome.i18n.getMessage("loggingIn"));
    LOG.info("Authenticating with remote as: " + username);
    this.loginProc = Evernote.context.remote
        .authenticate(
            username,
            password,
            rememberMe,
            function(response, textStatus, xhr) {
              LOG.info("Authentication response received...");
              self.viewManager.clearWait();
              if (response.isError()) {
                var userErrors = response
                    .selectErrors(function(e) {
                      if ((e instanceof Evernote.EDAMUserException || e instanceof Evernote.ValidationError)
                          && (e.errorCode == Evernote.EDAMErrorCode.INVALID_AUTH
                              || e.errorCode == Evernote.EDAMErrorCode.DATA_REQUIRED || e.errorCode == Evernote.EDAMErrorCode.BAD_DATA_FORMAT)) {
                        return true;
                      }
                    });
                if (userErrors) {
                  LOG.info("Authentication invalid");
                  self.loginValidator.resetForm();
                  self.viewManager.showFormErrors(form, userErrors, function(
                      fieldName, errorMessage) {
                    self.loginValidator.invalidate(fieldName, errorMessage);
                  });
                } else {
                  LOG.warn("Unexpected response during login");
                  self.viewManager.showErrors(response.errors);
                }
                self.viewManager.switchView("loginView", {
                  username : username,
                  password : ""
                });
              } else {
                LOG.info("Successfully logged in");
                self.viewManager.hideView("loginView");
                if (rememberMe) {
                  LOG
                      .debug("Updating stored password because user asked to remember their password");
                  var opts = Evernote.context.getOptions(true);
                  opts.username = username;
                  opts.password = Evernote.XORCrypt.encrypt(password, username);
                  opts.apply();
                  new Evernote.RequestMessage(
                      Evernote.Constants.RequestType.OPTIONS_UPDATED).send();
                }
                if (Evernote.context.getSyncState() != null) {
                  LOG.info("Got syncState, continuing with clipping");
                  self.startUp();
                } else {
                  LOG.info("Didn't get syncState, acquiring one...");
                  self
                      .remoteSyncState(function() {
                        LOG
                            .info("Got syncState after login, continuing with clipping...");
                        self.startUp();
                      });
                }
              }
            },
            function(xhr, textStatus, error) {
              if (xhr && xhr.readyState == 4) {
                LOG
                    .error("Failed to authenticate due to transport problems (status: "
                        + xhr.status + ")");
              } else if (xhr) {
                LOG
                    .error("Failed to authenticate due to transport problems (readyState: "
                        + xhr.readyState + ")");
              } else {
                LOG
                    .error("Failed to authenticate due to unkonwn transport problems");
              }
              self.viewManager.clearWait();
              self.viewManager.showHttpError(xhr, textStatus, error);
            }, true);
  };

  Evernote.ChromePopup.prototype.logout = function(callback) {
    LOG.debug("ChromePopup.logout");
    this.viewManager.wait(chrome.i18n.getMessage("loggingOut"));
    LOG.info("Logging out...");
    var self = this;
    if (typeof callback != 'function') {
      callback = function() {
        self.dismissPopup(true);
        // window.close();
      };
    }
    var localLogout = function() {
      self.viewManager.clearWait();
      new Evernote.RequestMessage(Evernote.Constants.RequestType.LOGOUT, {
        resetOptions : true
      }).send();
      callback();
    };
    var logoutProc = Evernote.context.remote.logout(function(response,
        textStatus) {
      self.viewManager.clearWait();
      if (response.isResult()) {
        LOG.info("Successfully logged out");
      } else if (result.isError()) {
        LOG.warn("Soft error logging out");
      } else {
        LOG.error("Got garbage response when tried to logout");
      }
      localLogout();
    }, function(xhr, textStatus, error) {
      if (xhr && xhr.readyState == 4) {
        LOG.error("Failed to log out due to transport errors (status: "
            + xhr.status + ")");
      } else if (xhr) {
        LOG.error("Failed to log out due to transport errors (readyState: "
            + xhr.readyState + ")");
      } else {
        LOG.error("Failed to log out due to unknown transport errors");
      }
      self.viewManager.clearWait();
      localLogout();
    }, true);
  };

  Evernote.ChromePopup.prototype.unabort = function() {
    LOG.debug("ChromePopup.unabort");
    this.aborted = false;
    this.viewManager.quiet = false;
  };

  Evernote.ChromePopup.prototype.abort = function() {
    LOG.debug("ChromePopup.abort");
    this.aborted = true;
    this.viewManager.quiet = true;
    this.abortProcs();
  };

  Evernote.ChromePopup.prototype.abortProcs = function() {
    LOG.debug("ChromePopup.abortProcs");
    if (this.loginProc && typeof this.loginProc.abort == 'function') {
      this.loginProc.abort();
      this.loginProc = null;
    }
    if (this.findProc && typeof this.findProc.abort == 'function') {
      this.findProc.abort();
      this.findProc = null;
    }
    if (this.findContextProc && typeof this.findContextProc.abort == 'function') {
      this.findContextProc.abort();
      this.findContextProc = null;
    }
  };

  Evernote.ChromePopup.prototype.handleResponseError = function(response, quiet) {
    LOG.debug("ChromePopup.handleResponseError ["
        + ((quiet) ? "quiet" : "not quiet") + "]");
    if (response && response.isMissingAuthTokenError()) {
      LOG
          .warn("Response indicates a problem with retaining authentication token between requests");
      if (!quiet) {
        this.viewManager.showError(chrome.i18n
            .getMessage("authPersistenceError"));
      }
      return true;
    } else if (response && response.isAuthTokenExpired()) {
      LOG.warn("Response indicates expired authentication");
      if (!quiet) {
        this.viewManager.showError(chrome.i18n.getMessage("authExpiredError"));
      }
      return true;
    } else if (response && response.isInvalidAuthentication()) {
      LOG.warn("Response indicates invalid authentication");
      var username = Evernote.context.options.username || "";
      this.viewManager.switchView("loginView", {
        username : username,
        password : ""
      });
      this.viewManager.showErrors(response.errors);
      return true;
    }
    return false;
  };

  Evernote.ChromePopup.prototype.remoteFileNote = function(note, success,
      failure) {
    LOG.debug("Popup.remoteFileNote");
    if (!(note instanceof Evernote.Note)) {
      LOG.error("Tried to file non-Note");
      return;
    }
    this.viewManager.wait(chrome.i18n.getMessage("filing"));
    LOG.info("Filing note...");
    var self = this;
    var fileProc = Evernote.context.remote
        .file(
            note,
            function(response, textStatus) {
              self.viewManager.clearWait();
              LOG.debug("Popup got response from server regarding filed note");
              if (response.isResult()) {
                LOG.info("Successfully filed clipped note");
                if (typeof success == 'function') {
                  success(response, textStatus);
                }
              } else if (response.isError()) {
                if (!self.handleResponseError(response)) {
                  LOG.warn("Problem filing clipped note");
                  if (typeof failure == 'function') {
                    failure(response, textStatus);
                  }
                }
              } else {
                LOG
                    .error("Unrecognized response when tried to file previously clipped note");
              }
            },
            function(xhr, textStatus, error) {
              if (xhr && xhr.readyState == 4) {
                LOG
                    .error("Failed to file clipped note due to transport errors (status: "
                        + xhr.status + ")");
              } else if (xhr) {
                LOG
                    .error("Failed to file clipped note due to transport errors (readyState: "
                        + xhr.readyState + ")");
              } else {
                LOG
                    .error("Failed to file clipped note due to unknown transport errors");
              }
              self.viewManager.clearWait();
              self.viewManager.showHttpError(xhr, textStatus, error);
            }, true);
    return fileProc;
  };

  Evernote.ChromePopup.prototype.remoteDeleteNote = function(note, success,
      failure) {
    LOG.debug("Popup.remoteDeleteNote");
    if (!(note instanceof Evernote.Note)) {
      LOG.error("Tried to delete non-Note");
      return;
    }
    this.viewManager.wait(chrome.i18n.getMessage("deleting"));
    LOG.info("Deleting previously clipped note...");
    var self = this;
    var deleteProc = Evernote.context.remote
        .deleteNote(
            note,
            function(response, textStatus) {
              self.viewManager.clearWait();
              LOG
                  .debug("Popup got response from the server regarding deletion of note");
              if (response.isResult()) {
                LOG.info("Successfully deleted previously clipped note");
                if (typeof success == 'function') {
                  success(response, textStatus);
                }
              } else if (response.isError()) {
                if (!self.handleResponseError(response)) {
                  LOG.warn("Failed to delete previously clipped note");
                  if (typeof failure == 'function') {
                    failure(response, textStatus);
                  }
                }
              } else {
                LOG
                    .error("Unrecognized response when tried to delete previously clipped note");
              }
            },
            function(xhr, textStatus, error) {
              if (xhr && xhr.readyState == 4) {
                LOG
                    .error("Failed to delete previously clipped note due to transport errors (status: "
                        + xhr.status + ")");
              } else if (xhr) {
                LOG
                    .error("Failed to delete previously clipped note due to transport errors (readyState: "
                        + xhr.readyState + ")");
              } else {
                LOG
                    .error("Failed to delete previously clipped note due to unknown transport errors");
              }
              self.viewManager.clearWait();
              self.viewManager.showHttpError(xhr, textStatus, error);
            }, true);
    return deleteProc;
  };

  Evernote.ChromePopup.prototype.remoteClipNote = function(clipNote, success,
      failure) {
    LOG.debug("Popup.remoteClipNote");
    if (!(clipNote instanceof Evernote.ClipNote)) {
      LOG.error("Tried to clip invalid object");
      return;
    }
    this.viewManager.wait(chrome.i18n.getMessage("clippingToEvernote"));
    LOG.info("Sending clip to the server");
    var self = this;
    var clipProc = Evernote.context.remote
        .clip(
            clipNote,
            function(response, textStatus) {
              self.viewManager.clearWait();
              LOG
                  .debug("Popup got response from the server regarding clipped note");
              if (response.isResult()) {
                LOG.info("Successfully sent clip to the server");
                if (typeof success == 'function') {
                  success(response, textStatus);
                }
              } else if (response.isError()) {
                if (!self.handleResponseError(response)) {
                  LOG.warn("Failed to send clip to the server");
                  if (typeof failure == 'function') {
                    failure(response, textStatus);
                  }
                }
              } else {
                LOG
                    .error("Unrecognized response when tried to send clip to the server");
              }
            },
            function(xhr, textStatus, error) {
              if (xhr && xhr.readyState == 4) {
                LOG
                    .error("Failed to send clip to server due to transport errors (status: "
                        + xhr.status + ")");
              } else if (xhr) {
                LOG
                    .error("Failed to send clip to server due to transport errors (readyState: "
                        + xhr.readyState + ")");
              } else {
                LOG
                    .error("Failed to send clip to server due to unknown transport errors");
              }
              self.viewManager.clearWait();
              self.viewManager.showHttpError(xhr, textStatus, error);
            }, true);
    return clipProc;
  };

  Evernote.ChromePopup.prototype.remoteFindNotes = function(filter, offset,
      maxNotes, success, failure) {
    LOG.debug("Popup.remoteFindNotes");
    if (!(filter instanceof Evernote.NoteFilter)) {
      LOG.error("Tried to find notes without valid NoteFilter");
      return;
    }
    // Evernote.ViewManager.wait(chrome.i18n.getMessage("findingNotes"));
    LOG.info("Searching notes: " + JSON.stringify(filter));
    var self = this;
    var findProc = Evernote.context.remote
        .findSnippetNotes(
            filter,
            offset,
            maxNotes,
            self.constructor.SNIPPET_MAX_LENGTH,
            function(response, textStatus) {
              // self.viewManager.clearWait();
              LOG
                  .debug("Popup got response from the server regarding note search");
              if (response.isResult()) {
                LOG.info("Successfully retreived note search results");
                if (typeof success == 'function') {
                  success(response, textStatus);
                }
              } else if (response.isError()) {
                if (!self.handleResponseError(response)) {
                  LOG.warn("Failed to find notes");
                  if (typeof failure == 'function') {
                    failure(response, textStatus);
                  }
                }
              } else {
                LOG
                    .error("Unrecognized response when tried to find notes on the server");
              }
            },
            function(xhr, textStatus, error) {
              if (xhr && xhr.readyState == 4) {
                LOG
                    .error("Failed to find notes due to transport errors (status: "
                        + xhr.status + ")");
              } else if (xhr) {
                LOG
                    .error("Failed to find notes due to transport errors (readyState: "
                        + xhr.readyState + ")");
              } else {
                LOG
                    .error("Failed to find notes due to unknown transport errors");
              }
              // self.viewManager.clearWait();
              self.viewManager.showHttpError(xhr, textStatus, error);
            }, true);
    return findProc;
  };

  Evernote.ChromePopup.prototype.remoteSyncState = function(success, failure) {
    LOG.debug("Popup.remoteSyncState");
    this.viewManager.wait(chrome.i18n.getMessage("synchronizing"));
    LOG.info("Asking server for sync state");
    var self = this;
    return Evernote.context.remote
        .getSyncState(
            null,
            function(response, textStatus, xhr) {
              self.viewManager.clearWait();
              if (response.isResult()) {
                LOG.info("Got successful result on sync");
                if (!Evernote.context.getSyncState()) {
                  LOG.warn("Somehow we're out of sync...");
                  return;
                }
                if (typeof success == 'function') {
                  success(response, textStatus);
                }
              } else if (response.isError()) {
                LOG.debug("About to handle response error when status is: "
                    + self.popupStatus);
                var quiet = (self.popupStatus == Evernote.ChromePopup.POPUP_STATUS_CODES.STARTUP) ? true
                    : false;
                if (!self.handleResponseError(response, quiet)) {
                  LOG.warn("Unexpected error");
                  self.viewManager.showErrors(response.errors);
                }
                if (typeof failure == 'function') {
                  failure(xhr, textStatus, response);
                }
              } else {
                LOG.error("Unexpected response when syncing");
                var err = new Evernote.Exception(
                    Evernote.EDAMErrorCode.UNKNOWN, chrome.i18n
                        .getMessage("Error_" + Evernote.EDAMErrorCode.UNKNOWN));
                self.viewManager.showError(err);
                if (typeof failure == 'function') {
                  failure(xhr, textStatus, response);
                }
              }
            },
            function(xhr, textStatus, error) {
              if (xhr && xhr.readyState == 4) {
                LOG
                    .error("Failed to find notes due to transport errors (status: "
                        + xhr.status + ")");
              } else if (xhr) {
                LOG
                    .error("Failed to find notes due to transport errors (readyState: "
                        + xhr.readyState + ")");
              } else {
                LOG
                    .error("Failed to find notes due to unknown transport errors");
              }
              self.viewManager.clearWait();
              self.viewManager.showHttpError(xhr, textStatus, error);
              if (typeof failure == 'function') {
                failure(xhr, textStatus, error);
              }
            }, true);
  };

  Evernote.ChromePopup.prototype.getLoginForm = function() {
    return $("form[name=loginForm]");
  };

  Evernote.ChromePopup.prototype.submitLoginForm = function() {
    LOG.debug("Popup.submitLoginForm");
    var form = this.getLoginForm();
    this.viewManager.hideErrors();
    this.viewManager.clearFormArtifacts(form);
    this.loginWithForm(form);
  };

  Evernote.ChromePopup.prototype.submitFileForm = function() {
    LOG.debug("Popup.submitFileForm");
    var self = this;
    if (this.fileNoteForm) {
      if (!this.fileNoteChanged) {
        LOG.info("No changes to file...");
        this.dismissPopup();
        return;
      }
      LOG.info("Filing changes...");
      this.viewManager.hideErrors();
      this.viewManager.clearFormArtifacts(this.fileNoteForm.form);
      LOG.debug("Grabbing data from form");
      var note = this.fileNoteForm.asNote();
      LOG.debug("Sending this to remote: " + note.toString());
      this.viewManager.hideView("fileView");
      var fileProc = this.remoteFileNote(note, function(response, textStatus) {
        self.viewManager.showMessage(chrome.i18n.getMessage("fileSuccess"));
        self.dismissPopup();
      }, function(response, textStatus) {
        if (response.errors.length > 1) {
          self.viewManager.showErrors(response.errors);
        } else {
          self.viewManager.showError(response.errors[0]);
        }
        self.viewManager.switchView("fileView", {
          note : note
        });
      });
    } else {
      LOG.debug("Nothing to file...");
    }
  };

  Evernote.ChromePopup.prototype.submitDeleteForm = function() {
    LOG.debug("Popup.submitDeleteForm");
    var self = this;
    if (this.fileNoteForm) {
      LOG.debug("Grabbing data from form");
      this.viewManager.hideErrors();
      var note = this.fileNoteForm.asNote();
      if (LOG.isDebugEnabled())
        LOG.debug("Sending this to remote: " + note.toString());
      this.viewManager.hideView("fileView");
      var fileProc = this.remoteDeleteNote(note,
          function(response, textStatus) {
            self.viewManager.showMessage(chrome.i18n
                .getMessage("deleteSuccess"));
            self.dismissPopup();
          }, function(response, textStatus) {
            self.viewManager.switchView("fileView", {
              note : note
            });
          });
    } else {
      LOG.debug("Nothing to delete");
    }
  };

  Evernote.ChromePopup.prototype.submitQuickNoteForm = function() {
    LOG.debug("Popup.submitQuickNoteForm");
    var self = this;
    if (this.quickNoteForm) {
      LOG.debug("Grabbing data from form");
      this.viewManager.hideErrors();
      var clipNote = this.quickNoteForm.asClipNote();
      this.viewManager.hideView("quickNoteView");
      this.abortProcs();
      this.removeAutoSavedNote();
      if (LOG.isDebugEnabled())
        LOG.debug("Sending this to remote: " + clipNote.toString());
      // if clipping full page but there's no content yet - then wait for it
      if (clipNote.fullPage && clipNote.content.length == 0) {
        if (this.quickNoteSubmitWait == null) {
          this.viewManager.wait(chrome.i18n.getMessage("clippingPageContent"));
          self.quickNoteSubmitWait = setTimeout(function() {
            self.submitQuickNoteForm();
          }, Evernote.ChromePopup.CLIP_PAGE_CONTENT_TIMEOUT);
          return;
        } else {
          this.viewManager.switchView("quickNoteView");
          this.quickNoteForm.fullPage = false;
          this.quickNoteForm.disableFullPage();
          this.viewManager.showError(chrome.i18n
              .getMessage("fullPageClipFailure"));
          this.quickNoteSubmitWait = null;
          return;
        }
      }
      // clear waiting process
      if (this.quickNoteSubmitWait) {
        clearTimeout(this.quickNoteSubmitWait);
        this.quickNoteSubmitWait = null;
      }
      // clear content before submitting if not full page
      // if there will be an error with submitting the note to the server,
      // we'll replace the content
      var origContent = clipNote.content;
      if (!clipNote.fullPage && clipNote.content.length > 0) {
        clipNote.content = "";
      }
      Evernote.chromeExtension.processClip(clipNote);
      this.dismissPopup();
    } else {
      LOG.debug("Nothing to clip...");
    }
  };

  Evernote.ChromePopup.prototype.cancelQuickNoteForm = function() {
    LOG.debug("Popup.cancelQuickNoteForm");
    this.resetQuickNote();
    this.dismissPopup();
  };

  Evernote.ChromePopup.prototype.resetQuickNote = function() {
    LOG.debug("ChromePopup.resetQuickNote");
    this.removeAutoSavedNote();
    this.updateBadge();
  };

  Evernote.ChromePopup.prototype.submitNotesSearchForm = function() {
    LOG.debug("Popup.submitNotesSearchForm");
    if (this.notesSearchForm) {
      var q = this.notesSearchForm.notesSearchQuery;
      var noteFilter = Evernote.context.noteFilter;
      noteFilter.resetQuery();
      noteFilter.words = q;
      Evernote.context.noteFilter = noteFilter;
      LOG.info("Searching for: " + JSON.stringify(noteFilter.toStorable()));
      $("#notesListItems").empty();
      Evernote.context.state.noteListScrollTop = null;
      this.doNoteSearch();
    } else {
      LOG.debug("No search query...");
    }
  };

  Evernote.ChromePopup.prototype.doNoteSearch = function(filter) {
    LOG.debug("Popup.doNoteSearch");
    var noteFilter = (filter instanceof Evernote.NoteFilter) ? filter
        : Evernote.context.noteFilter;
    if (noteFilter.words) {
      $("#notesSearchQuery").val(noteFilter.words);
    }
    var self = this;
    Evernote.context.state.noteListScrollTop = 0;
    $("#notesList").ascrollable(
        {
          debug : true,
          pageSize : Evernote.ChromePopup.NOTELIST_PAYLOAD_SIZE,
          pageBuffer : Evernote.ChromePopup.NOTELIST_PAGE_SIZE,
          itemHeight : Evernote.ChromePopup.NOTELIST_ITEM_HEIGHT,
          loadProcTimeout : Evernote.ChromePopup.NOTELIST_FETCH_TIMEOUT,
          debug : false,
          placeholderItem : self.createPlaceholderNoteListItem(),
          loadingContainer : $("#notesListLoadingContainer"),
          emptyContainer : $("#notesListEmptyContainer"),
          onScroll : function(event) {
            if (self.noteListScrollTimer)
              clearTimeout(self.noteListScrollTimer);
            self.noteListScrollTimer = setTimeout(function() {
              var pos = event.target.scrollTop;
              LOG.debug("Remembering scrollTop: " + pos);
              Evernote.context.state.noteListScrollTop = pos;
              self.noteListScrollTimer = null;
            }, 600);
          },
          onEmpty : function() {
            if (!noteFilter.isEmpty()) {
              $("#notesList > *").hide();
              $("#notesListEmptyContainer").show();
            } else {
              $("#notesList > *").hide();
              $("#notesList").addClass("notesListEmpty");
            }
          },
          totalItems : function() {
            return (self.noteList) ? self.noteList.totalNotes : 0;
          },
          onLoadPage : function(pageIndex, pageSize, totalPages) {
            self.findProc = self.remoteFindNotes(noteFilter,
                (pageIndex * pageSize), (pageSize * totalPages), function(
                    response, textStatus) {
                  LOG.debug("findProc success");
                  self.findProc = null;
                  self.noteList = response.result.noteList;
                  self.searchDrawer.setHandleTitle(chrome.i18n.getMessage(
                      "notes_titleWithCount", [ self.noteList.totalNotes ]));
                  $("#notesList").trigger("afterLoadPage",
                      [ pageIndex, pageSize, totalPages ]);
                }, function(response, textStatus) {
                  LOG.debug("findProc failed");
                  self.findProc = null;
                  if (response.errors.length == 1) {
                    self.viewManager.showError(response.errors[0]);
                  } else {
                    self.viewManager.showErrors(response.errors);
                  }
                });
            return false;
          },
          onAfterLoadPage : function(pageIndex, pageSize, totalPages) {
            if (pageIndex == 0 && Evernote.context.state.noteListScrollTop) {
              setTimeout(function() {
                $("#notesList").scrollTo(
                    Evernote.context.state.noteListScrollTop);
              }, Evernote.ChromePopup.NOTELIST_SCROLLTO_DELAY);
            }
          },
          items : function() {
            var items = new Array();
            if (self.noteList) {
              for ( var i = 0; i < self.noteList.notes.length; i++) {
                items[self.noteList.startIndex + i] = (self.createNoteListItem(
                    self.noteList.notes[i], (noteFilter) ? noteFilter.words
                        : null));
              }
            }
            return items;
          }
        });
  };

  Evernote.ChromePopup.prototype.doNoteContextSearch = function(url) {
    LOG.debug("Popup.doNoteContextSearch(" + url + ")");
    var self = this;
    // update URL on the search input prefix
    var domainStr = Evernote.Utils.urlTopDomain(url);
    $("#notesContextListTitle").html(domainStr);
    // setup NoteFilter
    this.noteContextFilter = new Evernote.NoteFilter();
    if (typeof url != 'string' || url.length == 0) {
      LOG.warn("Tried to find notes relative to empty URL... Ignoring!");
      return;
    }
    this.noteContextFilter.words = Evernote.Utils.urlToSearchQuery(url,
        "sourceUrl:");
    // setup ascrollable
    $("#notesContextList").ascrollable(
        {
          debug : true,
          pageSize : Evernote.ChromePopup.NOTELIST_PAYLOAD_SIZE,
          pageBuffer : Evernote.ChromePopup.NOTELIST_PAGE_SIZE,
          itemHeight : Evernote.ChromePopup.NOTELIST_ITEM_HEIGHT,
          loadProcTimeout : Evernote.ChromePopup.NOTELIST_FETCH_TIMEOUT,
          debug : false,
          placeholderItem : self.createPlaceholderNoteListItem(),
          loadingContainer : $("#notesContextListLoadingContainer"),
          emptyContainer : $("#notesContextListEmptyContainer"),
          onScroll : function(event) {
            if (self.noteListScrollTimer)
              clearTimeout(self.noteListScrollTimer);
            self.noteListScrollTimer = setTimeout(function() {
              var pos = event.target.scrollTop;
              LOG.debug("Remembering scrollTop: " + pos);
              // TODO: this needs to be remembered as another var
                // Evernote.context.state.noteListScrollTop = pos;
                self.noteListScrollTimer = null;
              }, 600);
          },
          onEmpty : function() {
            if (!self.noteContextFilter.isEmpty()) {
              $("#notesContextList > *").hide();
              $("#notesContextListEmptyContainer").show();
            } else {
              $("#notesContextList > *").hide();
              $("#notesContextList").addClass("notesListEmpty");
            }
          },
          totalItems : function() {
            return (noteContextList) ? noteContextList.totalNotes : 0;
          },
          onLoadPage : function(pageIndex, pageSize, totalPages) {
            // console.log("*** Fetching pageIndex=" + pageIndex + "; pageSize="
            // +
            // pageSize + "; totalPages=" + totalPages); // XXX
            self.findContextProc = self.remoteFindNotes(self.noteContextFilter,
                (pageIndex * pageSize), (pageSize * totalPages), function(
                    response, textStatus) {
                  LOG.debug("findContextProc success");
                  self.findContextProc = null;
                  noteContextList = response.result.noteList;
                  LOG.debug("Found " + noteContextList.totalNotes
                      + " notes relative to this domain...");
                  if (noteContextList.totalNotes > 0 || pageIndex > 0) {
                    self.contextDrawer.show();
                  } else {
                    self.contextDrawer.hide();
                  }
                  var domainProto = Evernote.Utils.urlProto(url);
                  if (domainProto && domainProto == "file") {
                    self.contextDrawer.setHandleTitle(chrome.i18n.getMessage(
                        "notes_titleLocalFilesAndCount",
                        [ noteContextList.totalNotes ]));
                    $("#notesContextListTitle").html(
                        chrome.i18n.getMessage("notes_titleForLocalFiles"));
                  } else {
                    var domainStr = Evernote.Utils.urlTopDomain(url);
                    self.contextDrawer.setHandleTitle(chrome.i18n.getMessage(
                        "notes_titleWithDomainAndCount", [ domainStr,
                            noteContextList.totalNotes ]));
                    $("#notesContextListTitle").html(
                        chrome.i18n.getMessage("notes_titleForDomain",
                            [ domainStr ]));
                  }
                  // console.log("Triggering afterLoadPage " + pageIndex + ", "
                // + pageSize
                // + ", " + totalPages); // XXX
                $("#notesContextList").trigger("afterLoadPage",
                    [ pageIndex, pageSize, totalPages ]);
              }, function(response, textStatus) {
                LOG.debug("findContextProc failed");
                self.findContextProc = null;
                if (response.errors.length == 1) {
                  self.viewManager.showError(response.errors[0]);
                } else {
                  self.viewManager.showErrors(response.errors);
                }
              });
            return false;
          },
          onAfterLoadPage : function(pageIndex, pageSize, totalPages) {
            /*
             * TODO: should address a different var if (pageIndex == 0 &&
             * Evernote.context.state.noteListScrollTop) { setTimeout(function() {
             * $("#notesContextList").scrollTo(Evernote.context.state.noteListScrollTop); },
             * Evernote.ChromePopup.NOTELIST_SCROLLTO_DELAY); }
             */
          },
          items : function() {
            var items = new Array();
            if (noteContextList) {
              for ( var i = 0; i < noteContextList.notes.length; i++) {
                items[noteContextList.startIndex + i] = (self
                    .createNoteListItem(noteContextList.notes[i], null));
              }
            }
            return items;
          }
        });
  };

  Evernote.ChromePopup.prototype.isClippableUrl = function(url) {
    if (typeof url == 'string') {
      var u = url.toLowerCase();
      if (u.indexOf("http") == 0) {
        return true;
      }
    }
    return false;
  };

  Evernote.ChromePopup.prototype.startUpWithSavedNote = function(tab) {
    LOG.debug("Popup.startUpWithSavedNote");
    var savedNote = Evernote.context.autoSavedNote;
    if (savedNote) {
      savedNote = (savedNote instanceof Evernote.ClipNote) ? savedNote
          : new Evernote.ClipNote(savedNote);
      var viewOpts = {
        clipNote : savedNote,
        autoSaved : true,
        fullPageEnabled : false
      };
      if (savedNote.saveUrl && typeof savedNote.url == 'string' && tab
          && typeof tab.url == 'string'
          && savedNote.url.toLowerCase() != tab.url.toLowerCase()) {
        viewOpts.saveUrlEnabled = false;
      }
      this.viewManager.switchView("quickNoteView", viewOpts);
    } else {
      LOG.warn("There was no note saved... starting afresh");
      this.startUpWithQuickNote(tab);
    }
  };

  Evernote.ChromePopup.prototype.startUpWithQuickNote = function(tab) {
    LOG.debug("Popup.startUpWithQuickNote");
    var viewOpts = {
      clipNote : new Evernote.ClipNote(),
      autoSaved : false,
      fullPageEnabled : false
    };
    if (tab
        && typeof tab.title == 'string'
        && (typeof tab.url != 'string' || (typeof tab.url == 'string' && tab.title != tab.url))) {
      viewOpts.clipNote.title = tab.title;
    }
    if (tab && typeof tab.url == 'string') {
      viewOpts.clipNote.url = tab.url;
    }
    viewOpts.clipNote.fullPage = false;
    viewOpts.clipNote.saveUrl = false;
    if (Evernote.context.getPreferredNotebook()) {
      viewOpts.notebookGuid = Evernote.context.getPreferredNotebook().guid;
    }
    this.viewManager.switchView("quickNoteView", viewOpts);
  };

  Evernote.ChromePopup.prototype.startUpWithSelection = function() {
    LOG.debug("Popup.startUpWithSelection");
    var fullPageOnly = false;
    this.getSelection(fullPageOnly);
  };

  Evernote.ChromePopup.prototype.startUp = function() {
    LOG.debug("Popup.startUp");
    var self = this;
    this.popupStatus = Evernote.ChromePopup.POPUP_STATUS_CODES.STARTED;
    // Evernote.context.autosaveProcessor.process(true);
    chrome.tabs
        .getSelected(
            null,
            function(tab) {
              if ((self.options.autoSaveClipNote == Evernote.Options.AUTO_SAVE_CLIPNOTE_OPTIONS.ALWAYS || self.options.autoSaveClipNote == Evernote.Options.AUTO_SAVE_CLIPNOTE_OPTIONS.REMEMBER)
                  && Evernote.context.autoSavedNote) {
                self.startUpWithSavedNote(tab);
              } else {
                if (tab && typeof tab.url == 'string'
                    && self.isClippableUrl(tab.url)) {
                  self.startUpWithSelection();
                } else {
                  self.startUpWithQuickNote(tab);
                }
              }
            });
  };

  Evernote.ChromePopup.prototype.updateBadge = function() {
    var self = this;
    Evernote.Utils.updateBadge(Evernote.context);
  };
})();


(function() {
  var LOG = null;

  Evernote.ChromeLogViewer = function ChromeLogViewer() {
    LOG = Evernote.chromeExtension.logger;
    this.__defineGetter__("logFiles", this.getLogFiles);
    this.__defineSetter__("logFiles", this.setLogFiles);
    this.initialize();
  };

  Evernote.ChromeLogViewer.LOG_DIR = "/logs";
  Evernote.ChromeLogViewer.MONITOR_INTERVAL = 10 * 1000;

  Evernote.ChromeLogViewer.prototype._sema = null;
  Evernote.ChromeLogViewer.prototype._fsa = null;
  Evernote.ChromeLogViewer.prototype._logFiles = null;
  Evernote.ChromeLogViewer.prototype._logViewerMonitor = null;
  Evernote.ChromeLogViewer.prototype._extensionInfo = null;

  Evernote.ChromeLogViewer.prototype.initialize = function() {
    this._sema = Evernote.Semaphore.mutex();
    this.initializeUI();
    this.initializeFSA();
    this.initBindings();
    var self = this;
    this._sema.critical(function() {
      chrome.management.get(chrome.i18n.getMessage("@@extension_Id"), function(
          infoObj) {
        self._sema.signal();
        if (infoObj) {
          self._extensionInfo = infoObj;
        }
      });
    });
  };

  Evernote.ChromeLogViewer.prototype.initializeUI = function() {
    var self = this;
    var selector = this.getLogSelector();
    if (selector) {
      selector.bind("change", function() {
        self.handleLogSelection();
      });
    }
    var follow = this.getFollow();
    follow.bind("click", function() {
      var $this = $(this);
      if ($this.attr("checked")) {
        self.scrollToBottom();
      }
    });
    var refreshRate = this.getRefreshRate();
    refreshRate.bind("change", function() {
      self.stopLogMonitor();
      self.monitorLogViewer();
    });
    var deleter = this.getDeleter();
    deleter.bind("click", function() {
      self.deleteLogFiles();
    });
    var exporter = this.getExporter();
    exporter.bind("click", function() {
      self.exportLogFiles();
    });
  };

  Evernote.ChromeLogViewer.prototype.initializeFSA = function() {
    var self = this;
    this._sema.critical(function() {
      self._fsa = new Evernote.FSA(PERSISTENT, 1024, function() {
        self._fsa.getCreateDirectory(self.constructor.LOG_DIR, function(
            dirEntry) {
          self._fsa.changeDirectory(self.constructor.LOG_DIR,
              function(dirEntry) {
                self._initializeLogFiles();
                self._sema.signal();
              }, self.onfsaerror);
        }, self.onfsaerror);
      }, function(err) {
        self._sema.signal();
        self.onfsaerror(err);
      });
    });
  };

  Evernote.ChromeLogViewer.prototype.initBindings = function() {
    var self = this;
    chrome.extension.onRequest
        .addListener(function(request, sender, sendResponse) {
          var req = Evernote.RequestMessage.fromObject(request);
          LOG.debug("Received request: " + req.code);
          if (req.code == Evernote.Constants.RequestType.LOG_FILE_SWAPPED
              && self.getFollow().attr("checked")) {
            LOG
                .debug("Re-initializing with new set of log files, cuz logs got swapped");
            self._initializeLogFiles();
          }
          sendResponse( {});
        });
  };

  Evernote.ChromeLogViewer.prototype._initializeLogFiles = function() {
    var self = this;
    this._fsa.listFiles(self.constructor.LOG_DIR, function(entries) {
      self.setUpdateLogFiles(entries);
    }, self.onfsaerror);
  };
  Evernote.ChromeLogViewer.prototype.onfsaerror = function(err) {
    LOG.exception(err);
    alert(err);
  };
  Evernote.ChromeLogViewer.prototype.setLogFiles = function(entryArray) {
    this._logFiles = entryArray;
  };
  Evernote.ChromeLogViewer.prototype.getLogFiles = function() {
    return this._logFiles;
  };
  Evernote.ChromeLogViewer.prototype.setUpdateLogFiles = function(entryArray) {
    this.logFiles = (entryArray && entryArray.length > 0) ? entryArray : null;
    this.populateLogSelector(this.logFiles);
  };
  Evernote.ChromeLogViewer.prototype.populateLogSelector = function(entries) {
    var selector = this.getLogSelector();
    if (selector && entries) {
      selector.empty();
      var lastEntry = null;
      for ( var i = 0; i < entries.length; i++) {
        if (entries[i].name) {
          var entry = $("<option value='" + entries[i].name + "'>"
              + entries[i].name + "</option>");
          selector.append(entry);
          lastEntry = entries[i];
        }
      }
      if (lastEntry) {
        selector.val(lastEntry.name);
      }
      if (selector.val()) {
        this.viewLog(selector.val());
      }
    } else if (selector) {
      selector.empty();
      var emptyOpt = $("<option value=''>"
          + chrome.i18n.getMessage("log_noLogsFound") + "</option>");
      selector.append(emptyOpt);
      this.viewLog(null);
    }
  };
  Evernote.ChromeLogViewer.prototype.getLogSelection = function() {
    var selector = this.getLogSelector();
    return selector.val();
  };
  Evernote.ChromeLogViewer.prototype.handleLogSelection = function() {
    var logName = this.getLogSelection();
    if (logName) {
      this.viewLog(logName);
    }
  };
  Evernote.ChromeLogViewer.prototype.viewLog = function(logName) {
    var self = this;
    if (logName) {
      var spinner = this.getSpinner();
      spinner.show();
      this._sema.critical(function() {
        self._fsa.readTextFile(logName, function(reader) {
          var viewer = self.getLogViewer();
          viewer.data( {
            logName : logName
          });
          viewer.text(reader.result);
          if (self.isFollowing()) {
            self.scrollToBottom();
          }
          self._sema.signal();
          spinner.hide();
          self.monitorLogViewer();
        }, self.onfsaerror);
      });
    } else {
      var viewer = this.getLogViewer();
      viewer.data( {
        logName : null
      });
      viewer.text(chrome.i18n.getMessage("log_noLogSelected"));
    }
  };
  Evernote.ChromeLogViewer.prototype.deleteLogFiles = function() {
    var self = this;
    var spinner = this.getSpinner();
    var ok = function() {
      self._sema.signal();
      spinner.hide();
      self.setAllSelected(false);
      self._initializeLogFiles();
    };
    var err = function(e) {
      self._sema.signal();
      alert("Error exporting log files: " + (e && e.code) ? e.code : e);
    };
    var cancel = function() {
      self._sema.signal();
      spinner.hide();
    };
    spinner.show();
    this._sema.critical(function() {
      if (self.isAllSelected()) {
        self._fsa.listFiles(self.constructor.LOG_DIR, function(fileEntries) {
          var yn = confirm(chrome.i18n.getMessage("logs_confirmDeleteFiles",
              [ fileEntries.length ]));
          if (yn) {
            self._deleteFileArray(fileEntries, ok, err);
          } else {
            cancel();
          }
        });
      } else if (self.getLogSelection()) {
        var logName = self.getLogSelection();
        self._fsa.getFile(self.constructor.LOG_DIR + "/" + logName, function(
            fileEntry) {
          var yn = confirm(chrome.i18n.getMessage("logs_confirmDeleteFiles",
              [ 1 ]));
          if (yn) {
            self._deleteFileArray( [ fileEntry ], ok, err);
          } else {
            cancel();
          }
        }, err);
      } else {
        alert(chrome.i18n.getMessage("log_noLogSelected"));
      }
    });
  };
  Evernote.ChromeLogViewer.prototype._deleteFileArray = function(fileArray,
      success, error) {
    var ok = function() {
      if (typeof success == 'function') {
        success();
      }
    };
    var err = function(e) {
      if (typeof error == 'function') {
        error(e);
      }
    };
    var remover = function(fArray, callback, index) {
      index = (index) ? index : 0;
      if (index >= fArray.length) {
        if (typeof callback == 'function') {
          callback();
        }
        return;
      }
      fArray[index].remove(function() {
        chrome.extension.sendRequest(
            new Evernote.RequestMessage(
                Evernote.Constants.RequestType.LOG_FILE_REMOVED,
                fArray[index].name), function() {
              remover(fArray, callback, ++index);
            });
      }, err);
    };
    remover(fileArray, success);
  };
  Evernote.ChromeLogViewer.prototype.monitorLogViewer = function() {
    var self = this;
    var refreshRate = this.getRefreshRateValue();
    if (!this._logViewerMonitor && refreshRate >= 1000) {
      this._logViewerMonitor = setInterval(function() {
        var viewer = self.getLogViewer();
        if (viewer && viewer.data() && viewer.data().logName) {
          self.viewLog(viewer.data().logName);
        }
      }, refreshRate);
    } else if (refreshRate < 1000) {
      this.stopLogMonitor();
    }
  };
  Evernote.ChromeLogViewer.prototype.stopLogMonitor = function() {
    if (this._logViewerMonitor) {
      clearInterval(this._logViewerMonitor);
      this._logViewerMonitor = null;
    }
  };
  Evernote.ChromeLogViewer.prototype.getRefreshRateValue = function() {
    var refreshRate = this.getRefreshRate();
    var val = 0;
    if (refreshRate.val()) {
      val = parseInt(refreshRate.val());
      if (isNaN(val)) {
        val = 0;
      }
    }
    return val;
  };
  Evernote.ChromeLogViewer.prototype._getExportHeader = function() {
    var str = "";
    str += "Navigator: " + navigator.userAgent + "\n";
    str += "Id: "
        + ((this._extensionInfo) ? this._extensionInfo.id : "undefined") + "\n";
    str += "Version: "
        + ((this._extensionInfo) ? this._extensionInfo.version : "undefined")
        + "\n";
    str += "Export date: " + new Date().toString() + "\n";
    str += "\n";
    return str;
  };
  Evernote.ChromeLogViewer.prototype.exportLogFiles = function() {
    var self = this;
    var spinner = this.getSpinner();
    var ok = function() {
      self._sema.signal();
      spinner.hide();
      self.setAllSelected(false);
    };
    var err = function(e) {
      self._sema.signal();
      alert("Error exporting log files: " + (e && e.code) ? e.code : e);
    };
    spinner.show();
    this._sema.critical(function() {
      if (self.isAllSelected()) {
        self._fsa.listFiles(self.constructor.LOG_DIR, function(files) {
          Evernote.FSA.sortEntries(files, function(f, cb) {
            f.getMetadata(function(meta) {
              cb(meta.modificationTime.getTime(), f);
            });
          }, function(a, b, fileArray, fileMap) {
            if (a == b) {
              return 0;
            } else if (a > b) {
              return -1;
            } else {
              return 1;
            }
          }, function(filesArray) {
            self._exportFileArray(filesArray, ok, err);
          });
        }, err);
      } else if (self.getLogSelection()) {
        var fname = self.getLogSelection();
        self._fsa.getFile(self.constructor.LOG_DIR + "/" + fname, function(
            fileEntry) {
          self._exportFileArray( [ fileEntry ], ok, err);
        }, err);
      } else {
        alert(chrome.i18n.getMessage("log_noLogSelected"));
      }
    });
  };
  Evernote.ChromeLogViewer.prototype._exportFileArray = function(fileArray,
      success, error) {
    var self = this;
    var header = this._getExportHeader();
    var zip = new JSZip("DEFLATE");
    var ok = function() {
      if (typeof success == 'function') {
        success();
      }
    };
    var err = function(e) {
      if (typeof error == 'function') {
        error(e);
      }
    };
    var cat = function(fArray, callback, index) {
      index = (index) ? index : 0;
      if (index >= fArray.length) {
        if (typeof callback == 'function') {
          callback();
        }
      } else {
        fArray[index].file(function(file) {
          var reader = new FileReader();
          reader.onerror = err;
          reader.onloadend = function() {
            zip.add(file.name, header + reader.result);
            cat(fArray, callback, ++index);
          };
          reader.readAsText(file);
        }, err);
      }
    };
    cat(fileArray, function() {
      content = zip.generate();
      ok();
      location.href = "data:application/zip;base64," + content;
    });
  };
  Evernote.ChromeLogViewer.prototype.scrollToBottom = function() {
    window.scrollTo(0, document.body.getBoundingClientRect().height);
  };
  Evernote.ChromeLogViewer.prototype.getLogSelector = function() {
    return $("#logSelector");
  };
  Evernote.ChromeLogViewer.prototype.getLogViewer = function() {
    return $("#logViewer");
  };
  Evernote.ChromeLogViewer.prototype.getSpinner = function() {
    return $("#spinner");
  };
  Evernote.ChromeLogViewer.prototype.getFollow = function() {
    return $("#logFollow");
  };
  Evernote.ChromeLogViewer.prototype.isFollowing = function() {
    return (this.getFollow().attr("checked")) ? true : false;
  };
  Evernote.ChromeLogViewer.prototype.getRefreshRate = function() {
    return $("#logRefreshRate");
  };
  Evernote.ChromeLogViewer.prototype.getDeleter = function() {
    return $("#logDelete");
  };
  Evernote.ChromeLogViewer.prototype.getExporter = function() {
    return $("#logExport");
  };
  Evernote.ChromeLogViewer.prototype.getAllSelector = function() {
    return $("#logAll");
  };
  Evernote.ChromeLogViewer.prototype.isAllSelected = function() {
    return (this.getAllSelector().attr("checked")) ? true : false;
  };
  Evernote.ChromeLogViewer.prototype.setAllSelected = function(bool) {
    if (bool) {
      this.getAllSelector().attr("checked", "checked");
    } else {
      this.getAllSelector().removeAttr("checked");
    }
  };
})();

(function() {
  var LOG = null;
  Evernote.ChromeUploadNotifier = function ChromeUploadNotifier() {
    LOG = Evernote.chromeExtension.logger;
    this.__defineGetter__("payloadGuid", this.getPayloadGuid);
    this.initialize();
  };
  Evernote.ChromeUploadNotifier.prototype._payloadGuid = null;
  Evernote.ChromeUploadNotifier.prototype.initialize = function() {
    var postData = Evernote.Utils.getPostData();
    if (typeof postData == 'object' && postData && postData.payload) {
      this._payloadGuid = postData.payload;
    }
    if (this._payloadGuid) {
      this.requestPayload();
    } else {
      this.showUnknownError();
    }
  };
  Evernote.ChromeUploadNotifier.prototype.setHeadline = function(str) {
    this.getNotificationHeadline().html(str);
  };
  Evernote.ChromeUploadNotifier.prototype.setDetails = function(str) {
    this.getNotificationDetails().html(str);
  };
  Evernote.ChromeUploadNotifier.prototype.requestPayload = function() {
    var self = this;
    var req = new Evernote.RequestMessage(
        Evernote.Constants.RequestType.GET_MANAGED_PAYLOAD, this.payloadGuid);
    Evernote.Utils.notifyExtension(req, function(payload) {
      LOG.debug("Handling Response callback after requesting managed payload");
      if (payload && payload.data) {
        payload.data = new Evernote.ClipNote(payload.data);
      }
      if (payload && payload.processResponse
          && payload.processResponse.response) {
        payload.processResponse.response = Evernote.EDAMResponse
            .fromObject(payload.processResponse.response);
      }
      self.payload = payload;
      self.notifyWithPayload(payload);
    });
  };
  Evernote.ChromeUploadNotifier.prototype.notifyWithPayload = function(payload) {
    LOG.debug("ChromeUploadNotifier.notifyWithPayload");
    var clipProcessor = Evernote.chromeExtension.clipProcessor;
    var clip = (payload && payload.data) ? payload.data : null;
    var error = chrome.i18n.getMessage("EDAMResponseError_1");
    if (payload && clip) {
      if (clipProcessor.isPayloadProcessed(payload)) {
        this.showClipSuccess(clip);
        return;
      } else if (payload.processResponse && payload.processResponse.response) {
        var response = Evernote.EDAMResponse
            .fromObject(payload.processResponse.response);
        if (response.hasAuthenticationError()) {
          LOG.debug("Response has authentication error");
          this.showAuthenticationError(clip);
          return;
        } else if (response.isError()) {
          LOG.debug("Response has errors");
          var responseErrors = response.getErrors();
          if (LOG.isDebugEnabled()) {
            LOG.dir(responseErrors);
          }
          var firstError = Evernote.EvernoteError.fromObject(responseErrors[0]);
          error = Evernote.Utils.extractErrorMessage(firstError, error);
          this.showClipError(clip, error);
          return;
        }
      } else if (payload && payload.data && payload.data.sizeExceeded) {
        error = chrome.i18n.getMessage("pageClipTooBig");
        this.showClipError(clip, error);
        return;
      } else if (payload.processResponse
          && (clipProcessor._isResponseHTTPAbortError(payload.processResponse) || clipProcessor
              ._isResponseHTTPRetryError(payload.processResponse))) {
        error = Evernote.Utils.extractHttpErrorMessage(
            payload.processResponse.xhr, payload.processResponse.textStatus,
            payload.processResponse.error);
        this.showClipError(clip, error);
        return;
      }
    }
    this.showUnknownError();
  };
  Evernote.ChromeUploadNotifier.prototype.showClipSuccess = function(clip) {
    this.clear();
    var _title = (clip && clip.title) ? clip.title : "";
    this.setHeadline(chrome.i18n.getMessage("desktopNotification_clipUploaded",
        [ _title ]));
    this.setDetails(chrome.i18n
        .getMessage("desktopNotification_clipUploadedMessage"));
    this.showSuccessActions(clip, true, true);
  };
  Evernote.ChromeUploadNotifier.prototype.showAuthenticationError = function(
      clip) {
    this.clear();
    this.setHeadline(chrome.i18n.getMessage(
        "desktopNotification_clipProcessorSignInTitle",
        [ ((clip && clip.title) ? clip.title : "") ]));
    this.setDetails(chrome.i18n
        .getMessage("desktopNotification_clipProcessorSignInMessage"));
    this.showErrorActions(clip, true, false, true);
  };
  Evernote.ChromeUploadNotifier.prototype.showUnknownError = function() {
    this.clear();
    this.setHeadline(chrome.i18n
        .getMessage("desktopNotification_unableToSaveClipUnknown"));
    this.setDetails(chrome.i18n
        .getMessage("desktopNotification_unableToSaveClipUnknownMessage"));
  };
  Evernote.ChromeUploadNotifier.prototype.showClipError = function(clip, error) {
    LOG.debug("ChromeUploadNotifier.showError");
    var self = this;
    this.clear();
    this.setHeadline(chrome.i18n.getMessage(
        "desktopNotification_unableToSaveClip",
        [ ((clip && clip.title) ? clip.title : "") ]));
    this.setDetails(error);
    this.showErrorActions(clip, true, true, true);
  };
  Evernote.ChromeUploadNotifier.prototype.showSuccessActions = function(clip,
      showView, showEdit) {
    var self = this;
    var actions = this.getNotificationActions();
    if (showView) {
      var viewAction = $("<a href='javascript:'></a>");
      viewAction.text(chrome.i18n
          .getMessage("desktopNotification_viewSuccessClip"));
      viewAction.bind("click", function() {
        Evernote.Utils.notifyExtension(new Evernote.RequestMessage(
            Evernote.Constants.RequestType.VIEW_MANAGED_PAYLOAD_DATA,
            self.payloadGuid));
      });
      actions.append(viewAction);
    }
    if (showEdit) {
      var editAction = $("<a href='javascript:'></a>");
      editAction.text(chrome.i18n
          .getMessage("desktopNotification_editSuccessClip"));
      editAction.bind("click", function() {
        Evernote.Utils.notifyExtension(new Evernote.RequestMessage(
            Evernote.Constants.RequestType.EDIT_MANAGED_PAYLOAD_DATA,
            self.payloadGuid));
      });
      actions.append(editAction);
    }
  };
  Evernote.ChromeUploadNotifier.prototype.showErrorActions = function(clip,
      showView, showRetry, showCancel) {
    var self = this;
    var actions = this.getNotificationActions();
    if (showView) {
      var viewAction = $("<a href='javascript:'></a>");
      viewAction.text(chrome.i18n
          .getMessage("desktopNotification_viewFailedClip"));
      viewAction.bind("click", function() {
        Evernote.Utils.notifyExtension(new Evernote.RequestMessage(
            Evernote.Constants.RequestType.REVISIT_MANAGED_PAYLOAD,
            self.payloadGuid));
      });
      actions.append(viewAction);
    }
    if (showRetry) {
      var retryAction = $("<a href='javascript:'></a>");
      retryAction.text(chrome.i18n
          .getMessage("desktopNotification_retryFailedClip"));
      retryAction.bind("click", function() {
        Evernote.Utils.notifyExtension(new Evernote.RequestMessage(
            Evernote.Constants.RequestType.RETRY_MANAGED_PAYLOAD,
            self.payloadGuid));
      });
      actions.append(retryAction);
    }
    if (showCancel) {
      var cancelAction = $("<a href='javascript:'></a>");
      cancelAction.text(chrome.i18n
          .getMessage("desktopNotification_cancelFailedClip"));
      cancelAction.bind("click", function() {
        Evernote.Utils.notifyExtension(new Evernote.RequestMessage(
            Evernote.Constants.RequestType.CANCEL_MANAGED_PAYLOAD,
            self.payloadGuid));
      });
      actions.append(cancelAction);
    }
  };
  Evernote.ChromeUploadNotifier.prototype.clear = function() {
    this.getNotificationHeadline().empty();
    this.getNotificationDetails().empty();
    this.getNotificationActions().empty();
  };
  Evernote.ChromeUploadNotifier.prototype.getPayloadGuid = function() {
    return this._payloadGuid;
  };
  Evernote.ChromeUploadNotifier.prototype.getNotificationHeadline = function() {
    return $("#notificationHeadline");
  };
  Evernote.ChromeUploadNotifier.prototype.getNotificationDetails = function() {
    return $("#notificationDetails");
  };
  Evernote.ChromeUploadNotifier.prototype.getNotificationActions = function() {
    return $("#notificationActions");
  };
})();

/*
 * Evernote.AppState
 * Evernote
 *
 * Created by Pavel Skaldin on 4/4/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.AppState = function AppState(obj) {
  this.__defineGetter__("fullPage", this.isFullPage);
  this.__defineSetter__("fullPage", this.setFullPage);
  this.__defineGetter__("noteList", this.isNoteList);
  this.__defineSetter__("noteList", this.setNoteList);
  this.__defineGetter__("notebookGuid", this.getNotebookGuid);
  this.__defineSetter__("notebookGuid", this.setNotebookGuid);
  this.__defineGetter__("noteListScrollTop", this.getNoteListScrollTop);
  this.__defineSetter__("noteListScrollTop", this.setNoteListScrollTop);
  this.__defineGetter__("notifyChanges", this.isNotifyChanges);
  this.__defineSetter__("notifyChanges", this.setNotifyChanges);
  this.initialize(obj);
};

Evernote.AppState.CHANGE_EVENT_NAME = "appStateChanged";
Evernote.AppState.DEFAULTS = {
  fullPage : false,
  noteList : false,
  notifyChanges : true,
  notebookGuid : null,
  noteListScrollTop : 0
};

// whether the user specified to clip entire page rather than making a link note
Evernote.AppState.prototype._fullPage = Evernote.AppState.DEFAULTS.fullPage;
// whether the user was browsing the note list rather than clipping
Evernote.AppState.prototype._noteList = Evernote.AppState.DEFAULTS.noteList;
// last selected notebook guid
Evernote.AppState.prototype._notebookGuid = Evernote.AppState.DEFAULTS.notebookGuid;
// whether to trigger event on window object when changes occur
Evernote.AppState.prototype._noteListScrollTop = Evernote.AppState.DEFAULTS.noteListScrollTop;
Evernote.AppState.prototype._notifyChanges = Evernote.AppState.DEFAULTS.notifyChanges;

Evernote.AppState.prototype.initialize = function(obj) {
  // track what the preferred setting for change notification is
  // and disable notifications while initializing... (since this method can be
  // called by other than constructor)
  var prefNotifyChanges = this.notifyChanges;
  this.notifyChanges = false;
  if (typeof obj == 'object' && obj != null) {
    for ( var i in obj) {
      if (i == "notifyChanges") {
        prefNotifyChanges = obj[i];
      } else if (typeof this[i] != 'undefined') {
        this[i] = obj[i];
      }
    }
  }
  // restore preferred setting for change notification
  this.notifyChanges = prefNotifyChanges;
};
Evernote.AppState.prototype.setFullPage = function(bool) {
  var val = (bool) ? true : false;
  if (this._fullPage != val) {
    this._fullPage = val;
    this.notifyChange();
  }
};
Evernote.AppState.prototype.isFullPage = function() {
  return this._fullPage;
};
Evernote.AppState.prototype.setNoteList = function(bool) {
  var val = (bool) ? true : false;
  if (this._noteList != val) {
    this._noteList = val;
    this.notifyChange();
  }
};
Evernote.AppState.prototype.isNoteList = function() {
  return this._noteList;
};
Evernote.AppState.prototype.setNotebookGuid = function(guid) {
  if (typeof guid == 'string' && guid.length > 0 && this._notebookGuid != guid) {
    this._notebookGuid = guid;
    this.notifyChange();
  } else if (guid == null && this._notebookGuid != null) {
    this._notebookGuid = null;
    this.notifyChange();
  }
};
Evernote.AppState.prototype.getNotebookGuid = function() {
  return this._notebookGuid;
};
Evernote.AppState.prototype.setNoteListScrollTop = function(num) {
  if (typeof num == 'number' && this._noteListScrollTop != num) {
    this._noteListScrollTop = num;
    this.notifyChange();
  } else if (num == null
      && this._noteListScrollTop != Evernote.AppState.DEFAULTS.noteListScrollTop) {
    this._noteListScrollTop = Evernote.AppState.DEFAULTS.noteListScrollTop;
    this.notifyChange();
  }
};
Evernote.AppState.prototype.getNoteListScrollTop = function() {
  return this._noteListScrollTop;
};
Evernote.AppState.prototype.setNotifyChanges = function(bool) {
  this._notifyChanges = (bool) ? true : false;
};
Evernote.AppState.prototype.isNotifyChanges = function() {
  return this._notifyChanges;
};

/** ************** Event handling *************** */
Evernote.AppState.prototype.notifyChange = function() {
  if (this.notifyChanges && window) {
    $(window).trigger(Evernote.AppState.CHANGE_EVENT_NAME, [ this ]);
  }
};

/** ************** Conversion *************** */
Evernote.AppState.prototype.toJSON = function() {
  return {
    fullPage : this.fullPage,
    noteList : this.noteList,
    notebookGuid : this.notebookGuid,
    noteListScrollTop : this.noteListScrollTop
  };
};

/*
 * Evernote.ClipNote
 * Evernote
 *
 * Created by Pavel Skaldin on 3/1/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
/**
 * ClipNote represents a note that's clipped from a web page.
 */
Evernote.ClipNote = function ClipNote(obj) {
  this.__defineBoolean__("fullPage", false);
  this.__defineString__("mailTo");
  this.__defineString__("mailComment");
  this.__defineBoolean__("saveUrl", true);
  this.__defineString__("tagNames");
  this.__defineString__("url");
  this.__defineGetter__("length", this.getLength);
  this.initialize(obj);
};
Evernote.ClipNote.javaClass = "com.evernote.web.ClipNote";
Evernote.inherit(Evernote.ClipNote, Evernote.BasicNote);

// Returns total length of the instance as it would be POSTed
Evernote.ClipNote.prototype.getLength = function() {
  var total = 0;
  var props = this.getStorableProps();
  for ( var i = 0; i < props.length; i++) {
    if (this[props[i]]) {
      total += ("" + this[props[i]]).length + props[i].length + 1;
    }
  }
  total += (props.length - 1);
  return total;
};
Evernote.ClipNote.prototype.getStorableProps = function() {
  var basicStorable = Evernote.ClipNote.parent.getStorableProps.apply(this);
  return basicStorable.concat( [ "fullPage", "mailTo", "mailComment",
      "saveUrl", "tagNames", "url" ]);
};
Evernote.ClipNote.prototype.toLOG = function() {
  var logObj = Evernote.ClipNote.parent.toLOG.apply(this);
  logObj["fullPage"] = this.fullPage;
  logObj["mailTo"] = this.mailTo;
  logObj["mailCommentLength"] = (this.mailComment) ? this.mailComment.length : 0;
  logObj["saveUrl"] = this.saveUrl;
  logObj["tagNames"] = this.tagNames;
  logObj["url"] = this.url;
  logObj["length"] = this.length;
  return logObj;
};
Evernote.ClipNote.prototype.toString = function() {
  return "Evernote.ClipNote [" + this.url + "] " + this.title + " (fullPage: "
      + this.fullPage + "; saveUrl: " + this.saveUrl + "; notebookGuid: "
      + this.notebookGuid + "; tagNames: " + this.tagNames
      + "; content length: "
      + ((typeof this.content == 'string') ? this.content.length : 0)
      + "; comment length: "
      + ((typeof this.comment == 'string') ? this.comment.length : 0) + ")";
};

/*
 * Evernote.Options
 * Evernote
 *
 * Created by Pavel Skaldin on 4/1/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
(function() {
  var LOG = null;
  Evernote.Options = function Options(context, opts) {
    LOG = Evernote.chromeExtension.logger;
    this.__defineGetter__("context", this.getContext);
    this.__defineSetter__("context", this.setContext);
    this.__defineGetter__("developerMode", this.isDeveloperMode);
    this.__defineSetter__("developerMode", this.setDeveloperMode);
    this.__defineGetter__("debugLevel", this.getDebugLevel);
    this.__defineSetter__("debugLevel", this.setDebugLevel);
    this.__defineGetter__("insecureProto", this.getInsecureProto);
    this.__defineSetter__("insecureProto", this.setInsecureProto);
    this.__defineGetter__("secureProto", this.getSecureProto);
    this.__defineSetter__("secureProto", this.setSecureProto);
    this.__defineGetter__("serviceDomain", this.getServiceDomain);
    this.__defineSetter__("serviceDomain", this.setServiceDomain);
    this.__defineGetter__("noteSortOrder", this.getNoteSortOrder);
    this.__defineSetter__("noteSortOrder", this.setNoteSortOrder);
    this.__defineGetter__("fullPage", this.getFullPage);
    this.__defineSetter__("fullPage", this.setFullPage);
    this.__defineGetter__("noteList", this.getNoteList);
    this.__defineSetter__("noteList", this.setNoteList);
    this.__defineGetter__("clipNotebook", this.getClipNotebook);
    this.__defineSetter__("clipNotebook", this.setClipNotebook);
    this.__defineGetter__("clipNotebookGuid", this.getClipNotebookGuid);
    this.__defineSetter__("clipNotebookGuid", this.setClipNotebookGuid);
    this.__defineGetter__("autoSaveClipNote", this.getAutoSaveClipNote);
    this.__defineSetter__("autoSaveClipNote", this.setAutoSaveClipNote);
    this.__defineGetter__("clipStyle", this.getClipStyle);
    this.__defineSetter__("clipStyle", this.setClipStyle);
    this.__defineGetter__("useContextMenu", this.isUseContextMenu);
    this.__defineSetter__("useContextMenu", this.setUseContextMenu);
    this.__defineGetter__("useSearchHelper", this.isUseSearchHelper);
    this.__defineSetter__("useSearchHelper", this.setUseSearchHelper);
    this.__defineGetter__("useLinkHilites", this.isUseLinkHilites);
    this.__defineSetter__("useLinkHilites", this.setUseLinkHilites);
    this.__defineGetter__("username", this.getUsername);
    this.__defineSetter__("username", this.setUsername);
    this.__defineGetter__("password", this.getPassword);
    this.__defineSetter__("password", this.setPassword);
    this.__defineGetter__("debugEnabled", this.isDebugEnabled);
    this.__defineSetter__("debugEnabled", this.setDebugEnabled);
    this.__defineGetter__("keepLogs", this.getKeepLogs);
    this.__defineSetter__("keepLogs", this.setKeepLogs);
    this.initialize(context, opts);
  };

  Evernote.Options.FULL_PAGE_OPTIONS = {
    NEVER : 0,
    ALWAYS : 1,
    REMEMBER : 2
  };
  Evernote.Options.NOTE_LIST_OPTIONS = {
    NEVER : 0,
    ALWAYS : 1,
    REMEMBER : 2
  };
  Evernote.Options.CLIP_NOTEBOOK_OPTIONS = {
    DEFAULT : 0,
    SELECT : 1,
    REMEMBER : 2
  };
  Evernote.Options.AUTO_SAVE_CLIPNOTE_OPTIONS = {
    NEVER : 0,
    ALWAYS : 1
  };
  Evernote.Options.CLIP_STYLE_OPTIONS = {
    NONE : 0,
    TEXT : 1,
    FULL : 2
  };

  Evernote.Options.__defineGetter__("DEFAULTS", function() {
    return {
      debugLevel : (LOG) ? LOG.level : Evernote.chromeExtension.logger.level,
      insecureProto : Evernote.EvernoteContext.INSECURE_PROTO,
      secureProto : Evernote.EvernoteContext.SECURE_PROTO,
      serviceDomain : Evernote.EvernoteContext.SERVICE_DOMAIN,
      noteSortOrder : new Evernote.NoteSortOrder(),
      fullPage : Evernote.Options.FULL_PAGE_OPTIONS.REMEMBER,
      noteList : Evernote.Options.NOTE_LIST_OPTIONS.REMEMBER,
      clipNotebook : Evernote.Options.CLIP_NOTEBOOK_OPTIONS.REMEMBER,
      clipNotebookGuid : null,
      autoSaveClipNote : Evernote.Options.AUTO_SAVE_CLIPNOTE_OPTIONS.ALWAYS,
      clipStyle : Evernote.Options.CLIP_STYLE_OPTIONS.FULL,
      useContextMenu : true,
      useSearchHelper : false,
      useLinkHilites : false,
      debugEnabled : false,
      keepLogs : 3
    };
  });

  Evernote.Options.isValidFullPageOptionValue = function(value) {
    return Evernote.Options.isValidOptionValue(value,
        Evernote.Options.FULL_PAGE_OPTIONS);
  };

  Evernote.Options.isValidNoteListOptionValue = function(value) {
    return Evernote.Options.isValidOptionValue(value,
        Evernote.Options.NOTE_LIST_OPTIONS);
  };

  Evernote.Options.isValidClipNotebookOptionValue = function(value) {
    return Evernote.Options.isValidOptionValue(value,
        Evernote.Options.CLIP_NOTEBOOK_OPTIONS);
  };

  Evernote.Options.isValidAutoSaveClipNoteOptionValue = function(value) {
    return Evernote.Options.isValidOptionValue(value,
        Evernote.Options.AUTO_SAVE_CLIPNOTE_OPTIONS);
  };

  Evernote.Options.isValidClipStyleOptionValue = function(value) {
    return Evernote.Options.isValidOptionValue(value,
        Evernote.Options.CLIP_STYLE_OPTIONS);
  };

  Evernote.Options.isValidOptionValue = function(value, allOptions) {
    if (typeof allOptions == 'object' && allOptions != null) {
      for ( var i in allOptions) {
        if (value == allOptions[i]) {
          return true;
        }
      }
    }
    return false;
  };

  Evernote.Options.prototype._context = null;
  Evernote.Options.prototype._developerMode = false;
  Evernote.Options.prototype._debugLevel = Evernote.Options.DEFAULTS.debugLevel;
  Evernote.Options.prototype._insecureProto = Evernote.Options.DEFAULTS.insecureProto;
  Evernote.Options.prototype._secureProto = Evernote.Options.DEFAULTS.secureProto;
  Evernote.Options.prototype._serviceDomain = Evernote.Options.DEFAULTS.serviceDomain;
  Evernote.Options.prototype._noteSortOrder = Evernote.Options.DEFAULTS.noteSortOrder;
  Evernote.Options.prototype._fullPage = Evernote.Options.DEFAULTS.fullPage;
  Evernote.Options.prototype._noteList = Evernote.Options.DEFAULTS.noteList;
  Evernote.Options.prototype._clipNotebook = Evernote.Options.DEFAULTS.clipNotebook;
  Evernote.Options.prototype._clipNotebookGuid = Evernote.Options.DEFAULTS.clipNotebookGuid;
  Evernote.Options.prototype._autoSaveClipNote = Evernote.Options.DEFAULTS.autoSaveClipNote;
  Evernote.Options.prototype._clipStyle = Evernote.Options.DEFAULTS.clipStyle;
  Evernote.Options.prototype._useContextMenu = Evernote.Options.DEFAULTS.useContextMenu;
  Evernote.Options.prototype._useSearchHelper = Evernote.Options.DEFAULTS.useSearchHelper;
  Evernote.Options.prototype._useLinkHilites = Evernote.Options.DEFAULTS.useLinkHilites;
  Evernote.Options.prototype._username = null;
  Evernote.Options.prototype._password = null;
  Evernote.Options.prototype._debugEnabled = Evernote.Options.DEFAULTS.debugEnabled;
  Evernote.Options.prototype._keepLogs = Evernote.Options.DEFAULTS.keepLogs;

  Evernote.Options.prototype.initialize = function(context, options) {
    if (context instanceof Evernote.EvernoteContext) {
      this.context = context;
    }
    var opts = (typeof options == 'object' && options != null) ? options
        : Evernote.Options.DEFAULTS;
    for ( var i in opts) {
      if (typeof this[i] != 'undefined') {
        this[i] = opts[i];
      }
    }
  };
  Evernote.Options.prototype.setContext = function(context) {
    if (context instanceof Evernote.EvernoteContext) {
      this._context = context;
    } else if (context == null) {
      this._context = null;
    }
  };
  Evernote.Options.prototype.getContext = function() {
    return this._context;
  };
  Evernote.Options.prototype.setDeveloperMode = function(bool) {
    this._developerMode = (bool) ? true : false;
  };
  Evernote.Options.prototype.isDeveloperMode = function() {
    return this._developerMode;
  };
  Evernote.Options.prototype.setDebugLevel = function(level) {
    if (typeof level == 'number') {
      this._debugLevel = level;
    } else if (typeof level == 'string') {
      this._debugLevel = parseInt(level);
    } else if (level == null) {
      this._debugLevel = 0;
    }
  };
  Evernote.Options.prototype.getDebugLevel = function() {
    return this._debugLevel;
  };
  Evernote.Options.prototype.setInsecureProto = function(proto) {
    if (typeof proto == 'string')
      this._insecureProto = proto;
    else if (proto == null)
      this._insecureProto = null;
  };
  Evernote.Options.prototype.getInsecureProto = function() {
    return this._insecureProto;
  };
  Evernote.Options.prototype.setSecureProto = function(proto) {
    if (typeof proto == 'string')
      this._secureProto = proto;
    else if (proto == null)
      this._secureProto = null;
  };
  Evernote.Options.prototype.getSecureProto = function() {
    return this._secureProto;
  };
  Evernote.Options.prototype.setServiceDomain = function(host) {
    if (typeof host == 'string')
      this._serviceDomain = host;
    else if (host == null)
      this._serviceDomain = null;
  };
  Evernote.Options.prototype.getServiceDomain = function() {
    return this._serviceDomain;
  };
  Evernote.Options.prototype.setNoteSortOrder = function(noteSortOrder) {
    if (noteSortOrder instanceof Evernote.NoteSortOrder) {
      this._noteSortOrder = noteSortOrder;
    } else if (typeof noteSortOrder == 'object' && noteSortOrder != null) {
      this._noteSortOrder = new Evernote.NoteSortOrder(noteSortOrder);
    } else if (noteSortOrder == null) {
      this._noteSortOrder = null;
    }
  };
  Evernote.Options.prototype.getNoteSortOrder = function() {
    return this._noteSortOrder;
  };
  Evernote.Options.prototype.setFullPage = function(val) {
    if (Evernote.Options.isValidFullPageOptionValue(val)) {
      this._fullPage = val;
    } else if (val == null) {
      this._fullPage = Evernote.Options.DEFAULTS.fullPage;
    }
  };
  Evernote.Options.prototype.getFullPage = function() {
    return this._fullPage;
  };
  Evernote.Options.prototype.setNoteList = function(val) {
    if (Evernote.Options.isValidNoteListOptionValue(val)) {
      this._noteList = val;
    } else if (val == null) {
      this._noteList = Evernote.Options.DEFAULTS.noteList;
    }
  };
  Evernote.Options.prototype.getNoteList = function() {
    return this._noteList;
  };
  Evernote.Options.prototype.setClipNotebook = function(val) {
    if (Evernote.Options.isValidClipNotebookOptionValue(val)) {
      this._clipNotebook = val;
    } else if (val == null) {
      this._clipNotebook = Evernote.Options.DEFAULTS.clipNotebook;
    }
  };
  Evernote.Options.prototype.getClipNotebook = function() {
    return this._clipNotebook;
  };
  Evernote.Options.prototype.setClipNotebookGuid = function(guid) {
    if (typeof guid == 'string' && guid.length > 0) {
      this._clipNotebookGuid = guid;
    } else if (guid instanceof Evernote.Notebook) {
      this._clipNotebookGuid = guid.guid;
    } else if (guid == null) {
      this._clipNotebookGuid = null;
    }
  };
  Evernote.Options.prototype.getClipNotebookGuid = function() {
    return this._clipNotebookGuid;
  };
  Evernote.Options.prototype.setAutoSaveClipNote = function(val) {
    if (Evernote.Options.isValidAutoSaveClipNoteOptionValue(val)) {
      this._autoSaveClipNote = val;
    } else if (val == null) {
      this._autoSaveClipNote = Evernote.Options.DEFAULTS.autoSaveClipNote;
    }
  };
  Evernote.Options.prototype.getAutoSaveClipNote = function() {
    return this._autoSaveClipNote;
  };
  Evernote.Options.prototype.setClipStyle = function(val) {
    if (Evernote.Options.isValidClipStyleOptionValue(val)) {
      this._clipStyle = val;
    } else if (val == null) {
      this._clipStyle = Evernote.Options.DEFAULTS.clipStyle;
    }
  };
  Evernote.Options.prototype.getClipStyle = function() {
    return this._clipStyle;
  };
  Evernote.Options.prototype.isUseContextMenu = function() {
    return this._useContextMenu;
  };
  Evernote.Options.prototype.setUseContextMenu = function(bool) {
    this._useContextMenu = (bool) ? true : false;
  };
  Evernote.Options.prototype.isUseSearchHelper = function() {
    return this._useSearchHelper;
  };
  Evernote.Options.prototype.setUseSearchHelper = function(bool) {
    this._useSearchHelper = (bool) ? true : false;
  };
  Evernote.Options.prototype.setUseLinkHilites = function(bool) {
    this._useLinkHilites = (bool) ? true : false;
  };
  Evernote.Options.prototype.isUseLinkHilites = function() {
    return this._useLinkHilites;
  };
  Evernote.Options.prototype.getUsername = function() {
    if (!this._username) {
      var user = Evernote.getContext().getUser();
      if (user) {
        this._username = user.username;
      }
    }
    return this._username;
  };
  Evernote.Options.prototype.setUsername = function(username) {
    this._username = username;
  };
  Evernote.Options.prototype.getPassword = function() {
    return this._password;
  };
  Evernote.Options.prototype.setPassword = function(password) {
    this._password = password;
  };
  Evernote.Options.prototype.isDebugEnabled = function() {
    return this._debugEnabled;
  };
  Evernote.Options.prototype.setDebugEnabled = function(bool) {
    this._debugEnabled = (bool) ? true : false;
  };
  Evernote.Options.prototype.getKeepLogs = function() {
    return this._keepLogs;
  };
  Evernote.Options.prototype.setKeepLogs = function(num) {
    this._keepLogs = parseInt(num);
    if (isNaN(this._keepLogs) || num < 0) {
      this._keepLogs = 0;
    }
  };

  Evernote.Options.prototype.apply = function() {
    LOG.level = this.debugLevel;
    Evernote.Logger.setLevel(this.debugLevel);
    if (this.context) {
      this.context.setOptions(this);
      this.context.secureProto = this.secureProto;
      this.context.insecureProto = this.insecureProto;
      this.context.serviceDomain = this.serviceDomain;
    }
  };
  Evernote.Options.prototype.resetCredentials = function() {
    this.username = null;
    this.password = null;
  };
  Evernote.Options.prototype.reset = function() {
    this.initialize(this.context, null);
  };

  Evernote.Options.prototype.toJSON = function() {
    return {
      debugLevel : this.debugLevel,
      developerMode : this.developerMode,
      insecureProto : this.insecureProto,
      secureProto : this.secureProto,
      serviceDomain : this.serviceDomain,
      noteSortOrder : this.noteSortOrder,
      fullPage : this.fullPage,
      noteList : this.noteList,
      clipNotebook : this.clipNotebook,
      clipNotebookGuid : this.clipNotebookGuid,
      autoSaveClipNote : this.autoSaveClipNote,
      clipStyle : this.clipStyle,
      useContextMenu : this.useContextMenu,
      useSearchHelper : this.useSearchHelper,
      useLinkHilites : this.useLinkHilites,
      username : this.username,
      password : this.password,
      debugEnabled : this.debugEnabled,
      keepLogs : this.keepLogs
    };
  };
})();

/*
 * Evernote.MailNote
 * Evernote
 *
 * Created by Pavel Skaldin on 3/1/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.MailNote = function MailNote(obj) {
  this.__defineGetter__("mailTo", this.getMailTo);
  this.__defineSetter__("mailTo", this.setMailTo);
  this.__defineGetter__("mailComment", this.getMailComment);
  this.__defineSetter__("mailComment", this.setMailComment);
  this.initialize(obj);
};
Evernote.MailNote.javaClass = "com.evernote.web.MailNote";
Evernote.inherit(Evernote.MailNote, Evernote.Note, true);

Evernote.MailNote.prototype._mailTo = null;
Evernote.MailNote.prototype._mailComment = null;
Evernote.MailNote.prototype.getMailTo = function() {
  return this._mailTo;
};
Evernote.MailNote.prototype.setMailTo = function(str) {
  if (typeof str == 'string')
    this._mailTo = $.trim(str);
  else if (str == null)
    this._mailTo = null;
};
Evernote.MailNote.prototype.getMailComment = function() {
  return this._mailComment;
};
Evernote.MailNote.prototype.setMailComment = function(str) {
  if (typeof str == 'string')
    this._mailComment = $.trim(str);
  else if (str == null)
    this._mailComment = null;
};
Evernote.MailNote.prototype.getStorableProps = function() {
  var props = Evernote.MailNote.parent.getStorableProps.apply(this);
  props.push("mailTo");
  props.push("mailComment");
  return props;
};

/*
 * Evernote.AbstractNoteForm
 * Evernote
 *
 * Created by Pavel Skaldin on 3/5/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.AbstractNoteForm = function AbstractNoteForm() {
};

Evernote.AbstractNoteForm.TITLE = "title";
Evernote.AbstractNoteForm.NOTEBOOK_GUID = "notebookGuid";
Evernote.AbstractNoteForm.TAG_NAMES = "tagNames";
Evernote.AbstractNoteForm.CONTENT = "content";
Evernote.AbstractNoteForm.COMMENT = "comment";
Evernote.AbstractNoteForm.MAIL_TO = "mailTo";
Evernote.AbstractNoteForm.MAIL_COMMENT = "mailComment";

Evernote.inherit(Evernote.AbstractNoteForm, jQuery);
Evernote.AbstractNoteForm.onForm = function(form, fieldNames) {
  var props = {};
  for ( var i in this.prototype) {
    props[i] = this.prototype[i];
  }
  var origForm = form.get(0);
  $.extend(true, form, props);
  form.form = $(origForm);
  form.__defineGetter__("title", form.getTitle);
  form.__defineSetter__("title", form.setTitle);
  form.__defineGetter__("notebookGuid", form.getNotebookGuid);
  form.__defineSetter__("notebookGuid", form.setNotebookGuid);
  form.__defineGetter__("tagNames", form.getTagNames);
  form.__defineSetter__("tagNames", form.setTagNames);
  form.__defineGetter__("content", form.getContent);
  form.__defineSetter__("content", form.setContent);
  form.__defineGetter__("comment", form.getComment);
  form.__defineSetter__("comment", form.setComment);
  form.__defineGetter__("mailTo", form.getMailTo);
  form.__defineSetter__("mailTo", form.setMailTo);
  form.__defineGetter__("mailComment", form.getMailComment);
  form.__defineSetter__("mailComment", form.setMailComment);
  if (typeof fieldNames == 'object' && fieldNames != null) {
    for ( var i in fieldNames) {
      if (typeof this.prototype[i + "FieldName"] == 'string')
        this[i + "FieldName"] = fieldNames[i];
    }
  }
  return form;
};

Evernote.AbstractNoteForm.prototype.titleFieldName = Evernote.AbstractNoteForm.TITLE;
Evernote.AbstractNoteForm.prototype.notebookGuidFieldName = Evernote.AbstractNoteForm.NOTEBOOK_GUID;
Evernote.AbstractNoteForm.prototype.tagNamesFieldName = Evernote.AbstractNoteForm.TAG_NAMES;
Evernote.AbstractNoteForm.prototype.contentFieldName = Evernote.AbstractNoteForm.CONTENT;
Evernote.AbstractNoteForm.prototype.commentFieldName = Evernote.AbstractNoteForm.COMMENT;
Evernote.AbstractNoteForm.prototype.mailToFieldName = Evernote.AbstractNoteForm.MAIL_TO;
Evernote.AbstractNoteForm.prototype.mailCommentFieldName = Evernote.AbstractNoteForm.MAIL_COMMENT;

Evernote.AbstractNoteForm.prototype.getField = function(fieldName) {
  return this.form.find("*[name=" + fieldName + "]");
};
Evernote.AbstractNoteForm.prototype.getLabel = function(fieldName) {
  return this.form.find("label[for=" + fieldName + "]");
};
Evernote.AbstractNoteForm.prototype.enableField = function(fieldName) {
  var field = this.getField(fieldName);
  if (field) {
    if (field.attr("tagName").toLowerCase() == 'input') {
      field.removeAttr("disabled");
    } else {
      field.removeClass("disabled");
    }
    var label = this.getLabel(fieldName);
    if (label && label.hasClass("disabled")) {
      label.removeClass("disabled");
    }
  }
};
Evernote.AbstractNoteForm.prototype.disableField = function(fieldName) {
  var field = this.getField(fieldName);
  if (field) {
    if (field.attr("tagName").toLowerCase() == "input") {
      field.attr("disabled", "disabled");
    } else {
      field.addClass("disabled");
    }
    var label = this.getLabel(fieldName);
    if (label && !(label.hasClass("disabled"))) {
      label.addClass("disabled");
    }
  }
};
Evernote.AbstractNoteForm.prototype.isFieldEnabled = function(fieldName) {
  var field = this.getField(fieldName);
  return (field && !field.hasClass("disabled"));
};
Evernote.AbstractNoteForm.prototype.getTitle = function() {
  return this.getField(this.titleFieldName).val();
};
Evernote.AbstractNoteForm.prototype.setTitle = function(title) {
  this.getField(this.titleFieldName).val(title);
};
Evernote.AbstractNoteForm.prototype.getNotebookGuid = function() {
  return this.getField(this.notebookGuidFieldName).val();
};
Evernote.AbstractNoteForm.prototype.setNotebookGuid = function(notebookGuid) {
  this.getField(this.notebookGuidFieldName).val(notebookGuid);
};
Evernote.AbstractNoteForm.prototype.getTagNames = function() {
  return this.getField(this.tagNamesFieldName).val();
};
Evernote.AbstractNoteForm.prototype.setTagNames = function(tagNames) {
  this.getField(this.tagNamesFieldName).val(tagNames);
};
Evernote.AbstractNoteForm.prototype.getContent = function() {
  return this.getField(this.contentFieldName).val();
};
Evernote.AbstractNoteForm.prototype.setContent = function(content) {
  this.getField(this.contentFieldName).val(content);
};
Evernote.AbstractNoteForm.prototype.getComment = function() {
  return this.getField(this.commentFieldName).val();
};
Evernote.AbstractNoteForm.prototype.setComment = function(comment) {
  this.getField(this.commentFieldName).val(comment);
};
Evernote.AbstractNoteForm.prototype.getMailTo = function() {
  return this.getField(this.mailToFieldName).val();
};
Evernote.AbstractNoteForm.prototype.setMailTo = function(str) {
  this.getField(this.mailToFieldName).val(str);
};
Evernote.AbstractNoteForm.prototype.getMailComment = function() {
  return this.getField(this.mailCommentFieldName).val();
};
Evernote.AbstractNoteForm.prototype.setMailComment = function(str) {
  this.getField(this.mailCommentFieldName).val(str);
};
Evernote.AbstractNoteForm.prototype.reset = function() {
  var props = this.getStorableProps();
  for ( var i = 0; i < props.length; i++) {
    this[props[i]] = null;
  }
};
Evernote.AbstractNoteForm.prototype.populateWithNote = function(context, note) {
  if (typeof LOG != 'undefined')
    LOG.debug("Evernote.AbstractNoteForm.populateWithNote");
  // this.reset();
  if (note instanceof Evernote.AppModel) {
    var props = note.toStorable();
    for ( var i in props) {
      if (typeof this[i] != 'undefined' && typeof note[i] != 'undefined'
          && note[i] != null) {
        this[i] = note[i];
      }
    }
  }
};
Evernote.AbstractNoteForm.prototype.populateWith = function(options) {
  if (typeof LOG != 'undefined')
    LOG.debug("Evernote.ClipNoteForm.populateWith");
  if (typeof options == 'object' && options != null) {
    for ( var opt in options) {
      if (typeof this[opt] != 'undefined' && typeof this[opt] != 'function'
          && typeof options[opt] != 'undefined' && options[opt] != null) {
        this[opt] = options[opt];
      }
    }
  }
};
Evernote.AbstractNoteForm.prototype.getStorableProps = function() {
  return [ "title", "notebookGuid", "tagNames", "content", "comment", "mailTo",
      "mailComment" ];
};
Evernote.AbstractNoteForm.prototype.toStorable = function() {
  var props = this.getStorableProps();
  var storable = {};
  for ( var i = 0; i < props.length; i++) {
    storable[props[i]] = this[props[i]];
  }
  return storable;
};
Evernote.AbstractNoteForm.prototype.getModelName = function() {
  return "Evernote.AbstractNoteForm";
};
Evernote.AbstractNoteForm.prototype.getStringDescription = function() {
  return "'" + this.title + "'; NotebookGuid: " + this.notebookGuid
      + "; TagNames: " + this.tagNames + "; Content length: "
      + ((typeof this.content == 'string') ? this.content.length : 0)
      + "; Comment length: "
      + ((typeof this.comment == 'string') ? this.comment.length : 0);
};
Evernote.AbstractNoteForm.prototype.toString = function() {
  return this.getModelName() + " " + this.getStringDescription();
};

/*
 * Evernote.NoteForm
 * Evernote
 *
 * Created by Pavel Skaldin on 3/5/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.NoteForm = function NoteForm(form) {
};

Evernote.NoteForm.URL = "url";
Evernote.NoteForm.THUMBNAIL_URL = "thumbnailUrl";
Evernote.NoteForm.NOTE_URL = "noteUrl";
Evernote.NoteForm.GUID = "guid";
Evernote.NoteForm.THUMBNAIL_SIZE = 150;

Evernote.inherit(Evernote.NoteForm, Evernote.AbstractNoteForm);
Evernote.NoteForm.onForm = function(form, fieldNames) {
  form = Evernote.NoteForm.parent.constructor.onForm.apply(this, [ form,
      fieldNames ]);
  form.__defineGetter__("url", form.getUrl);
  form.__defineSetter__("url", form.setUrl);
  form.__defineGetter__("thumbnailUrl", form.getThumbnailUrl);
  form.__defineSetter__("thumbnailUrl", form.setThumbnailUrl);
  form.__defineGetter__("noteUrl", form.getNoteUrl);
  form.__defineSetter__("noteUrl", form.setNoteUrl);
  form.__defineGetter__("guid", form.getGuid);
  form.__defineSetter__("guid", form.setGuid);
  return form;
};

Evernote.NoteForm.prototype.urlFieldName = Evernote.NoteForm.URL;
Evernote.NoteForm.prototype.thumbnailUrlFieldName = Evernote.NoteForm.THUMBNAIL_URL;
Evernote.NoteForm.prototype.noteUrlFieldName = Evernote.NoteForm.NOTE_URL;
Evernote.NoteForm.prototype.guidFieldName = Evernote.NoteForm.GUID;

Evernote.NoteForm.prototype.getUrl = function() {
  return this.getField(this.urlFieldName).text();
};
Evernote.NoteForm.prototype.setUrl = function(url) {
  this.getField(this.urlFieldName).text(url);
};
Evernote.NoteForm.prototype.getThumbnailUrl = function() {
  return this.getField(this.thumbnailUrlFieldName).attr("src");
};
Evernote.NoteForm.prototype.setThumbnailUrl = function(url) {
  this.getField(this.thumbnailUrlFieldName).attr("src", url);
};
Evernote.NoteForm.prototype.getNoteUrl = function() {
  return this.getField(this.noteUrlFieldName).val();
};
Evernote.NoteForm.prototype.setNoteUrl = function(url) {
  this.getField(this.noteUrlFieldName).val(url);
};
Evernote.NoteForm.prototype.setGuid = function(guid) {
  if (typeof guid == 'undefined' || guid == null)
    this.getField(this.guidFieldName).val(null);
  else
    this.getField(this.guidFieldName).val(guid);
};
Evernote.NoteForm.prototype.getGuid = function() {
  return this.getField(this.guidFieldName).val();
};
Evernote.NoteForm.prototype.getStorableProps = function() {
  var props = Evernote.NoteForm.parent.getStorableProps.apply(this);
  props.push("url");
  props.push("thumbnailUrl");
  props.push("noteUrl");
  props.push("guid");
  return props;
};
Evernote.NoteForm.prototype.populateWithNote = function(context, note) {
  if (note instanceof Evernote.Note) {
    Evernote.NoteForm.parent.populateWithNote.apply(this, [ context, note ]);
    if (note.guid) {
      this.guid = note.guid;
      var noteUrl = note.getNoteUrl(context.getShardedUrl(), context
          .getShardId(), "", context.getLocale());
      this.noteUrl = noteUrl;
      this.thumbnailUrl = note.getThumbnailUrl(context.getShardedUrl(),
          Evernote.NoteForm.THUMBNAIL_SIZE);
    }
    if (note.attributes instanceof Evernote.NoteAttributes
        && note.attributes.sourceURL) {
      this.url = note.attributes.sourceURL;
    }
  }
};
Evernote.NoteForm.prototype.asNote = function() {
  var note = new Evernote.MailNote();
  if (this.guid) {
    note.guid = this.guid;
  }
  if (this.title) {
    note.title = this.title;
  }
  if (this.notebookGuid) {
    note.notebookGuid = this.notebookGuid;
  }
  if (this.comment) {
    note.comment = this.comment;
  }
  var doTrim = (typeof "".trim == 'function');
  if (typeof this.tagNames == 'string' && this.tagNames.length > 0) {
    var parts = this.tagNames.split(",");
    if (parts instanceof Array && parts.length > 0) {
      for ( var i = 0; i < parts.length; i++) {
        var t = new Evernote.Tag();
        t.name = (doTrim) ? parts[i].trim() : parts[i];
        note.addTag(t);
      }
    }
  }
  if (this.url) {
    var attrs = (note.attributes instanceof Evernote.NoteAttributes) ? note.attributes
        : (new Evernote.NoteAttributes());
    attrs.sourceURL = this.url;
    note.attributes = attrs;
  }
  if (this.mailTo) {
    note.mailTo = this.mailTo;
    if (this.mailComment)
      note.mailComment = this.mailComment;
  }
  return note;
};
Evernote.NoteForm.prototype.getModelName = function() {
  return "Evernote.NoteForm";
};
Evernote.NoteForm.prototype.getStringDescription = function() {
  var superStr = Evernote.NoteForm.parent.getStringDescription.apply(this);
  superStr += "; URL: " + this.url + "; Guid: " + this.guid;
  return superStr;
};

/*
 * Evernote.ModelForm
 * Evernote
 *
 * Created by Pavel Skaldin on 3/7/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
(function() {
  var LOG = null;
  Evernote.ModelForm = function ModelForm() {
    LOG = Evernote.chromeExtension.logger;
  };

  Evernote.inherit(Evernote.ModelForm, jQuery);
  Evernote.ModelForm.onForm = function(form, fieldSelector) {
    LOG = LOG || Evernote.chromeExtension.getLogger(Evernote.ModelForm);
    var props = {};
    for ( var i in this.prototype) {
      props[i] = this.prototype[i];
    }
    // Extend jQuery object and make a reference to the original jQuery object
    var origForm = form.get(0);
    $.extend(true, form, props);
    form.form = $(origForm);
    form._fields = {};

    fieldSelector = (typeof fieldSelector == 'string') ? fieldSelector
        : "input, textarea, select";
    var fields = form.form.find(fieldSelector);
    if (fields) {
      for ( var i = 0; i < fields.length; i++) {
        var field = $(fields[i]);
        var fieldName = field.attr("name");
        var realFieldName = fieldName;
        if (!fieldName)
          continue;
        // deduce proper name
        var fieldNameParts = fieldName.replace(/[^a-z0-9]+/i, " ").split();
        if (fieldNameParts.length > 1) {
          for ( var n = 0; n < fieldNameParts.length; n++) {
            if (n == 0)
              fieldName = fieldNameParts[n].toLowerCase();
            else
              fieldName += fieldNameParts[n].substring(0, 1).toUperrCase()
                  + fieldNameParts[n].substring(1).toLowerCase();
          }
        }
        // skip fields that have been processed already
        if (typeof form._fields[fieldName] != 'undefined') {
          LOG.debug(">>> " + fieldName + " was already parsed");
          continue;
        }
        // add mapping of fieldName to field object
        LOG.debug(">>> FieldName: " + fieldName);
        form._fields[fieldName] = field;

        // setup accessors
        form.__defineGetter__("storableProps", form.getStorableProps);
        form.__defineSetter__("storableProps", form.setStorableProps);
        var methName = fieldName.substring(0, 1).toUpperCase()
            + fieldName.substring(1);
        if (field.attr("type") == "checkbox") {
          var t = "(function() {return function is" + methName
              + "() {return this.getField('" + realFieldName
              + "').attr('checked');}})()";
          form["is" + methName] = eval(t);
          form.__defineGetter__(fieldName, form["is" + methName]);
          t = "(function () {return function set"
              + methName
              + "(bool) {if (typeof bool != 'undefined' && bool) {this.getField('"
              + realFieldName
              + "').attr('checked', 'checked');} else {this.getField('"
              + fieldName + "').removeAttr('checked');} }})()";
          form["set" + methName] = eval(t);
          form.__defineSetter__(fieldName, form["set" + methName]);
        } else if (field.attr("type") == "radio") {
          var t = "(function() {return function is"
              + methName
              + "() {var checked = null; this.getField('"
              + realFieldName
              + "').each(function(index, element) {var $element = $(element); if ($element.attr('checked')) {checked = $element.val()}});"
              + "return checked;}})()";
          form["get" + methName] = eval(t);
          form.__defineGetter__(fieldName, form["get" + methName]);
          t = "(function () {return function set"
              + methName
              + "(val) {this.getField('"
              + realFieldName
              + "').each(function(index, element) {var $element = $(element);if ($element.val() == val) {$element.attr('checked', 'checked');} else {$element.removeAttr('checked');} });}})()";
          form["set" + methName] = eval(t);
          form.__defineSetter__(fieldName, form["set" + methName]);
        } else {
          var t = "(function() {return function get" + methName
              + "() {return this.getField('" + realFieldName + "').val();}})()";
          form["get" + methName] = eval(t);
          form.__defineGetter__(fieldName, form["get" + methName]);

          var t = "(function() {return function set" + methName
              + "(value) {this.getField('" + realFieldName
              + "').val(value);}})()";
          form["set" + methName] = eval(t);
          form.__defineSetter__(fieldName, form["set" + methName]);
        }
      }
    }
    return form;
  };

  Evernote.ModelForm.prototype._storableProps = null;

  Evernote.ModelForm.prototype.getField = function(fieldName) {
    return this.form.find("*[name=" + fieldName + "]");
  };
  Evernote.ModelForm.prototype.clear = function() {
    // TODO: clear form
  };
  Evernote.ModelForm.prototype.populateWith = function(object) {
    LOG.debug("Evernote.ModelForm.populateWith");
    if (typeof object == 'object' && object != null) {
      for ( var i in object) {
        if (typeof this._fields[i] != 'undefined') {
          this[i] = object[i];
        }
      }
    }
  };
  Evernote.ModelForm.prototype.setStorableProps = function(arrayOfPropNames) {
    var a = (arrayOfPropNames instanceof Array) ? arrayOfPropNames : new Array(
        arrayOfPropNames);
    this._storableProps = new Array();
    for ( var i = 0; i < a.length; i++) {
      if (typeof a[i] == 'string' && a[i].length > 0)
        this._storableProps.push(a[i]);
    }
  };
  Evernote.ModelForm.prototype.getStorableProps = function() {
    if (this._storableProps == null) {
      var fieldNames = new Array();
      for ( var i in this._fields) {
        fieldNames.push(i);
      }
      this._storableProps = fieldNames;
    }
    return this._storableProps;
  };
  Evernote.ModelForm.prototype.toStorable = function() {
    var props = this.storableProps;
    var storable = {};
    for ( var i = 0; i < props.length; i++) {
      storable[props[i]] = this[props[i]];
    }
    return storable;
  };
})();

/*
 * Evernote.ClipNoteForm
 * Evernote
 *
 * Created by Pavel Skaldin on 3/5/10
 * Copyright 2010 Evernote Corp. All rights reserved
 */
Evernote.ClipNoteForm = function ClipNoteForm(form) {
};

Evernote.ClipNoteForm.SAVE_URL = "saveUrl";
Evernote.ClipNoteForm.FULL_PAGE = "fullPage";
Evernote.ClipNoteForm.URL = "url";

Evernote.inherit(Evernote.ClipNoteForm, Evernote.AbstractNoteForm);
Evernote.ClipNoteForm.onForm = function(form, fieldNames) {
  form = Evernote.ClipNoteForm.parent.constructor.onForm.apply(this, [ form, fieldNames ]);
  form.__defineGetter__("url", form.getUrl);
  form.__defineSetter__("url", form.setUrl);
  form.__defineGetter__("saveUrl", form.isSaveUrl);
  form.__defineSetter__("saveUrl", form.setSaveUrl);
  form.__defineGetter__("fullPage", form.isFullPage);
  form.__defineSetter__("fullPage", form.setFullPage);
  form.__defineGetter__("saveUrlEnabled", form.isSaveUrlEnabled);
  form.__defineSetter__("saveUrlEnabled", form.setSaveUrlEnabled);
  form.__defineGetter__("fullPageEnabled", form.isFullPageEnabled);
  form.__defineSetter__("fullPageEnabled", form.setFullPageEnabled);
  form.getField(form.saveUrlFieldName).change(function() {
    form.setSaveUrl($(this).attr("checked"));
  });
  form.getField(form.fullPageFieldName).change(function() {
    form.setFullPage($(this).attr("checked"));
  });
  return form;
};

Evernote.ClipNoteForm.prototype.saveUrlFieldName = Evernote.ClipNoteForm.SAVE_URL;
Evernote.ClipNoteForm.prototype.fullPageFieldName = Evernote.ClipNoteForm.FULL_PAGE;
Evernote.ClipNoteForm.prototype.urlFieldName = Evernote.ClipNoteForm.URL;

Evernote.ClipNoteForm.prototype.isSaveUrl = function() {
  return this.getField(this.saveUrlFieldName).attr("checked");
};
Evernote.ClipNoteForm.prototype.setSaveUrl = function(bool) {
  if (bool) {
    this.getField(this.saveUrlFieldName).attr("checked", "checked");
  } else {
    this.getField(this.saveUrlFieldName).removeAttr("checked");
    this.setFullPage(false);
  }
};
Evernote.ClipNoteForm.prototype.setSaveUrlEnabled = function(bool) {
  if (bool) {
    this.enableSaveUrl();
  } else {
    this.disableSaveUrl();
  }
};
Evernote.ClipNoteForm.prototype.isSaveUrlEnabled = function() {
  return this.isFieldEnabled(this.saveUrlFieldName);
};
Evernote.ClipNoteForm.prototype.enableSaveUrl = function() {
  this.enableField(this.saveUrlFieldName);
};
Evernote.ClipNoteForm.prototype.disableSaveUrl = function() {
  this.disableField(this.saveUrlFieldName);
};
Evernote.ClipNoteForm.prototype.isFullPage = function() {
  return (this.getField(this.fullPageFieldName).attr("checked"));
};
Evernote.ClipNoteForm.prototype.setFullPage = function(bool) {
  if (bool) {
    this.getField(this.fullPageFieldName).attr("checked", "checked");
    this.setSaveUrl(true);
  } else {
    this.getField(this.fullPageFieldName).removeAttr("checked");
  }
};
Evernote.ClipNoteForm.prototype.disableFullPage = function() {
  this.disableField(this.fullPageFieldName);
};
Evernote.ClipNoteForm.prototype.enableFullPage = function() {
  this.enableField(this.fullPageFieldName);
};
Evernote.ClipNoteForm.prototype.isFullPageEnabled = function() {
  return this.isFieldEnabled(this.fullPageFieldName);
};
Evernote.ClipNoteForm.prototype.setFullPageEnabled = function(bool) {
  if (bool) {
    this.enableFullPage();
  } else {
    this.disableFullPage();
  }
};
Evernote.ClipNoteForm.prototype.getUrl = function() {
  return this.getField(this.urlFieldName).val();
};
Evernote.ClipNoteForm.prototype.setUrl = function(url) {
  this.getField(this.urlFieldName).val(url);
};

Evernote.ClipNoteForm.prototype.getStorableProps = function() {
  var props = Evernote.ClipNoteForm.parent.getStorableProps.apply(this);
  props.push("saveUrl");
  props.push("fullPage");
  props.push("url");
  return props;
};
Evernote.ClipNoteForm.prototype.populateWithNote = function(context, clipNote) {
  if (typeof LOG != 'undefined')
    LOG.debug("Evernote.ClipNoteForm.populateWithNote");
  if (clipNote instanceof Evernote.ClipNote) {
    Evernote.ClipNoteForm.parent.populateWithNote.apply(this, [ context, clipNote ]);
    if (typeof LOG != 'undefined')
      LOG.debug(">>> Setting fullPage: " + clipNote.fullPage);
    this.setFullPage(clipNote.fullPage);
    if (typeof LOG != 'undefined')
      LOG.debug(">>> Setting saveUrl: " + clipNote.saveUrl);
    this.setSaveUrl(clipNote.saveUrl);
    if (clipNote.notebookGuid) {
      this.notebookGuid = clipNote.notebookGuid;
    }
  }
};
Evernote.ClipNoteForm.prototype.asClipNote = function() {
  if (typeof LOG != 'undefined')
    LOG.debug("Evernote.ClipNoteForm.asClipNote");
  var clipNote = new Evernote.ClipNote(this.toStorable());
  if (typeof LOG != 'undefined')
    LOG.debug(">>> CLIPNOTE: " + clipNote.toString());
  return clipNote;
};
Evernote.ClipNoteForm.prototype.getModelName = function() {
  return "Evernote.ClipNoteForm";
};
Evernote.ClipNoteForm.prototype.getStringDescription = function() {
  var superStr = Evernote.ClipNoteForm.parent.getStringDescription.apply(this);
  superStr += "; URL: " + this.url + "; SaveUrl: " + this.saveUrl
      + "; FullPage: " + this.fullPage;
  return superStr;
};

(function() {
  var LOG = null;

  Evernote.ContentScriptingMixin = function ContentScriptingMixin() {
  };
  Evernote.ContentScriptingMixin.prototype.startScriptTimer = function(tabId,
      timeoutCallback, t) {
    LOG = LOG
        || Evernote.chromeExtension.getLogger(Evernote.ContentScriptingMixin);
    LOG.debug("ContentScriptingMixin.startScriptTimer");
    return setTimeout(function() {
      LOG.debug("Content script load/execution timed out");
      if (typeof timeoutCallback == 'function') {
        timeoutCallback(tabId);
      }
    }, t);
  };
  Evernote.ContentScriptingMixin.prototype.stopScriptTimer = function(timerId) {
    LOG = LOG
        || Evernote.chromeExtension.getLogger(Evernote.ContentScriptingMixin);
    LOG.debug("ContentScriptingMixin.stopScriptTimer");
    if (typeof timerId == 'number') {
      LOG.debug("Cancelling load timer");
      clearTimeout(timerId);
    }
  };
  Evernote.ContentScriptingMixin.prototype.executeScript = function(tabId,
      scriptObj, oncomplete) {
    LOG = LOG
        || Evernote.chromeExtension.getLogger(Evernote.ContentScriptingMixin);
    LOG.debug("ContentScriptingMixin.executeScript");
    if (typeof tabId != 'number')
      tabId = null;
    this.doExecuteScript(tabId, scriptObj, null, oncomplete);
  };
  Evernote.ContentScriptingMixin.prototype.executeTimedScript = function(tabId,
      scriptObj, timeout, oncomplete, ontimeout) {
    LOG = LOG
        || Evernote.chromeExtension.getLogger(Evernote.ContentScriptingMixin);
    LOG.debug("ContentScriptingMixin.executeTimedScript");
    if (typeof tabId != 'number')
      tabId = null;
    if (typeof timeout != 'number') {
      timeout = 0;
    }
    var timer = 0;
    var self = this;
    this.doExecuteScript(tabId, scriptObj, function() {
      LOG.debug("Starting page clip timer");
      timer = self.startScriptTimer(tabId, ontimeout, timeout);
    }, function() {
      self.stopScriptTimer(timer);
      if (typeof oncomplete == 'function') {
        oncomplete();
      }
    });
  };
  Evernote.ContentScriptingMixin.prototype.doExecuteScript = function(tabId,
      scriptObj, onstart, oncomplete) {
    LOG = LOG
        || Evernote.chromeExtension.getLogger(Evernote.ContentScriptingMixin);
    LOG.debug("ContentScriptingMixin.doExecuteScript");
    if (typeof tabId != 'number')
      tabId = null;
    if (typeof onstart == 'function') {
      LOG.debug("Executing onstart");
      onstart();
    }
    LOG.debug("Executing code in tab");
    chrome.tabs.executeScript(tabId, scriptObj, function() {
      if (typeof oncomplete == 'function') {
        oncomplete();
      }
    });
  };
})();

(function() {
  var LOG = null;

  /**
   * Map of various states of this controller.
   */
  var ContentScriptingStatus = {
    UNKNOWN : 0,
    LOADING : 1,
    LOADED : 2,
    EXECUTING : 3,
    FINISHED : 4,
    TIMEDOUT : 5,
    ERROR : 6
  };

  Evernote.AbstractContentScripting = function AbstractContentScripting() {
    LOG = Evernote.chromeExtension.logger;
    this.initialize();
  };

  Evernote.mixin(Evernote.AbstractContentScripting,
      Evernote.ContentScriptingMixin, {
        "executeScript" : "mixinExecuteScript",
        "executeTimedScript" : "mixinExecuteTimedScript",
        "doExecuteScript" : "mixinDoExecuteScript"
      });

  Evernote.AbstractContentScripting.prototype._status = null;
  Evernote.AbstractContentScripting.prototype._sema = null;
  Evernote.AbstractContentScripting.TIMEOUT = 10000;

  Evernote.AbstractContentScripting.prototype.initialize = function() {
    this._status = {};
    this._sema = Evernote.Semaphore.mutex();
    this.initializeTabListeners();
  };

  Evernote.AbstractContentScripting.prototype.initializeTabListeners = function() {
    this.initializeTabUpdateListener();
    this.initializeTabRemoveListener();
  };

  Evernote.AbstractContentScripting.prototype.initializeTabUpdateListener = function() {
    var self = this;
    chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
      LOG.debug("chrome.extension.onUpdated: " + tabId);
      self.handleTabUpdate(tabId, changeInfo, tab);
    });
  };
  Evernote.AbstractContentScripting.prototype.initializeTabRemoveListener = function() {
    var self = this;
    chrome.tabs.onRemoved.addListener(function(tabId, removeInfo) {
      LOG.debug("chrome.extension.onRemoved: " + tabId);
      self.handleTabRemove(tabId, removeInfo);
    });
  };

  Evernote.AbstractContentScripting.prototype.handleTabUpdate = function(tabId,
      changeInfo, tab) {
    LOG.debug("AbstractContentScripting.handleTabUpdate");
    if (changeInfo && changeInfo.status == "loading") {
      LOG.debug("Forgetting tabId: " + tabId);
      this.forgetTab(tabId);
    }
  };

  Evernote.AbstractContentScripting.prototype.handleTabRemove = function(tabId,
      removeInfo) {
    LOG.debug("AbstractContentScripting.handleTabRemove");
    this.forgetTab(tabId);
  };

  Evernote.AbstractContentScripting.prototype.getRequiredScriptNames = function() {
    return [];
  };

  Evernote.AbstractContentScripting.prototype.forgetTab = function(tabId) {
    LOG.debug("AbstractContentScripting.forgetTab: " + tabId);
    if (typeof tabId == 'number' && this._status[tabId]) {
      LOG.debug("Deleting remembered tabId: " + tabId);
      delete this._status[tabId];
    }
  };
  Evernote.AbstractContentScripting.prototype.setStatus = function(tabId,
      status) {
    LOG.debug("AbstractContentScripting.setStatus: " + tabId + ", " + status);
    if (typeof tabId == 'number') {
      LOG.debug("Setting status of tabId: " + tabId + " to " + status);
      this._status[tabId] = status;
    }
  };
  Evernote.AbstractContentScripting.prototype.getStatus = function(tabId) {
    return (this._status[tabId] || ContentScriptingStatus.INITIALIZED);
  };
  Evernote.AbstractContentScripting.prototype.isRequiredScriptsLoaded = function(
      tabId) {
    return (this.getRequiredScriptNames().length == 0 || this.getStatus(tabId) >= ContentScriptingStatus.LOADED);
  };
  Evernote.AbstractContentScripting.prototype.isRequiredScriptsLoading = function(
      tabId) {
    return this.getStatus(tabId) == ContentScriptingStatus.LOADING;
  };
  Evernote.AbstractContentScripting.prototype.loadRequiredScripts = function(
      tabId, callback) {
    LOG.debug("AbstractContentScripting.loadRequiredScripts");
    var self = this;
    this.setStatus(tabId, ContentScriptingStatus.LOADING);
    self._loadRequiredScripts(tabId, function() {
      self.setStatus(tabId, ContentScriptingStatus.LOADED);
      if (typeof callback == 'function') {
        callback();
      }
    }, self.ontimeout, self.getRequiredScriptNames());
  };
  Evernote.AbstractContentScripting.prototype._loadRequiredScripts = function(
      tabId, callback, ontimeout, scripts) {
    LOG.debug("AbstractContentScripting._loadRequiredScripts");
    var self = this;
    if (scripts && scripts.length > 0) {
      var script = scripts.shift();
      LOG.debug("Loading script: " + script + " with timeout of: "
          + this.constructor.TIMEOUT);
      this.mixinExecuteTimedScript(tabId, {
        file : script
      }, this.constructor.TIMEOUT, function() {
        LOG.debug("Loaded script: " + script);
        self._loadRequiredScripts(tabId, callback, ontimeout, scripts);
      }, function() {
        LOG.debug("Timed out after waiting for " + self.constructor.TIMEOUT
            + " ms for script to load: " + script);
        if (typeof ontimeout == 'function') {
          ontimeout();
        }
        // self._loadRequiredScripts(tabId, callback, ontimeout, []);
        });
    } else {
      LOG.debug("Finished loading scripts into tab: " + tabId);
      this.onload(tabId, callback);
    }
  };
  Evernote.AbstractContentScripting.prototype.getOnloadCode = function() {
    return "Evernote.Logger.setGlobalLevel(" + LOG.level + ");";
  };
  Evernote.AbstractContentScripting.prototype.onload = function(tabId, callback) {
    LOG.debug("AbstractContentScripting.onload");
    LOG.debug("Setting up Logger inside the content page");
    this.mixinDoExecuteScript(tabId, {
      code : this.getOnloadCode()
    }, null, function() {
      if (typeof callback == 'function') {
        LOG.debug("Executing callback after loading all required scripts");
        callback();
      }
    });
  };
  Evernote.AbstractContentScripting.prototype.ontimeout = function() {
    LOG.debug("AbstractContentScripting.ontimeout");
    Evernote.Utils.notifyExtension(new Evernote.RequestMessage(
        Evernote.Constants.RequestType.CONTENT_SCRIPT_LOAD_TIMEOUT));
  };
  Evernote.AbstractContentScripting.prototype.ensureRequiredScripts = function(
      tabId) {
    LOG.debug("AbstractContentScripting.ensureRequiredScripts");
    if (!this.isRequiredScriptsLoaded(tabId)
        && !this.isRequiredScriptsLoading(tabId)) {
      LOG
          .debug("ContentScript wasn't injected yet, injecting it and then executing the callback");
      try {
        this.loadRequiredScripts(tabId);
      } catch (e) {
        LOG.error(e);
      }
    }
  };
  Evernote.AbstractContentScripting.prototype.executeScript = function(tabId,
      scriptObject, oncomplete) {
    LOG.debug("AbstractContentScripting.executeScript");
    var self = this;
    this.ensureRequiredScripts(tabId);
    // this.mixinExecuteScript(tabId, scriptObject, oncomplete);
    this.doExecuteScript(tabId, scriptObject, function() {
      self.setStatus(tabId, ContentScriptingStatus.EXECUTING);
    }, function() {
      self.setStatus(tabId, ContentScriptingStatus.FINISHED);
      if (typeof oncomplete == 'function') {
        oncomplete();
      }
    });
  };
  Evernote.AbstractContentScripting.prototype.executeTimedScript = function(
      tabId, scriptObject, timeout, oncomplete, ontimeout) {
    LOG.debug("AbstractContentScripting.executeTimedScript");
    var self = this;
    this.ensureRequiredScripts(tabId);
    this.mixinExecuteTimedScript(tabId, scriptObject, timeout, function() {
      self.setStatus(tabId, ContentScriptingStatus.EXECUTING);
      if (typeof oncomplete == 'function') {
        oncomplete();
      }
    }, function() {
      self.setStatus(tabId, ContentScriptingStatus.TIMEDOUT);
      if (typeof ontimeout == 'function') {
        ontimeout();
      }
    });
  };
  Evernote.AbstractContentScripting.prototype._logTabInfo = function(tabId) {
    chrome.tabs.get(tabId, function(tab) {
      LOG.debug(tab.url);
    });
  };
  Evernote.AbstractContentScripting.prototype.doExecuteScript = function(tabId,
      scriptObject, onstart, oncomplete) {
    LOG.debug("AbstractContentScripting.doExecuteScript(" + tabId + ")");
    var self = this;
    LOG
        .debug(" > Sema: " + this._sema._excessSignals + ":"
            + this._sema.length);
    this._sema
        .critical(function() {
          try {
            if (scriptObject.file) {
              LOG.debug("Executing content script from file: "
                  + scriptObject.file);
            } else if (scriptObject.code) {
              LOG.debug("Executing content script: " + scriptObject.code);
            }
            // self.setStatus(tabId, ContentScriptingStatus.EXECUTING);
            if (LOG.isDebugEnabled()) {
              self._logTabInfo(tabId);
            }
            self.mixinDoExecuteScript(tabId, scriptObject, onstart, function() {
              // self.setStatus(tabId, ContentScriptingStatus.FINISHED);
                if (typeof oncomplete == 'function') {
                  oncomplete();
                }
                self._sema.signal();
              });
          } catch (e) {
            self.setStatus(tabId, ContentScriptingStatus.ERROR);
            LOG.error(e);
            self._sema.signal();
          }
        });
    LOG
        .debug(" < Sema: " + this._sema._excessSignals + ":"
            + this._sema.length);
  };
})();


/*
 * Evernote
 * Evernote
 * 
 * Created by Pavel Skaldin on 2/23/10
 * Copyright 2010 Evernote Corp. All rights reserved.
 */

(function() {
  var LOG = null;

  Evernote.SearchHelper = function SearchHelper() {
    // LOG = Evernote.Logger.getInstance();
    LOG = Evernote.chromeExtension.logger;
    this.initialize();
  };

  Evernote.SearchHelper.prototype._query = null;
  Evernote.SearchHelper.prototype._ajax = null;
  Evernote.SearchHelper.prototype._result = null;
  Evernote.SearchHelper.prototype._response = null;
  Evernote.SearchHelper.prototype._filter = null;
  Evernote.SearchHelper.prototype._sema = null;
  Evernote.SearchHelper.prototype._successHandler = null;
  Evernote.SearchHelper.prototype._errorHandler = null;
  // caching should really stay disabled because it may still display results
  // after user delete cookies - and that's weird
  Evernote.SearchHelper.prototype._caching = false;
  Evernote.SearchHelper.prototype._xhr = null;

  Evernote.SearchHelper.queryFromUrl = function(url) {
    if (typeof url == 'string') {
      var domain = Evernote.Utils.urlDomain(url);
      if (typeof domain == 'string') {
        domain = domain.toLowerCase();
        if (domain.indexOf("www.google.") == 0) {
          var u = (url.indexOf("#") > 0) ? url.replace(/(\?.*)?\#/, "?") : url;
          return Evernote.Utils.urlQueryValue("q", u);
        }
      }
    }
    return null;
  };

  Evernote.SearchHelper._pool = {};

  Evernote.SearchHelper.search = function(tabId, url, success, failure,
      startWaiting) {
    LOG = LOG || Evernote.chromeExtension.getLogger(Evernote.SearchHelper);
    LOG.debug("Search from URL: " + url);
    var sh = Evernote.SearchHelper.getInstance(tabId);
    var q = Evernote.SearchHelper.queryFromUrl(url);
    if (sh && sh.caching && sh.query == q) {
      LOG.debug("Using cached version of SearchHelper");
      return;
    } else if (sh) {
      LOG.debug("Re-using existing instance of SearchHelper");
      sh.abort();
      sh.reset();
    } else {
      LOG.debug("Creating new instanceo of SearchHelper");
      sh = Evernote.SearchHelper._pool[tabId] = new Evernote.SearchHelper();
    }
    if (startWaiting) {
      LOG.debug("Start waiting before the search");
      sh.wait();
    }
    sh.query = q;
    sh.successHandler = success;
    sh.errorHandler = failure;
    sh.doSearch();
  };

  Evernote.SearchHelper.abortAll = function() {
    for ( var i in Evernote.SearchHelper._pool) {
      var sh = Evernote.SearchHelper._pool[i];
      sh.abort();
      sh.reset();
    }
  };

  Evernote.SearchHelper.reset = function() {
    Evernote.SearchHelper.abortAll();
    Evernote.SearchHelper._pool = {};
  };

  Evernote.SearchHelper.getInstance = function(tabId) {
    return Evernote.SearchHelper._pool[tabId];
  };

  Evernote.SearchHelper.removeInstance = function(tabId) {
    LOG = LOG || Evernote.chromeExtension.getLogger(Evernote.SearchHelper);
    LOG.debug("SearchHelper.removeInstance: " + tabId);
    if (Evernote.SearchHelper._pool[tabId]) {
      delete Evernote.SearchHelper._pool[tabId];
    }
  };

  Evernote.SearchHelper.prototype.initialize = function() {
    this.__defineGetter__("query", this.getQuery);
    this.__defineSetter__("query", this.setQuery);
    this.__defineGetter__("result", this.getResult);
    this.__defineGetter__("response", this.getResponse);
    this.__defineGetter__("successHandler", this.getSuccessHandler);
    this.__defineSetter__("successHandler", this.setSuccessHandler);
    this.__defineGetter__("errorHandler", this.getErrorHandler);
    this.__defineSetter__("errorHandler", this.setErrorHandler);
    this.__defineGetter__("noteFilter", this.getNoteFilter);
    this.__defineGetter__("caching", this.isCaching);
    this.__defineSetter__("caching", this.setCaching);
    this.initializeNoteFilter();
    this._sema = 0;
  };

  Evernote.SearchHelper.prototype.initializeNoteFilter = function() {
    this._filter = new Evernote.NoteFilter( {
      order : NoteSortOrderTypes.UPDATED,
      ascending : false,
      fuzzy : true
    });
  };

  Evernote.SearchHelper.prototype.wait = function() {
    this._sema++;
  };

  Evernote.SearchHelper.prototype.signal = function() {
    LOG.debug("SearchHelper.signal");
    this._sema = Math.max(this._sema - 1, 0);
    LOG.debug("Semaphone count: " + this._sema);
    if (this._sema == 0) {
      this._handleResult();
    }
  };

  Evernote.SearchHelper.prototype.isWaiting = function() {
    return this._sema > 0;
  };

  Evernote.SearchHelper.prototype.isActive = function() {
    return (this._query != null && this._filter != null);
  };

  Evernote.SearchHelper.prototype.hasSearchQuery = function() {
    return (this.getQuery()) ? true : false;
  };
  Evernote.SearchHelper.prototype.setQuery = function(q) {
    if (typeof q == 'string' && q.length > 0) {
      this._query = q.toLowerCase();
    } else if (q == null) {
      this._query = null;
    }
  };
  Evernote.SearchHelper.prototype.getQuery = function() {
    return this._query;
  };
  Evernote.SearchHelper.prototype.getNoteFilter = function() {
    return this._filter;
  };
  Evernote.SearchHelper.prototype.isCaching = function() {
    return this._caching == true;
  };
  Evernote.SearchHelper.prototype.setCaching = function(bool) {
    this._caching = (bool) ? true : false;
  };
  Evernote.SearchHelper.prototype.doSearch = function() {
    var self = this;
    this.abort();
    if (this.query) {
      this._filter.setWords(this.query);
      this.wait();
      this._ajax = Evernote.context.remote.findNotes(this._filter, 0, 1,
          function(response, textStatus, xhr) {
            self._response = response;
            self._xhr = xhr;
            if (response.isResult()
                && typeof response.result["noteList"] == 'object') {
              LOG.debug("Retreived search results");
              self._result = response.result.noteList;
            } else {
              LOG.debug("Error retreiving results: " + textStatus);
            }
            self.signal();
          }, function(xhr, textStatus, error) {
            if (xhr && xhr.readyState == 4) {
              LOG.error("HTTP Error status: " + xhr.status);
            } else if (xhr) {
              LOG.error("HTTP Error readyState: " + xhr.readyState);
            } else {
              LOG.error("HTTP Error (Unknown)");
            }
            self._xhr = xhr;
            self.signal();
          }, true);
    } else {
      LOG.debug("Not searching cuz there is no search query...");
      self.signal();
    }
  };
  Evernote.SearchHelper.prototype.abort = function() {
    if (this._ajax && typeof this._ajax["abort"] == 'function') {
      this._ajax.abort();
    }
  };
  Evernote.SearchHelper.prototype.reset = function() {
    this.initializeNoteFilter();
    this._result = null;
    this._response = null;
    this._sema = 0;
  };
  Evernote.SearchHelper.prototype.getResult = function() {
    return this._result;
  };
  Evernote.SearchHelper.prototype.getResponse = function() {
    return this._response;
  };
  Evernote.SearchHelper.prototype.hasResults = function() {
    return this._result && typeof this._result["totalNotes"] == 'number'
        && this._result["totalNotes"] > 0;
  };
  Evernote.SearchHelper.prototype.isTransportError = function() {
    return (this._xhr.readyState != 4 || this._xhr.status < 200 || this._xhr.status >= 400);
  };
  Evernote.SearchHelper.prototype.setSuccessHandler = function(fn) {
    if (typeof fn == 'function' || fn == null) {
      this._successHandler = fn;
    }
  };
  Evernote.SearchHelper.prototype.getSuccessHandler = function() {
    return this._successHandler;
  };
  Evernote.SearchHelper.prototype.setErrorHandler = function(fn) {
    if (typeof fn == 'function' || fn == null) {
      this._errorHandler = fn;
    }
  };
  Evernote.SearchHelper.prototype.getErrorHandler = function() {
    return this._errorHandler;
  };
  Evernote.SearchHelper.prototype._handleResult = function() {
    if (this.result) {
      this._handleSuccess();
    } else {
      this._handleError();
    }
  };
  Evernote.SearchHelper.prototype._handleSuccess = function() {
    if (typeof this.successHandler == 'function') {
      this.successHandler(this.result, this);
    }
  };
  Evernote.SearchHelper.prototype._handleError = function() {
    if (typeof this.errorHandler == 'function') {
      this.errorHandler(this);
    }
  };
})();

(function() {
  var LOG = null;
  Evernote.SearchHelperContentScripting = function SearchHelperContentScripting() {
    LOG = Evernote.chromeExtension.logger;
    this.initialize();
  };

  Evernote.inherit(Evernote.SearchHelperContentScripting,
      Evernote.AbstractContentScripting, true);

  Evernote.SearchHelperContentScripting.CONTENT_SCRIPTS = [ "/libs/evernote-cr/evernoteContentSearchHelper.js" ];

  Evernote.SearchHelperContentScripting.prototype.getRequiredScriptNames = function() {
    return [].concat(this.constructor.CONTENT_SCRIPTS);
  };

  Evernote.SearchHelperContentScripting.prototype.appendContentMessage = function(
      tabId, message) {
    LOG.debug("SearchHelperContentScripting.appendContentMessage");
    var self = this;
    this
        .executeScript(
            tabId,
            {
              code : "Evernote.SearchHelperContentScript.getInstance().removeErrorMessage(); Evernote.SearchHelperContentScript.getInstance().appendMessage(\"#res\", \""
                  + message + "\");"
            });
  };
  Evernote.SearchHelperContentScripting.prototype.prependContentMessage = function(
      tabId, message) {
    LOG.debug("SearchHelperContentScripting.prependContentMessage");
    var self = this;
    this
        .executeScript(
            tabId,
            {
              code : "Evernote.SearchHelperContentScript.getInstance().removeErrorMessage(); Evernote.SearchHelperContentScript.getInstance().prependMessage(\"#res\", \""
                  + message + "\");"
            });
  };
  Evernote.SearchHelperContentScripting.prototype.clearContentMessages = function(
      tabId) {
    LOG.debug("SearchHelperContentScripting.clearContentMessages");
    var self = this;
    this
        .executeScript(
            tabId,
            {
              code : "Evernote.SearchHelperContentScript.getInstance().removeResultStats();"
            });
  };
  Evernote.SearchHelperContentScripting.prototype.appendContentErrorMessage = function(
      tabId, message) {
    LOG.debug("SearchHelperContentScripting.appendContentErrorMessage");
    var self = this;
    this
        .executeScript(
            tabId,
            {
              code : "Evernote.SearchHelperContentScript.getInstance().removeMessage(); Evernote.SearchHelperContentScript.getInstance().appendErrorMessage(\"#res\", \""
                  + message + "\");"
            });
  };
  Evernote.SearchHelperContentScripting.prototype.prependContentErrorMessage = function(
      tabId, message) {
    LOG.debug("SearchHelperContentScripting.prependContentErrorMessage");
    var self = this;
    this
        .executeTimedScript(
            tabId,
            {
              code : "Evernote.SearchHelperContentScript.getInstance().removeMessage(); Evernote.SearchHelperContentScript.getInstance().prependErrorMessage(\"#res\", \""
                  + message + "\");"
            });
  };
  Evernote.SearchHelperContentScripting.prototype.prependLinkedUrls = function(
      tabId, notes, words) {
    LOG.debug("SearchHelperContentScripting.prependLinkedUrls");
    this.markLinkedUrls(tabId, notes, words, true);
  };
  Evernote.SearchHelperContentScripting.prototype.appendLinkedUrls = function(
      tabId, notes, words) {
    LOG.debug("SearchHelperContentScripting.appendLinkedUrls");
    this.markLinkedUrls(tabId, notes, words, false);
  };
  Evernote.SearchHelperContentScripting.prototype.markLinkedUrls = function(
      tabId, notes, words, prepend) {
    LOG.debug("SearchHelperContentScripting.markLinkedUrls");
    if (notes instanceof Array) {
      LOG.debug("Checking " + notes.length + " notes");
      var linkedNotes = {
        urls : {},
        domains : {}
      };
      var count = 0;
      for ( var i = 0; i < notes.length; i++) {
        var note = notes[i];
        try {
          var notebook = Evernote.context.getNotebookByGuid(note.notebookGuid);
          var sourceUrl = note.attributes.sourceURL;
          if (sourceUrl && notebook && notebook.name) {
            var theUrl = sourceUrl.replace(/^.*:\/\//, "");
            var theDomain = theUrl.replace(/^([^\/]+).*$/, "$1");
            linkedNotes.urls[theUrl] = chrome.i18n.getMessage(
                "searchHelperUrlInEvernote", [
                    Evernote.context.getNoteInNotebookUrl(note.guid,
                        notebook.guid, words), notebook.name ]);
            linkedNotes.domains[theDomain] = chrome.i18n.getMessage(
                "searchHelperDomainInEvernote", [
                    Evernote.context.getEvernoteSearchUrl("sourceUrl:http://"
                        + theDomain + " sourceUrl:https://" + theDomain, true),
                    theDomain ]);
            count++;
          }
        } catch (e) {
          LOG
              .debug("Could not determine enough information about a linked note: "
                  + e);
        }
      }
      LOG.debug("Found " + count + " linked urls");
      var self = this;
      if (count > 0) {
        this
            .executeScript(
                tabId,
                {
                  code : "Evernote.SearchHelperContentScript.getInstance().markLinkedUrls(\"li.knavi\", "
                      + JSON.stringify(linkedNotes) + ", " + prepend + ");"
                });
      }
    }
  };
})();


(function() {
  var LOG = null;
  Evernote.ClipperContentScripting = function ClipperContentScripting() {
    LOG = Evernote.chromeExtension.logger;
    this.initialize();
  };

  Evernote.inherit(Evernote.ClipperContentScripting,
      Evernote.AbstractContentScripting, true);

  Evernote.ClipperContentScripting.CONTENT_SCRIPTS = [ "/libs/evernote-cr/evernoteContentClipper.js" ];

  Evernote.ClipperContentScripting.prototype.getRequiredScriptNames = function() {
    return [].concat(this.constructor.CONTENT_SCRIPTS);
  };

  Evernote.ClipperContentScripting.prototype.createInstance = function() {
    var code = "Evernote.ContentClipper().destroyInstance();";
    code += "Evernote.ContentClipper().getInstance();";
  };

  Evernote.ClipperContentScripting.prototype.perform = function(tabId,
      fullPageOnly, stylingStrategy, showWait, callback) {
    LOG.debug("ClipperContentScripting.perform(" + tabId + ", " + fullPageOnly
        + ", " + stylingStrategy + ", " + showWait + ")");
    if (!stylingStrategy) {
      stylingStrategy = "Evernote.ClipFullStylingStrategy";
    }
    var _fullPageOnly = (fullPageOnly) ? "true" : "false";
    var _stylingStrategy = (stylingStrategy) ? stylingStrategy : "null";
    var _showWait = (showWait) ? "true" : "false";
    var code = this.createInstance();
    code += "Evernote.ContentClipper.getInstance().perform(" + _fullPageOnly + ", "
        + _stylingStrategy + ", " + _showWait + ");";
    LOG.debug("Executing: " + code);
    this.executeScript(tabId, {
      code : code
    }, callback);
  };

})();

