var Evernote={};Evernote.inherit=function(a,d,c){if(typeof d.constructor=="function"){a.prototype=new d;a.prototype.constructor=a;a.parent=d.prototype}else{a.prototype=d;a.prototype.constructor=a;a.parent=d}if(c){for(var b in d.prototype.constructor){if(b!="parent"&&b!="prototype"&&b!="javaClass"&&d.constructor[b]!=d.prototype.constructor[b]){a.prototype.constructor[b]=d.prototype.constructor[b]}}}if(typeof a.prototype.handleInheritance=="function"){a.prototype.handleInheritance.apply(a,[a,d,c])}};Evernote.inherits=function(a,b){var c=a;while(c&&typeof c.parent!="undefined"){if(c.parent.constructor==b){return true}else{c=c.parent.constructor}}return false};Evernote.mixin=function(c,a,e){var d=(typeof c=="function")?c.prototype:c;for(var b in a.prototype){var f=to=b;if(typeof e=="object"&&e&&typeof e[b]!="undefined"){to=e[b]}d[to]=a.prototype[f]}};Evernote.extendObject=function(d,b,a){if(typeof b=="object"&&b!=null){for(var c in b){if(a&&typeof b[c]=="object"&&b[c]!=null&&typeof d[c]=="object"&&d[c]!=null){Evernote.extendObject(d[c],b[c],a)}else{d[c]=b[c]}}}};Evernote.Logger=function Logger(c,d,b){this.__defineGetter__("level",this.getLevel);this.__defineSetter__("level",this.setLevel);this.__defineGetter__("scope",this.getScope);this.__defineSetter__("scope",this.setScope);this.__defineGetter__("scopeName",this.getScopeName);this.__defineGetter__("scopeNameAsPrefix",this.getScopeNameAsPrefix);this.__defineGetter__("useTimestamp",this.isUseTimestamp);this.__defineSetter__("useTimestamp",this.setUseTimestamp);this.__defineGetter__("usePrefix",this.isUsePrefix);this.__defineSetter__("usePrefix",this.setUsePrefix);this.__defineGetter__("enabled",this.isEnabled);this.__defineSetter__("enabled",this.setEnabled);this.scope=c||arguments.callee.caller;this.level=d;if(typeof b!="undefined"&&b instanceof Evernote.LoggerImpl){this.impl=b}else{var a=Evernote.LoggerImplFactory.getImplementationFor(navigator);if(a instanceof Array){this.impl=new Evernote.LoggerChainImpl(this,a)}else{this.impl=new a(this)}}};Evernote.Logger.LOG_LEVEL_DEBUG=0;Evernote.Logger.LOG_LEVEL_INFO=1;Evernote.Logger.LOG_LEVEL_WARN=2;Evernote.Logger.LOG_LEVEL_ERROR=3;Evernote.Logger.LOG_LEVEL_EXCEPTION=4;Evernote.Logger.LOG_LEVEL_OFF=5;Evernote.Logger.GLOBAL_LEVEL=Evernote.Logger.LOG_LEVEL_ERROR;Evernote.Logger.DEBUG_PREFIX="[DEBUG] ";Evernote.Logger.INFO_PREFIX="[INFO] ";Evernote.Logger.WARN_PREFIX="[WARN] ";Evernote.Logger.ERROR_PREFIX="[ERROR] ";Evernote.Logger.EXCEPTION_PREFIX="[EXCEPTION] ";Evernote.Logger._instances={};Evernote.Logger.getInstance=function(b){b=b||arguments.callee.caller;var a=(typeof b=="function")?b.name:b.constructor.name;if(typeof this._instances[a]=="undefined"){this._instances[a]=new Evernote.Logger(b)}return this._instances[a]};Evernote.Logger.setInstance=function(a){this._instance=a};Evernote.Logger.destroyInstance=function(b){b=b||arguments.callee.caller;var a=(typeof b=="function")?b.name:b.constructor.name;delete this._instances[a]};Evernote.Logger.setGlobalLevel=function(c){var a=parseInt(c);if(isNaN(a)){return}Evernote.Logger.GLOBAL_LEVEL=a;if(this._instances){for(var b in this._instances){this._instances[b].setLevel(a)}}};Evernote.Logger.setLevel=function(b){if(this._instances){for(var a in this._instances){this._instances[a].setLevel(b)}}};Evernote.Logger.enableImplementor=function(a){if(this._instances){for(var b in this._instances){this._instances[b].enableImplementor(a)}}if(a){a.protoEnabled=true}};Evernote.Logger.disableImplementor=function(a){if(this._instances){for(var b in this._instances){this._instances[b].disableImplementor(a)}}if(a){a.protoEnabled=false}};Evernote.Logger.prototype._level=0;Evernote.Logger.prototype._scope=null;Evernote.Logger.prototype._usePrefix=true;Evernote.Logger.prototype._useTimestamp=true;Evernote.Logger.prototype._enabled=true;Evernote.Logger.prototype.getImplementor=function(a){if(a){return this.impl.answerImplementorInstance(a)}else{return this.impl}};Evernote.Logger.prototype.enableImplementor=function(a){if(a){var b=this.getImplementor(a);if(b){b.enabled=true}}else{this.impl.enabled=true}};Evernote.Logger.prototype.disableImplementor=function(a){if(a){var b=this.getImplementor(a);if(b){b.enabled=false}}else{this.impl.enabled=false}};Evernote.Logger.prototype.setLevel=function(a){this._level=parseInt(a);if(isNaN(this._level)){this._level=Evernote.Logger.GLOBAL_LEVEL}};Evernote.Logger.prototype.getLevel=function(){return this._level};Evernote.Logger.prototype.setScope=function(a){if(typeof a=="function"){this._scope=a}else{if(typeof a=="object"&&a!=null){this._scope=a.constructor}}};Evernote.Logger.prototype.getScope=function(){return this._scope};Evernote.Logger.prototype.getScopeName=function(){if(this.scope){return this.scope.name}else{return""}};Evernote.Logger.prototype.getScopeNameAsPrefix=function(){var a=this.scopeName;return(a)?"["+a+"] ":""};Evernote.Logger.prototype._padNumber=function(c,a){var b="0";c=parseInt(c);if(isNaN(c)){c=0}var e=(c>=0)?true:false;var d=""+Math.abs(c);while(d.length<a){d=b+d}if(!e){d="-"+d}return d};Evernote.Logger.prototype.getPrefix=function(f){var i="";if(this.useTimestamp){var g=new Date();var a=this._padNumber((g.getMonth()+1),2);var j=this._padNumber(g.getDate(),2);var e=this._padNumber(g.getHours(),2);var b=this._padNumber(g.getMinutes(),2);var k=this._padNumber(g.getSeconds(),2);var c=this._padNumber((0-(g.getTimezoneOffset()/60)*100),4);i+=a+"/"+j+"/"+g.getFullYear()+" "+e+":"+b+":"+k+"."+g.getMilliseconds()+" "+c+" "}if(this.usePrefix){i+=f}i+=this.scopeNameAsPrefix;return i};Evernote.Logger.prototype.isUsePrefix=function(){return this._usePrefix};Evernote.Logger.prototype.setUsePrefix=function(a){this._usePrefix=(a)?true:false};Evernote.Logger.prototype.isUseTimestamp=function(){return this._useTimestamp};Evernote.Logger.prototype.setUseTimestamp=function(a){this._useTimestamp=(a)?true:false};Evernote.Logger.prototype.isEnabled=function(){return this._enabled};Evernote.Logger.prototype.setEnabled=function(a){this._enabled=(a)?true:false};Evernote.Logger.prototype.isDebugEnabled=function(){return(this.enabled&&this.level<=Evernote.Logger.LOG_LEVEL_DEBUG)};Evernote.Logger.prototype.dump=function(a){if(this.enabled&&this.impl.enabled){this.impl.dir(a)}};Evernote.Logger.prototype.dir=function(a){if(this.enabled&&this.impl.enabled){this.impl.dir(a)}};Evernote.Logger.prototype.trace=function(){if(this.enabled&&this.impl.enabled){this.impl.trace()}};Evernote.Logger.prototype.debug=function(a){if(this.enabled&&this.impl.enabled&&this.level<=Evernote.Logger.LOG_LEVEL_DEBUG){this.impl.debug(this.getPrefix(this.constructor.DEBUG_PREFIX)+a)}};Evernote.Logger.prototype.info=function(a){if(this.enabled&&this.impl.enabled&&this.level<=Evernote.Logger.LOG_LEVEL_INFO){this.impl.info(this.getPrefix(this.constructor.INFO_PREFIX)+a)}};Evernote.Logger.prototype.warn=function(a){if(this.enabled&&this.impl.enabled&&this.level<=Evernote.Logger.LOG_LEVEL_WARN){this.impl.warn(this.getPrefix(this.constructor.WARN_PREFIX)+a)}};Evernote.Logger.prototype.error=function(a){if(this.enabled&&this.impl.enabled&&this.level<=Evernote.Logger.LOG_LEVEL_ERROR){this.impl.error(this.getPrefix(this.constructor.ERROR_PREFIX)+a)}};Evernote.Logger.prototype.exception=function(a){if(this.enabled&&this.impl.enabled&&this.level<=Evernote.Logger.LOG_LEVEL_EXCEPTION){this.impl.exception(this.getPrefix(this.constructor.EXCEPTION_PREFIX)+a)}};Evernote.Logger.prototype.alert=function(a){if(this.enabled&&this.impl.enabled){this.impl.alert(a)}};Evernote.Logger.prototype.clear=function(){this.impl.clear()};Evernote.LoggerImpl=function LoggerImpl(a){this.__defineGetter__("logger",this.getLogger);this.__defineSetter__("logger",this.setLogger);this.__defineGetter__("enabled",this.isEnabled);this.__defineSetter__("enabled",this.setEnabled);this.__defineGetter__("protoEnabled",this.isProtoEnabled);this.__defineSetter__("protoEnabled",this.setProtoEnabled);this.initialize(a)};Evernote.LoggerImpl.ClassRegistry=new Array();Evernote.LoggerImpl.isResponsibleFor=function(a){return false};Evernote.LoggerImpl.prototype.handleInheritance=function(b,a){Evernote.LoggerImpl.ClassRegistry.push(b)};Evernote.LoggerImpl.prototype._logger=null;Evernote.LoggerImpl.prototype._enabled=false;Evernote.LoggerImpl.prototype.initialize=function(a){this.logger=a};Evernote.LoggerImpl.prototype.answerImplementorInstance=function(a){if(this.constructor==a){return this}};Evernote.LoggerImpl.prototype.isEnabled=function(){return this._enabled};Evernote.LoggerImpl.prototype.setEnabled=function(a){this._enabled=(a)?true:false};Evernote.LoggerImpl.prototype.isProtoEnabled=function(){return this.constructor.prototype._enabled};Evernote.LoggerImpl.prototype.setProtoEnabled=function(a){this.constructor.prototype._enabled=(a)?true:false};Evernote.LoggerImpl.prototype.getLogger=function(){return this._logger};Evernote.LoggerImpl.prototype.setLogger=function(a){if(a instanceof Evernote.Logger){this._logger=a}};Evernote.LoggerImpl.prototype.dir=function(a){};Evernote.LoggerImpl.prototype.trace=function(){};Evernote.LoggerImpl.prototype.debug=function(a){};Evernote.LoggerImpl.prototype.info=function(a){};Evernote.LoggerImpl.prototype.warn=function(a){};Evernote.LoggerImpl.prototype.error=function(a){};Evernote.LoggerImpl.prototype.exception=function(a){};Evernote.LoggerImpl.prototype.alert=function(a){};Evernote.LoggerImpl.prototype.clear=function(){};Evernote.LoggerChainImpl=function LoggerChainImpl(a,b){this.initialize(a,b)};Evernote.inherit(Evernote.LoggerChainImpl,Evernote.LoggerImpl,true);Evernote.LoggerChainImpl.prototype._impls=null;Evernote.LoggerChainImpl.prototype._enabled=true;Evernote.LoggerChainImpl.prototype.initialize=function(a,e){Evernote.LoggerChainImpl.parent.initialize.apply(this,[a]);var c=[].concat(e);this._impls=[];for(var b=0;b<c.length;b++){var d=c[b];this._impls.push(new d(a))}};Evernote.LoggerChainImpl.prototype.answerImplementorInstance=function(a){for(var b=0;b<this._impls.length;b++){var c=this._impls[b].answerImplementorInstance(a);if(c){return c}}};Evernote.LoggerChainImpl.prototype.dir=function(b){for(var a=0;a<this._impls.length;a++){if(this._impls[a].enabled){this._impls[a].dir(b)}}};Evernote.LoggerChainImpl.prototype.trace=function(){for(var a=0;a<this._impls.length;a++){if(this._impls[a].enabled){this._impls[a].trace(obj)}}};Evernote.LoggerChainImpl.prototype.debug=function(b){for(var a=0;a<this._impls.length;a++){if(this._impls[a].enabled){this._impls[a].debug(b)}}};Evernote.LoggerChainImpl.prototype.info=function(b){for(var a=0;a<this._impls.length;a++){if(this._impls[a].enabled){this._impls[a].info(b)}}};Evernote.LoggerChainImpl.prototype.warn=function(b){for(var a=0;a<this._impls.length;a++){if(this._impls[a].enabled){this._impls[a].warn(b)}}};Evernote.LoggerChainImpl.prototype.error=function(b){for(var a=0;a<this._impls.length;a++){if(this._impls[a].enabled){this._impls[a].error(b)}}};Evernote.LoggerChainImpl.prototype.exception=function(b){for(var a=0;a<this._impls.length;a++){if(this._impls[a].enabled){this._impls[a].exception(b)}}};Evernote.LoggerChainImpl.prototype.alert=function(b){for(var a=0;a<this._impls.length;a++){if(this._impls[a].enabled){this._impls[a].alert(b)}}};Evernote.LoggerChainImpl.prototype.clear=function(){for(var a=0;a<this._impls.length;a++){if(this._impls[a].enabled){this._impls[a].clear()}}};Evernote.LoggerImplFactory={getImplementationFor:function(a){var c=Evernote.LoggerImpl.ClassRegistry;var d=[];for(var b=0;b<c.length;b++){if(typeof c[b]=="function"&&typeof c[b].isResponsibleFor=="function"&&c[b].isResponsibleFor(a)){d.push(c[b])}}if(d.length==0){return Evernote.LoggerImpl}else{if(d.length==1){return d[0]}}return d}};Evernote.WebKitLoggerImpl=function WebKitLoggerImpl(a){this.initialize(a)};Evernote.inherit(Evernote.WebKitLoggerImpl,Evernote.LoggerImpl,true);Evernote.WebKitLoggerImpl.isResponsibleFor=function(a){return a.userAgent.toLowerCase().indexOf("AppleWebKit/")>0};Evernote.WebKitLoggerImpl.prototype._enabled=true;Evernote.WebKitLoggerImpl.prototype.dir=function(a){console.group(this.logger.scopeName);console.dir(a);console.groupEnd()};Evernote.WebKitLoggerImpl.prototype.trace=function(){console.group(this.logger.scopeName);console.trace();console.groupEnd()};Evernote.WebKitLoggerImpl.prototype.debug=function(a){console.debug(a)};Evernote.WebKitLoggerImpl.prototype.info=function(a){console.info(a)};Evernote.WebKitLoggerImpl.prototype.warn=function(a){console.warn(a)};Evernote.WebKitLoggerImpl.prototype.error=function(a){console.error(a)};Evernote.WebKitLoggerImpl.prototype.exception=function(a){console.error(a);this.trace()};Evernote.WebKitLoggerImpl.prototype.alert=function(a){alert(a)};Evernote.Utils=new function Utils(){};Evernote.Utils.extendObject=function(e,c,d,f){if(typeof e=="object"&&e!=null&&typeof c=="object"&&c!=null){for(var g in c){if(typeof e[g]=="undefined"||f){e[g]=c[g]}else{if(d){arguments.callee.apply(this,[e[g],c[g],d,f])}}}}};Evernote.Utils.importConstructs=function(c,b,f){var g=(f instanceof Array)?f:[f];for(var d=0;d<g.length;d++){var e=g[d].split(".");var h=b;var j=c;for(var a=0;a<e.length;a++){if(a==e.length-1){if(typeof h[e[a]]=="undefined"){h[e[a]]=j[e[a]]}else{Evernote.Utils.extendObject(h[e[a]],j[e[a]],true)}}else{j=j[e[a]];if(typeof h[e[a]]=="undefined"){h[e[a]]={}}h=h[e[a]]}}}};Evernote.Utils.separateString=function(f,e){if(typeof f!="string"){return f}if(typeof e!="string"){e=","}var d=f.split(e);var c=new Array();for(var b=0;b<d.length;b++){if(typeof d[b]!="string"){continue}var a=Evernote.Utils.trim(d[b]);if(a&&a.length>0){c.push(a)}}return c};Evernote.Utils.trim=function(a){if(typeof a!="string"){return a}return a.replace(/^\s+/,"").replace(/\s+$/,"")};Evernote.Utils.shortenString=function(d,a,c){var b=d+"";if(b.length>a){b=b.substring(0,Math.max(0,a-((typeof c=="string")?c.length:0)));if(typeof c=="string"){b+=c}}return b};Evernote.Utils.htmlEntities=function(a){return $("<div/>").text(a).html()};Evernote.Utils.urlPath=function(a){if(typeof a=="string"){var b=a.replace(/^[^:]+:\/+([^\/]+)/,"");if(b.indexOf("/")==0){return b.replace(/^(\/[^\?\#]*).*$/,"$1")}}return""};Evernote.Utils.urlDomain=function(b,a){if(typeof b=="string"){var c=new RegExp("^[^:]+:/+([^/"+((a)?"":":")+"]+).*$");return b.replace(c,"$1")}return b};Evernote.Utils.urlTopDomain=function(b){var a=b;if(typeof b=="string"){var a=Evernote.Utils.urlDomain(b);if(a.toLowerCase().indexOf("www.")==0){a=a.substring(4)}}return a};Evernote.Utils.urlQueryValue=function(f,c){if(typeof c=="string"&&typeof f=="string"&&c.indexOf("?")>=0){var b=c.split(/[\?\#\&]+/).slice(1);var a=f.toLowerCase();var e=new Array();for(var d=0;d<b.length;d++){var h=b[d].split("=",2);if(h[0].toLowerCase()==a){var g=(h[1])?h[1].replace(/\+/g," "):h[1];e.push(decodeURIComponent(g))}}if(e.length>0){return e[e.length-1]}}return null};Evernote.Utils.urlProto=function(b){if(typeof b=="string"){var a=-1;if((a=b.indexOf(":/"))>0){return b.substring(0,a).toLowerCase()}}return null};Evernote.Utils.urlToSearchQuery=function(a,c){var b=Evernote.Utils.urlProto(a);if(b&&b.indexOf("http")==0){return Evernote.Utils.httpUrlToSearchQuery(a,c)}else{if(b&&b=="file"){return Evernote.Utils.fileUrlToSearchQuery(a,c)}else{if(b){return Evernote.Utils.anyProtoUrlToSearchQuery(a,c)}else{return Evernote.Utils.anyUrlToSearchQuery(a,c)}}}};Evernote.Utils.httpUrlToSearchQuery=function(a,f){var g=(typeof f=="string")?f:"";var e=Evernote.Utils.urlDomain((a+"").toLowerCase());var d=[(g+"http://"+e+"*"),(g+"https://"+e+"*")];if(e.match(/[^0-9\.]/)){var b=(e.indexOf("www.")==0)?e.substring(4):("www."+e);d=d.concat([(g+"http://"+b+"*"),(g+"https://"+b+"*")])}var c="any: "+d.join(" ");return c};Evernote.Utils.fileUrlToSearchQuery=function(a,c){var d=(typeof c=="string")?c:"";var b=d+"file:*";return b};Evernote.Utils.anyProtoUrlToSearchQuery=function(b,g){var h=(typeof g=="string")?g:"";var c=Evernote.Utils.urlProto(b);var a=c+"s";if(c.indexOf("s")==(c.length-1)){c=c.substring(0,(c.length-1));a=c+"s"}var f=Evernote.Utils.urlDomain(b);var e=[(h+c+"://"+f+"*"),(h+a+"://"+f+"*")];var d="any: "+e.join(" ");return d};Evernote.Utils.anyUrlToSearchQuery=function(a,c){var d=(typeof c=="string")?c:"";var b=d+a+"*";return b};Evernote.Utils.urlSuffix="...";Evernote.Utils.shortUrl=function(c,a){var b=c;if(typeof c=="string"){if(b.indexOf("file:")==0){b=decodeURIComponent(b.replace(/^file:.*\/([^\/]+)$/,"$1"));if(typeof a=="number"&&!isNaN(a)&&b.length>a){b=b.substring(0,a);b+=""+Evernote.Utils.urlSuffix}}else{b=b.replace(/^([a-zA-Z]+:\/+)?([^\/]+).*$/,"$2");if(typeof a=="number"&&!isNaN(a)&&b.length>a){b=b.substring(0,a);b+=""+Evernote.Utils.urlSuffix}else{if(c.substring(c.indexOf(b)+b.length).length>2){b+="/"+Evernote.Utils.urlSuffix}}}}return b};Evernote.Utils.appendSearchQueryToUrl=function(a,d){var c=a+"";c+=(c.indexOf("?")>=0)?"&":"?";if(typeof d=="string"){c+=d}else{if(typeof d=="object"&&d){for(var b in d){c+=encodeURIComponent(b)+"="+encodeURIComponent(d[b])+"&"}}}if(c.charAt(c.length-1)=="&"){c=c.substring(0,c.length-1)}return c};Evernote.Utils=Evernote.Utils||new function Utils(){};Evernote.Utils.MESSAGE_ATTR="message";Evernote.Utils.MESSAGE_DATA_ATTR="messagedata";Evernote.Utils.LOCALIZED_ATTR="localized";Evernote.Utils.BADGE_AUTOSAVED_TEXT="+";Evernote.Utils.BADGE_NORMAL_COLOR=[255,0,0,255];Evernote.Utils.BADGE_UPLOADING_COLOR=[255,255,0,255];Evernote.Utils.updateBadge=function(d,b){var a=Evernote.chromeExtension.logger;a.debug("Utils.updateBadge");var c=null;if(d){if(d.clipProcessor.length>0){Evernote.Utils.setBadgeBackgroundColor(Evernote.Utils.BADGE_UPLOADING_COLOR,b);a.debug("Badge indicates pending notes: "+d.clipProcessor.length);Evernote.Utils.setBadgeText(d.clipProcessor.length,b);Evernote.Utils.setBadgeTitle(chrome.i18n.getMessage("BrowserActionTitlePending"),b)}else{if(typeof b=="number"&&chrome.extension&&typeof chrome.extension.getBackgroundPage().Evernote.SearchHelper!="undefined"&&(c=chrome.extension.getBackgroundPage().Evernote.SearchHelper.getInstance(b))&&c.hasResults()){Evernote.Utils.setBadgeBackgroundColor(Evernote.Utils.BADGE_NORMAL_COLOR,b);a.debug("Badge indicates simsearch results: "+c.result.totalNotes);Evernote.Utils.setBadgeText(c.result.totalNotes,b);Evernote.Utils.setBadgeTitle(chrome.i18n.getMessage("BrowserActionTitle"),b)}else{if(d.hasAutosavedNote()){Evernote.Utils.setBadgeBackgroundColor(Evernote.Utils.BADGE_NORMAL_COLOR,b);a.debug("Badge indicates auto-saved note");Evernote.Utils.setBadgeText(Evernote.Utils.BADGE_AUTOSAVED_TEXT,b);Evernote.Utils.setBadgeTitle(chrome.i18n.getMessage("BrowserActionTitleUnsaved"),b)}else{a.debug("Clearing badge for there's nothing interesting to show");Evernote.Utils.clearBadge(b);Evernote.Utils.setBadgeTitle(chrome.i18n.getMessage("BrowserActionTitle"),b)}}}}};Evernote.Utils.clearBadge=function(a){var b={text:""};if(typeof a=="number"){b.tabId=a;chrome.browserAction.setBadgeText(b)}else{this.clearAllBadges()}};Evernote.Utils.clearAllBadges=function(){this.doInEveryNormalTab(function(a){chrome.browserAction.setBadgeText({tabId:a.id,text:""})},true)};Evernote.Utils.setBadgeBackgroundColor=function(a,b){var c={color:a};if(typeof b=="number"){c.tabId=b;chrome.browserAction.setBadgeBackgroundColor(c)}else{this.doInEveryNormalTab(function(d){c.tabId=d.id;chrome.browserAction.setBadgeBackgroundColor(c)},true)}};Evernote.Utils.setBadgeText=function(a,b){if(a){var c={text:""+a};if(typeof b=="number"){c.tabId=b;chrome.browserAction.setBadgeText(c)}else{this.doInEveryNormalTab(function(d){console.log("Setting badge in tab id: "+d.id);c.tabId=d.id;chrome.browserAction.setBadgeText(c)},true)}}else{if(a==null){Evernote.Utils.clearBadge(b)}}};Evernote.Utils.setBadgeTitle=function(c,a){if(c){var b={title:""+c};if(typeof a=="number"){b.tabId=a;chrome.browserAction.setTitle(b)}else{this.doInEveryNormalTab(function(d){b.tabId=d.id;chrome.browserAction.setTitle(b)},true)}}else{if(c==null){Evernote.Utils.clearBadgeTitle(a)}}};Evernote.Utils.clearBadgeTitle=function(a){var b={title:""};if(typeof a=="number"){b.tabId=a;chrome.browserAction.setTitle(b)}else{this.doInEveryNormalTab(function(c){b.tabId=c.id;chrome.browserAction.setTitle(b)},true)}};Evernote.Utils.doInEveryNormalTab=function(b,a){chrome.windows.getAll({populate:true},function(e){for(var c=0;c<e.length;c++){if(e[c].type=="normal"){for(var d=0;d<e[c].tabs.length;d++){if(!a||e[c].tabs[d].selected){b(e[c].tabs[d],e[c])}}}}})};Evernote.Utils.localizeBlock=function(d){if(d.attr(Evernote.Utils.MESSAGE_ATTR)){Evernote.Utils.localizeElement(d)}var c=d.find("["+Evernote.Utils.MESSAGE_ATTR+"]");for(var a=0;a<c.length;a++){var b=$(c.get(a));Evernote.Utils.localizeElement(b)}};Evernote.Utils.extractLocalizationField=function(a){if(typeof a.attr=="function"&&a.attr(Evernote.Utils.MESSAGE_ATTR)){return a.attr(Evernote.Utils.MESSAGE_ATTR)}else{return null}};Evernote.Utils.extractLocalizationDataField=function(element){if(typeof element.attr=="function"&&element.attr(Evernote.Utils.MESSAGE_DATA_ATTR)){var v=element.attr(Evernote.Utils.MESSAGE_DATA_ATTR);try{v=eval(v)}catch(e){}if(!(v instanceof Array)){v=[v]}return v}else{return null}};Evernote.Utils.localizeElement=function(b,c){if(!c&&b.attr(Evernote.Utils.LOCALIZED_ATTR)&&b.attr(Evernote.Utils.LOCALIZED_ATTR=="true")){return}var d=Evernote.Utils.extractLocalizationField(b);var a=Evernote.Utils.extractLocalizationDataField(b);if(d){if(a){var e=chrome.i18n.getMessage(d,a)}else{var e=chrome.i18n.getMessage(d)}if(b.attr("tagName")=="INPUT"){b.val(e)}else{b.html(e)}b.attr(Evernote.Utils.LOCALIZED_ATTR,"true")}};Evernote.Utils.notifyExtension=function(a,b){chrome.windows.getCurrent(function(c){chrome.tabs.getSelected(c.id,function(e){var f={tab:e,id:chrome.i18n.getMessage("@@extension_id")};var d=b||function(){};chrome.extension.onRequest.dispatch(a,f,d);chrome.extension.sendRequest(a,d)})})};Evernote.Utils._setDesktopNotificationAttributes=function(c,a){if(c&&typeof a=="object"&&a){for(var b in a){c[b]=a[b]}}};Evernote.Utils.notifyDesktop=function(e,b,c,a){var d=webkitNotifications.createNotification("images/en_app_icon-48.png",e,b);this._setDesktopNotificationAttributes(d,a);d.show();if(typeof c=="number"){setTimeout(function(){d.cancel()},c)}return d};Evernote.Utils.notifyDesktopWithHTML=function(b,c,a){var d=webkitNotifications.createHTMLNotification(b);this._setDesktopNotificationAttributes(d,a);d.show();if(typeof c=="number"){setTimeout(function(){d.cancel()},c)}return d};Evernote.Utils.openWindow=function(a){var b=chrome.extension.getBackgroundPage();b.Evernote.chromeExtension.openWindow(a)};Evernote.Utils.getPostData=function(j){if(typeof j=="undefined"){j=window.location.search.replace(/^\?/,"")}var a={};if(j){var h=j.split("&");for(var d=0;d<h.length;d++){var f=h[d].split("=");var c=unescape(f[0]);var b=(f[1])?unescape(f[1]):null;if(b){try{a[c]=JSON.parse(b)}catch(g){a[c]=b}}else{a[c]=b}}}return a};Evernote.Utils.getLocalizedMessage=function(a,b){if(typeof chrome!="undefined"&&typeof chrome.i18n.getMessage=="function"){return chrome.i18n.getMessage(a,b)}else{return a}};Evernote.Utils.extractHttpErrorMessage=function(c,d,a){if(this.quiet){return}if(c.readyState==4){var b=this.getLocalizedMessage("Error_HTTP_Transport",[(""+c.status),((typeof a=="string")?a:"")])}else{var b=this.getLocalizedMessage("Error_HTTP_Transport",[("readyState: "+c.readyState),""])}return b};Evernote.Utils.extractErrorMessage=function(b,a){var c=(typeof a!="undefined")?a:null;if(b instanceof Evernote.EvernoteError&&typeof b.errorCode=="number"&&typeof b.parameter=="string"&&this.getLocalizedMessage("EDAMError_"+b.errorCode+"_"+b.parameter.replace(/[^a-zA-Z0-9_]+/g,"_"))){c=this.getLocalizedMessage("EDAMError_"+b.errorCode+"_"+b.parameter.replace(/[^a-zA-Z0-9_]+/g,"_"))}else{if(b instanceof Evernote.EDAMResponseException&&typeof b.errorCode=="number"&&this.getLocalizedMessage("EDAMResponseError_"+b.errorCode)){if(typeof b.parameter=="string"){c=this.getLocalizedMessage("EDAMResponseError_"+b.errorCode,b.parameter)}else{c=this.getLocalizedMessage("EDAMResponseError_"+b.errorCode)}}else{if(b instanceof Evernote.EvernoteError&&typeof b.errorCode=="number"&&this.getLocalizedMessage("EDAMError_"+b.errorCode)){if(typeof b.parameter=="string"){c=this.getLocalizedMessage("EDAMError_"+b.errorCode,b.parameter)}else{c=this.getLocalizedMessage("EDAMError_"+b.errorCode)}}else{if(b instanceof Evernote.EvernoteError&&typeof b.message=="string"){c=b.message}else{if((b instanceof Error||b instanceof Error)&&typeof b.message=="string"){c=b.message}else{if(typeof b=="string"){c=b}}}}}}return c};Evernote.Utils.isForbiddenUrl=function(a){if(typeof a=="string"&&(a.toLowerCase().indexOf("chrome.google.com/extensions")>=0||a.toLowerCase().indexOf("chrome.google.com/webstore")>=0)){return true}return false};Evernote.Constants=Evernote.Constants||{};Evernote.Constants.RequestType={UNKNOWN:0,LOGOUT:1,LOGIN:2,AUTH_ERROR:3,AUTH_SUCCESS:4,DATA_UPDATED:6,QUOTA_REACHED:7,CLIP_PROCESSOR_INIT_ERROR:11,AUTOSAVE_PROCESSOR_INIT_ERROR:13,GET_MANAGED_PAYLOAD:14,RETRY_MANAGED_PAYLOAD:15,CANCEL_MANAGED_PAYLOAD:16,REVISIT_MANAGED_PAYLOAD:17,VIEW_MANAGED_PAYLOAD_DATA:18,EDIT_MANAGED_PAYLOAD_DATA:19,SYNC_DATA:20,SYNC_DATA_FAILURE:21,LOG_FILE_REMOVED:30,LOG_FILE_SWAPPED:32,PAGE_CLIP_SUCCESS:100,PAGE_CLIP_FAILURE:101,PAGE_CLIP_CONTENT_SUCCESS:102,PAGE_CLIP_CONTENT_FAILURE:103,PAGE_CLIP_CONTENT_TOO_BIG:105,CLIP_SUCCESS:110,CLIP_FAILURE:111,CLIP_HTTP_FAILURE:113,CLIP_FILE_SUCCESS:120,CLIP_FILE_FAILURE:121,CLIP_FILE_HTTP_FAILURE:123,CANCEL_PAGE_CLIP_TIMER:200,CLEAR_AUTOSAVE:210,AUTOSAVE:212,OPTIONS_UPDATED:320,SEARCH_HELPER_DISABLE:340,CONTENT_SCRIPT_LOAD_TIMEOUT_CANCEL:400,CONTENT_SCRIPT_LOAD_TIMEOUT:401,POPUP_PAGE_CLIP_SUCCESS:1100,POPUP_PAGE_CLIP_FAILURE:1101,POPUP_PAGE_CLIP_CONTENT_SUCCESS:1102,POPUP_PAGE_CLIP_CONTENT_FAILURE:1103,POPUP_PAGE_CLIP_CONTENT_TOO_BIG:1105,CONTEXT_PAGE_CLIP_SUCCESS:2100,CONTEXT_PAGE_CLIP_FAILURE:2101,CONTEXT_PAGE_CLIP_CONTENT_SUCCESS:2102,CONTEXT_PAGE_CLIP_CONTENT_FAILURE:2103,CONTEXT_PAGE_CLIP_CONTENT_TOO_BIG:2105};Evernote.Constants.Limits={EDAM_USER_USERNAME_LEN_MIN:1,EDAM_USER_USERNAME_LEN_MAX:64,EDAM_USER_USERNAME_REGEX:"^[a-z0-9]([a-z0-9_-]{0,62}[a-z0-9])?$",EDAM_USER_PASSWORD_LEN_MIN:6,EDAM_USER_PASSWORD_LEN_MAX:64,EDAM_USER_PASSWORD_REGEX:"^[A-Za-z0-9!#$%&'()*+,./:;<=>?@^_`{|}~\\[\\]\\\\-]{6,64}$",EDAM_NOTE_TITLE_LEN_MIN:1,EDAM_NOTE_TITLE_LEN_MAX:255,EDAM_NOTE_TITLE_REGEX:"^[^\\s\\r\\n\\t]([^\\n\\r\\t]{0,253}[^\\s\\r\\n\\t])?$",EDAM_TAG_NAME_LEN_MIN:1,EDAM_TAG_NAME_LEN_MAX:100,EDAM_TAG_NAME_REGEX:"^[^,\\s\\r\\n\\t]([^,\\n\\r\\t]{0,98}[^,\\s\\r\\n\\t])?$",EDAM_NOTE_TAGS_MIN:0,EDAM_NOTE_TAGS_MAX:100,SERVICE_DOMAIN_LEN_MIN:1,SERVICE_DOMAIN_LEN_MAX:256,CLIP_NOTE_CONTENT_LEN_MAX:5242880,EDAM_USER_RECENT_MAILED_ADDRESSES_MAX:10,EDAM_EMAIL_LEN_MIN:6,EDAM_EMAIL_LEN_MAX:255,EDAM_EMAIL_REGEX:"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.([A-Za-z]{2,})$"};Evernote.RequestMessage=function RequestMessage(b,a){this.initialize(b,a)};Evernote.RequestMessage.fromObject=function(a){var b=new Evernote.RequestMessage();if(typeof a=="object"&&a!=null){if(typeof a.code!="undefined"){b.code=a.code}if(typeof a.message!="undefined"){b.message=a.message}}return b};Evernote.RequestMessage.prototype._code=0;Evernote.RequestMessage.prototype._message=null;Evernote.RequestMessage.prototype._callback=null;Evernote.RequestMessage.prototype.initialize=function(c,b,a){this.__defineGetter__("code",this.getCode);this.__defineSetter__("code",this.setCode);this.__defineGetter__("message",this.getMessage);this.__defineSetter__("message",this.setMessage);this.__defineGetter__("callback",this.getCallback);this.__defineSetter__("callback",this.setCallback);this.code=c;this.message=b};Evernote.RequestMessage.prototype.getCode=function(){return this._code};Evernote.RequestMessage.prototype.setCode=function(a){this._code=parseInt(a);if(isNaN(this._code)){this._code=0}};Evernote.RequestMessage.prototype.getMessage=function(){return this._message};Evernote.RequestMessage.prototype.setMessage=function(a){this._message=a};Evernote.RequestMessage.prototype.getCallback=function(){return this._callback};Evernote.RequestMessage.prototype.setCallback=function(a){if(typeof a=="function"||a==null){this._callback=a}};Evernote.RequestMessage.prototype.send=function(){chrome.extension.sendRequest({code:this.code,message:this.message})};Evernote.RequestMessage.prototype.isEmpty=function(){return(this.code)?false:true};