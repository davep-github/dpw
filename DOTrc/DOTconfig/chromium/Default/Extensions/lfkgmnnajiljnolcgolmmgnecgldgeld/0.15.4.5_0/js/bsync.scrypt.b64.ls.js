var lscache={},ls=function(b,c,a){if(c===void 0){if(lscache[b])return lscache[b];try{return lscache[b]=JSON.parse(localStorage.getItem(b)),lscache[b]}catch(d){}return null}if(!a||!ls(b))lscache[b]=JSON.stringify(c),localStorage.setItem(b,lscache[b]),lscache[b]=JSON.parse(lscache[b])},Base64={map:["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y",
"z","0","1","2","3","4","5","6","7","8","9","+","/"]};Base64.fromBinArray=function(b){for(var c="",a=0;a+2<b.length;a+=3){var d=b[a]*65536+b[a+1]*256+b[a+2];c+=Base64.map[Math.floor(d/64/64/64)];c+=Base64.map[Math.floor(d/64/64)%64];c+=Base64.map[Math.floor(d/64)%64];c+=Base64.map[Math.floor(d)%64]}a=b.length%3;a>0&&(d=b.length-a,d=b[d]*65536+(a==2?b[d+1]*256:0),c+=Base64.map[Math.floor(d/64/64/64)],c+=Base64.map[Math.floor(d/64/64)%64],c+=a==2?Base64.map[Math.floor(d/64)%64]+"=":"==");return c};
Base64.toBinArray=function(b){var c=[],a=b.indexOf("=");a>=0&&(b=b.substr(0,a));for(var d=0;d+3<b.length;d+=4)a=Base64.map.indexOf(b[d])*262144+Base64.map.indexOf(b[d+1])*4096+Base64.map.indexOf(b[d+2])*64+Base64.map.indexOf(b[d+3]),c.push(Math.floor(a/256/256)),c.push(Math.floor(a/256)%256),c.push(Math.floor(a)%256);d=b.length%4;d>0&&(a=b.length-d,a=Base64.map.indexOf(b[a])*262144+Base64.map.indexOf(b[a+1])*4096+(d==3?Base64.map.indexOf(b[a+2])*64:0),c.push(Math.floor(a/256/256)),d==3&&c.push(Math.floor(a/
256)%256));return c};Base64.fromString=function(b){for(var c=[],a=0;a<b.length;a++)c.push(b.charCodeAt(a));return Base64.fromBinArray(c)};Base64.toString=function(b){for(var c=Base64.toBinArray(b),b="",a=0;a<c.length;a++)b+=String.fromCharCode(c[a]);return b};
var SimpleCrypt={encode:function(b,c){if(!c)return Base64.fromString(b);for(var c=Base64.toBinArray(c),a=c[0],d=[],f=0;f<b.length;f++)d.push((b.charCodeAt((f+a)%b.length)+c[f%c.length])%256);return Base64.fromBinArray(d)},decode:function(b,c){if(!c)return Base64.toString(b);for(var c=Base64.toBinArray(c),a=Base64.toBinArray(b),d=c[0],f="",g=0;g<a.length;g++)f+=String.fromCharCode((a[(g+a.length*256-d)%a.length]-c[(g+a.length*256-d)%a.length%c.length]+256)%256);return f},makeKey:function(b){if(typeof b==
"string"){var b=Base64.fromString(b),c=b.indexOf("=");c>=0&&(b=b.substr(0,c));b=Base64.fromString(b);c=b.indexOf("=");c>=0&&(b=b.substr(0,c));b=b.substr(1);b.length%4==1&&b.substr(1);b.length%4==2&&(b+="==");b.length%4==3&&(b+="=");return b}else{for(var b=10+Math.floor(Math.random()*20),c=[],a=0;a<b;a++)c.push(Math.floor(Math.random()*256));return Base64.fromBinArray(c)}}},BookmarkSync=function(b,c,a,d,f,g){var e=this;e.title=b;e.profile=c;e.updated=0;e.key=a;e.updatewait=d||12E5;e.mergefunc=f;e.updatedfunc=
g;e.ls="bookmarksync-"+e.title;ls(e.ls,{time:(new Date).getTime(),profiles:{}},!0);ls("bookmarksync-time",0,!0);e.onchanged=function(b,a){e.updated>0?e.updated--:a.title==e.title&&e.getNode()};e.oncreated=function(b,a){e.updated>0?e.updated--:a.title==e.title&&e.getNode()};chrome.bookmarks.onChanged.addListener(e.onchanged);chrome.bookmarks.onCreated.addListener(e.oncreated);e.getNode()};BookmarkSync.prototype.destroy=function(){chrome.bookmarks.onChanged.removeListener(this.onchanged);chrome.bookmarks.onCreated.removeListener(this.oncreated)};
BookmarkSync.prototype.prefix='javascript:alert("This bookmark is used to sync options for an extension.");//--';BookmarkSync.prototype.codeurl=function(b){return this.prefix+Base64.fromString(JSON.stringify(b))};BookmarkSync.prototype.parse=function(b){try{return JSON.parse(Base64.toString(b.match(/\/\/--(.+)$/)[1]))}catch(c){}return null};
BookmarkSync.prototype.set=function(b,c){var a=ls(this.ls);a.time=(new Date).getTime();a.profiles[this.profile]={value:SimpleCrypt.encode(JSON.stringify(b),this.key),time:a.time};ls(this.ls,a);this.update(!1,c)};BookmarkSync.prototype.get=function(b){this.getProfile(this.profile,this.key,b)};
BookmarkSync.prototype.getProfile=function(b,c,a){if(b=ls(this.ls).profiles[b])if(b.value){try{var d=JSON.parse(SimpleCrypt.decode(b.value,c))}catch(f){}d?a("success",d,b.time):a("bad password",null,b.time)}else a("profile deleted");else a("no profile")};BookmarkSync.prototype.getProfiles=function(b){var c=ls(this.ls).profiles;if(c){var a=[];for(name in c)a.push(name);b(a)}else b("no profiles")};
BookmarkSync.prototype.removeProfile=function(b,c){var a=ls(this.ls);a.time=(new Date).getTime();a.profiles[b]={time:a.time,value:null};ls(this.ls,a);this.update(!1,c)};BookmarkSync.prototype.update=function(b,c){var a=this;if(b&&a.updateTimeout)clearTimeout(a.updateTimeout),a.updateTimeout=null;if(!a.updateTimeout){var d=a.updatewait-(new Date).getTime()+ls("bookmarksync-time");!b&&d>0?a.updateTimeout=setTimeout(function(){a.doUpdate(c)},d):a.doUpdate(c)}};
BookmarkSync.prototype.getNode=function(b){var c=this;chrome.bookmarks.search(c.title,function(a){for(var d=0;d<a.length;a[d].title==c.title&&!a[d].children?d++:a.splice(d,1));if(a.length==0)chrome.bookmarks.getTree(function(a){c.updated++;var d=(new Date).getTime(),e=ls(c.ls);e.time=d;ls(c.ls,e);ls("bookmarksync-time",d);chrome.bookmarks.create({parentId:a[0].children[1].id,title:c.title,url:c.codeurl(ls(c.ls))},b)});else{for(d in a)a[d].content=c.parse(a[d].url);a.sort(function(a,b){return a.content.time-
b.content.time});for(var f=ls(c.ls),g=[],d=0;d<a.length;d++)if(a[d].content&&a[d].content.time&&a[d].content.profiles){console.log("A");for(p in a[d].content.profiles)if(!f.profiles[p]||a[d].content.profiles[p].time>f.profiles[p].time){console.log("A1");if(p==c.profile){if(console.log("A2"),c.mergefunc){console.log("A3");var e=null;try{e=JSON.parse(SimpleCrypt.decode(f.profiles[p].value,c.key))}catch(j){}var h=null;try{h=JSON.parse(SimpleCrypt.decode(a[d].content.profiles[p].value,c.key))}catch(k){}if(e&&
h)try{console.log("A4");var i=JSON.stringify(c.mergefunc(e,h));console.log("A5");f.profile[p]=JSON.stringify({value:SimpleCrypt.encode(JSON.stringify(i),c.key),time:f.time})}catch(l){}}}else f.profiles[p]=a[d].content.profiles[p];g.push(p)}if(a[d].content.time>f.time)f.time=a[d].content.time;d<a.length-1&&chrome.bookmarks.remove(a[d].id)}g.length>0&&c.updatedfunc&&c.updatedfunc(g);ls(c.ls,f);b&&b(a[a.length-1])}})};
BookmarkSync.prototype.doUpdate=function(b){var c=this;c.updated++;var a=(new Date).getTime(),d=ls(c.ls);d.time=a;ls(c.ls,d);ls("bookmarksync-time",a);c.getNode(function(a){chrome.bookmarks.update(a.id,{url:c.codeurl(ls(c.ls))},function(a){if(c.updateTimeout)clearTimeout(c.updateTimeout),c.updateTimeout=null;b&&b(!!a)})})};