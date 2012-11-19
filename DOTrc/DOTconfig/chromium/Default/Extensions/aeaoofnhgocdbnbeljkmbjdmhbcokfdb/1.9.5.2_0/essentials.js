/* global initialization */
(function() {

/* inject content scripts at both document_start and document_end,
 * avoid duplicate injection
 * ISSUE=24 */
if (window['cjabiokabamngnbigeeibddnihgllkgg-essentials.js']) return;
window['cjabiokabamngnbigeeibddnihgllkgg-essentials.js'] = true;

/* document.head is undefined in non-HTML type documents */
if (!document.body) {
	window.addEventListener('load', function() {
		if (!document.head)
			document.body.parentNode.insertBefore(
				document.createElement('head'),
				document.body);
	}, false);
} else if (!document.head) {
	document.body.parentNode.insertBefore(
		document.createElement('head'),
		document.body);
}

String.prototype.trim = function()
{
	return this.replace(/^\s+|\s+$/, '');
}

Array.prototype.unique = function()
{
	var o = {}, i, l = this.length;
	for (i = 0; i < l; o[this[i]] = this[i++]);
	this.splice(0, l);
	for(i in o) this.push(o[i]);
}

/* essential functions */
window.$ = {
	/* extensions id */
	EXT_ID: chrome.extension.getURL('').replace(/^.+\/(\w+)\W*$/, '$1'),

	/* element IDs required by one click installation */
	ONE_CLICK_TITLE: 'custom-stroke-one-click-title',
	ONE_CLICK_FRAME: 'custom-stroke-one-click-frame',
	ONE_CLICK_SCRIPT: 'custom-stroke-one-click-script',
	ONE_CLICK_BUTTON: 'custom-stroke-one-click-install',

	/* mouse button id */
	LBUTTON: 0,
	MBUTTON: 1,
	RBUTTON: 2,

	/* stroke directions */
	LEFT: 'L',
	RIGHT: 'R',
	UP: 'U',
	DOWN: 'D',

	/* url of the options page */
	OPTION_URL: chrome.extension.getURL('options.html'),

	/* id prefix of custom strokes */
	CUS_PFX: 'userdef#',

	/* sadly.. */
	WIN: /^win/i.test(navigator.platform),

	/* number of milliseconds to wait before close a tab or window,
	 * the time is given to the content scripts reside in that tab
	 * to do some cleanup work, such as reporting global variables
	 * to the extension
	 * ISSUE=92 */
	CLOSE_WAIT: 100,

	get: function(id) {
		if ('string' != typeof id) return id;
		return document.getElementById(id);
	},

	getbyclass: function(cls, callback) {
		var i, els = document.getElementsByClassName(cls);
		for (i = 0; i < els.length; ++i)
			if (callback)
				try { callback.apply(els[i]) }
				catch (e) {}
		return els;
	},

	getbytag: function(tag, callback) {
		var i, els = document.getElementsByTagName(tag);
		for (i = 0; i < els.length; ++i)
			if (callback)
				try { callback.apply(els[i]) }
				catch (e) {}
		return els;
	},

	create: function(t, p) {
		var n = document.createElement(t);
		for (k in p) n[k] = p[k];
		return n;
	},

	addcls: function(n, c) {
		var nd = $.get(n);
		if (nd && !$.hascls(nd, c))
			nd.className = nd.className.trim() + ' ' + c;
	},

	delcls: function(n, c) {
		var nd = $.get(n);
		if (nd)
			nd.className = nd.className.replace(new RegExp('(^|\\s+)' + c + '(\\s+|$)', 'g'), ' ');
	},

	hascls: function(n, c) {
		var nd = $.get(n);
		if (nd) return (new RegExp('(^|\\s+)' + c + '(\\s+|$)')).test(nd.className);
	},

	show: function(n) {
		$.delcls(n, 'hidden');
	},

	hide: function(n) {
		$.addcls(n, 'hidden');
	},

	toggle: function(n) {
		return $.hascls(n, 'hidden') ? $.show(n) : $.hide(n);
	},

	copy: function(o) {
		return JSON.parse(JSON.stringify(o));
	},

	erase: function(o) {
		if (o) {
			o.innerHTML = '';
			if (o.parentNode)
				o.parentNode.removeChild(o);
		}
	},

	/* inspect all nodes, looking for those with class name 'i18n',
	 * then extract their message IDs and localize their innerHTMLs */
	i18n: function(cls, attr) {
		var i, nodes, html, msg;

		if (!cls) cls = 'i18n';
		if (!attr) attr = 'msg';

		$.getbyclass(cls, function() {
			msg = this.getAttribute(attr);
			if (!!msg && !!(html = chrome.i18n.getMessage(msg)))
				this.innerHTML = html;
		});
	},

	/* and some not-so-essential functions too */
	prompt: function(msg, dur, callback) {
		var id = $.EXT_ID + '-prompt', id2 = id + '-old',
			/* notifications should be shown in the top window,
			 * this should be decided by the caller if Chrome
			 * devs fixes issue 30422
			 * http://code.google.com/p/chromium/issues/detail?id=30442
			 * ISSUE=55 */
			wnd = window.top, doc = wnd.document, body = doc.body,
			nd, nd2, confirm, cancel;

//		if (nd = $.get(id)) {
//			if (nd2 = $.get(id2)) {
		if (nd = doc.getElementById(id)) {
			if (nd2 = doc.getElementById(id2)) {
				nd2.id = '';
				$.erase(nd2);
			}
			nd.id = id2;
		}

		nd = $.create('span', { id: id });
		nd.style.cssText = '\
-webkit-border-top-right-radius:4px;\
background:#d2e1f6;\
border:#b9c7d9 solid 1px;\
bottom:0;\
color:#696969;\
font:11px/1.5 tahoma,sans-serif;\
left:0;\
margin:0;\
opacity:0;\
padding:0 0 1px 3px;\
position:fixed;\
text-align:left;\
width:' + (wnd.innerWidth * .328) + 'px;\
z-index:' + new Date().getTime();

		if (isNaN(dur)) {
			/* duration not set, display till user confirm */
			nd.appendChild($.create('span', { innerHTML: msg }));
			confirm = $.create('button', { textContent: 'Confirm' });
			confirm.style.float = 'right';
			confirm.addEventListener('click', function(ev) {
				$.fade_out(nd, function() {
					try { $.erase(nd) }
					catch (e) {}
					if (!!callback) callback.apply();
				});
			}, false);
			nd.appendChild(confirm);
			$.fade_in(nd);
		} else {
			nd.innerHTML = msg;
			$.fade_in(nd, function() {
				setTimeout(function() {
					$.fade_out(nd, function() {
						try { $.erase(nd) }
						catch (e) {}
						if (!!callback) callback.apply();
					});
				}, Math.max(2, dur) * 1000);
			});
		}
		body.appendChild(nd);
	},

	clear_prompts: function() {
		var id = $.EXT_ID + '-prompt', id2 = id + '-old', n,
			doc = window.top.document, body = doc.body;
		if (n = doc.getElementById(id))
			$.erase(n);
		if (n = doc.getElementById(id2))
			$.erase(n);
	},

	fade_in: function(nd, callback) {
		if (!(nd = $.get(nd))) return;
		nd.style.opacity = 0;
		var i = 0, si = setInterval(function() {
			nd.style.opacity = (i += 0.1);
			if (nd.style.opacity >= 1) {
				clearInterval(si);
				if (!!callback) callback.apply();
			}
		}, 10);
		$.show(nd);
	},

	fade_out: function(nd, callback) {
		if (!(nd = $.get(nd))) return;
		nd.style.opacity = 1;
		var i = 1, si = setInterval(function() {
			nd.style.opacity = (i -= 0.1);
			if (nd.style.opacity <= 0) {
				clearInterval(si);
				$.hide(nd);
				if (!!callback) callback.apply();
			}
		}, 10);
	},

	slide_down: function(nd, callback) {
		if (!(nd = $.get(nd)) || !nd.slide_cache) return;

		var height = 0, cache = nd.slide_cache, style = nd.style;
		cache.interval = setInterval(function() {
			if (height < cache.height) {
				style.height = (Math.min(cache.height, height += 30)) + 'px';
			} else {
				clearInterval(cache.interval);
				style.overflow = cache.overflow;
				nd.slide_cache = undefined;
				if (!!callback) callback.apply();
			}
		}, 10);
	},

	slide_up: function(nd, callback) {
		if (!(nd = $.get(nd)) || !!nd.slide_cache) return;

		nd.slide_cache = {
			height: parseInt(getComputedStyle(nd).getPropertyValue('height')),
			overflow: nd.style.overflow
		}
		nd.style.overflow = 'hidden';

		var cache = nd.slide_cache, style = nd.style, height = cache.height;
		cache.interval = setInterval(function() {
			if (height > 0) {
				style.height = (Math.max(0, height -= 30)) + 'px';
			} else {
				clearInterval(cache.interval);
				if (!!callback) callback.apply();
			}
		}, 10);
	}
}


/* stroke handlers
 * the first parameter is the tab object in which the stroke is generated
 * the second parameter is the event object recorded in the stroke.js */
$.actions = {

'to-page-top': {
	/* evaluated locally in the content script */
	local: true,
	/* executed in which frames, valid when evaluted in content scripts
	 * recognized values are:
	 * all: all frames within page;
	 * top: only the top frame;
	 * target: only the target frame, the frame under the cursor. */
	frame: 'target',
	/* the handler function */
	handler: function(tab, event, dest) {
		var global = $.actions['to-page-top'],
			duration = 200, interval = 10,
			i = 1, n = Math.ceil(duration / interval / 2),
			f = 2,	/* speed factor */
			half, step, curr, scroll_h, client_h,
			el = $.get(event.initevt.target.id);

		/* find the first scrollable element */
		while (!!el && !/^(body|html)$/i.test(el.nodeName) && (el.scrollHeight <= el.offsetHeight ||
			!/^(auto|scroll)$/i.test(getComputedStyle(el).getPropertyValue('overflow')))) {
			el = el.parentNode;
		}
		if (!el) return;
		else if (/^(body|html)$/i.test(el.nodeName)) {
			el = document.body;
			scroll_h = el.scrollHeight;
			client_h = window.innerHeight;
		} else {
			scroll_h = el.scrollHeight;
			client_h = el.offsetHeight;
		}

		curr = el.scrollTop;
		if ('pageup' === dest) {
			dest = el.scrollTop - client_h + 40;
		} else if ('pagedown' === dest) {
			dest = el.scrollTop + client_h - 40;
		}

		if (!dest || dest < 0)
			dest = 0;
		else if (dest > scroll_h - client_h)
			dest = scroll_h - client_h;

		if (dest == el.scrollTop) return;
		else half = (dest - curr) / 2;

		if (!event.cfg.enable_animation) {
			el.scrollTop = dest;
			return;
		}

		if (global.interval) clearInterval(global.interval);

		global.interval = setInterval(function() {
			/* the scroll speed steps up as a geometric sequence,
			 * then steps down as the same sequence reversed */
			if (1 == i) {
				/* first step */
				step = half * (1 - f) / (1 - Math.pow(f, n));
			} else if (i <= n) {
				/* speed up */
				step *= f;
			} else if (i != n + 1) {
				/* speed down */
				step *= 1 / f;
			}

			/* round steps to integers, to compensate deviations,
			 * do not modify steps directly cause fractions
			 * should be used in calculation */
			curr = el.scrollTop = el.scrollTop +
				Math[step > 0 ? 'ceil' : 'floor'](step);
			if (++i > 2 * n) {
				clearInterval(global.interval);
				global.interval = null;
				/* final distance align */
//				el.scrollTop = dest;
			}
		}, interval);
	}
},

'to-page-bottom': {
	local: true,
	frame: 'target',
	handler: function(tab, event) {
		$.actions['to-page-top'].handler(tab, event, Infinity);
	}
},

'scroll-up-one-page': {
	local: true,
	frame: 'target',
	handler: function(tab, event) {
		$.actions['to-page-top'].handler(tab, event, 'pageup');
	}
},

'scroll-down-one-page': {
	local: true,
	frame: 'target',
	handler: function(tab, event) {
		$.actions['to-page-top'].handler(tab, event, 'pagedown');
	}
},

'history-back': {
	local: true,
	frame: 'target',
	handler: function(tab, event) {
		history.back();
	}
},

'history-forward': {
	local: true,
	frame: 'target',
	handler: function(tab, event) {
		history.forward();
	}
},

'previous-tab': {
	local: false,
	handler: function(tab, event) {
		$.actions['next-tab'].handler(tab, event, -1);
	}
},

'next-tab': {
	local: false,
	handler: function(tab, event, dir) {
		var i, n, step = (!!dir && dir < 0) ? -1 : 1;
		chrome.tabs.getAllInWindow(null, function(tabs) {
			n = tabs.length;
			for (i = 0; i < n; ++i) {
				if (tabs[i].id == tab.id) {
					if (!!(tab = tabs[(i+step+n)%n])) {
						chrome.tabs.update(tab.id, { selected: true });
					}
					break;
				}
			}
		});
	}
},

'first-tab': {
	local: false,
	handler: function(tab, event) {
		chrome.tabs.getAllInWindow(null, function(tabs) {
			chrome.tabs.update(tabs[0].id, { selected: true });
		});
	}
},

'last-tab': {
	local: false,
	handler: function(tab, event) {
		chrome.tabs.getAllInWindow(null, function(tabs) {
			chrome.tabs.update(tabs[tabs.length-1].id, { selected: true });
		});
	}
},

'upper-level-in-url': {
	local: true,
	frame: 'target',
	handler: function(tab, event) {
		var p = location.protocol + '//' + location.host +
			location.pathname.slice(0, -1).replace(/[^\/]*$/, '');
		if (p != location.href) location.href = p;
	}
},

'increase-number-in-url': {
	local: true,
	frame: 'target',
	handler: function(tab, event, dir) {
		var url = null, i, s, s2, lnks, href, rel_search, url_search,
			rel_prev = /^prev$/i, rel_next = /^next$/i,
			url_prev = /^(?:prev|prev page|previous|previous page|<)$/i,
			url_next = /^(?:next|next page|>)$/i,
			page_search = /\W(?:page)=(\d+)(?:\D|$)/i;

		if ((dir = !isNaN(dir) && dir < 0 ? -1 : 1) > 0) {
			rel_search = rel_next;
			url_search = url_next;
		} else {
			rel_search = rel_prev;
			url_search = url_prev;
		}

		/* first search <link rel="next"...> */
		lnks = $.getbytag('link');
		for (i = 0; i < lnks.length; ++i) {
			href = lnks[i].href;
			s = '' + lnks[i].rel;
			if (href && rel_search.test(s)) {
				url = href;
				break;
			}
		}
		/* then search <a href="...">next</a> */
		if (!url) {
			lnks = $.getbytag('a');
			for (i = 0; i < lnks.length; ++i) {
				href = lnks[i].href;
				s = '' + lnks[i].rel;
				s2 = '' + lnks[i].textContent
				if (href && !/^javascript/i.test(href) && (rel_search.test(s) || url_search.test(s2))) {
					url = href;
					break;
				}
			}
		}
		/* then search for url pattern: ?page=... */
		if (!url && (href = location.href.match(page_search))) {
			s = Math.max(parseInt(href[1]) + dir, 0);	/* page number */
			s2 = href[0].replace(href[1], s);		/* page parameter */
			url = location.href.replace(href[0], s2);
		}

		if (url && url != location.href) location.href = url;

		return;

		var n = location.href.match(/(\d+)$/);
		if (n) {
			n = Math.max(0, parseInt(n[1]) + (isNaN(i) ? 1 : i));
			location.href = location.href.replace(/\d+$/, n);
		}
	}
},

'decrease-number-in-url': {
	local: true,
	frame: 'target',
	handler: function(tab, event) {
		$.actions['increase-number-in-url'].handler(tab, event, -1);
	}
},

'open-homepage': {
	local: false,
	handler: function(tab, event) {
		$.actions['new-tab'].handler(tab, event, {
			url: undefined, selected: true
		});
	}
},

'minimize-window': {
	local: false,
	handler: function(tab, event) {
		/* not implemented */
	}
},

'maximize-window': {
	local: false,
	handler: function(tab, event) {
		chrome.windows.getCurrent(function(wnd) {
			chrome.windows.update(wnd.id, {
				left: 0, top: 0, width: screen.width,
				height: screen.height });
		});
	}
},

'new-window': {
	local: false,
	handler: function(tab, event) {
		chrome.windows.create();
	}
},

'close-window': {
	local: false,
	handler: function(tab, event) {
		chrome.windows.getCurrent(function(wnd) {
			setTimeout(function() {
				chrome.windows.remove(wnd.id);
			}, $.CLOSE_WAIT);
		});
	}
},

'new-tab': {
	local: false,
	handler: function(tab, event, info) {
		if (!info) {
			info = {
				selected: true,
				url: (event.cfg.newtab_target ?
					event.cfg.newtab_target : undefined)
			}
		} else {
			info.selected = !!info.selected;
		}

		info.index = eval(tab.index + event.cfg.newtab_position);
		/* when tab.index is 0 and event.cfg.newtab_position is '/0',
		 * info.index will be NaN.
		 * stupid stuipd stupid
		 * ISSUE=51 */
		if (isNaN(info.index) || Infinity == info.index)
			/* divided by zero (when open as the last tab),
			 * simply assign a big number */
			info.index = 31415926;

		chrome.tabs.create(info);
	}
},

'close-tab': {
	local: false,
	handler: function(tab, event) {
		if (!event.cfg.last_tab_close_win)
			chrome.tabs.getAllInWindow(null, function(t) {
				if (1 == t.length)
					$.actions['new-tab'].handler(tab, event);
				setTimeout(function() {
					chrome.tabs.remove(tab.id);
				}, $.CLOSE_WAIT);
			});
		else
			setTimeout(function() {
				chrome.tabs.remove(tab.id);
			}, $.CLOSE_WAIT);
	}
},

'undo-close-tab': {
	local: false,
	handler: function(tab, event) {
		if (0 < _tabs.closed.length) {
			var dead = _tabs.all[_tabs.closed.pop()];
			chrome.tabs.create({
				index: tab.index + 1,
				selected: true,
				url: dead.url
			}, function() {
				/* a new tab is created (same url, different
				 * tab id), the old tab has long gone */
				delete _tabs.all[dead.id];
			});
		}
	}
},

'detach-tab': {
	local: false,
	handler: function(tab, event) {
		chrome.windows.create(null, function(wnd) {
			chrome.tabs.move(tab.id, { windowId: wnd.id, index: 0 });
			/* remove all other tabs */
			chrome.tabs.getAllInWindow(wnd.id, function(tabs) {
				for (var i = 0; i < tabs.length; ++i) {
					if (tabs[i].id != tab.id) {
						chrome.tabs.remove(tabs[i].id);
					}
				}
			});
		});
	}
},

'duplicate-tab': {
	local: false,
	handler: function(tab, event) {
		chrome.tabs.create({
			index: tab.index + 1,
			url: tab.url
		});
	}
},

'close-tab-to-the-left': {
	local: false,
	handler: function(tab, event) {
		$.actions['close-tab-to-the-right'].handler(tab, event, -1);
	}
},

'close-tab-to-the-right': {
	local: false,
	handler: function(tab, event, dir) {
		var i, n, step = (!!dir && dir < 0) ? -1 : 1;
		chrome.tabs.getAllInWindow(null, function(tabs) {
			n = tabs.length;
			for (i = 0; i < n; ++i) {
				if (tabs[i].id == tab.id) {
					chrome.tabs.remove(tabs[(i+step+n)%n].id);
					break;
				}
			}
		});
	}
},

'close-all-tabs-to-the-left': {
	local: false,
	handler: function(tab, event) {
		$.actions['close-all-tabs-to-the-right'].handler(tab, event, -1);
	}
},

'close-all-tabs-to-the-right': {
	local: false,
	handler: function(tab, event, dir) {
		/* when dir < 0, remove left tabs, otherwise remove right ones */
		var i, start = dir < 0;
		chrome.tabs.getAllInWindow(null, function(tabs) {
			for (i = 0; i < tabs.length; ++i) {
				if (start && tab.id != tabs[i].id)
					chrome.tabs.remove(tabs[i].id);
				else if (start)
					break;
				else if (tab.id == tabs[i].id)
					start = true;
			}
		});
	}
},

'close-other-tabs': {
	local: false,
	handler: function(tab, event) {
		chrome.tabs.getAllInWindow(null, function(tabs) {
			for (var i = 0; i < tabs.length; ++i) {
				if (tabs[i].id != tab.id) {
					chrome.tabs.remove(tabs[i].id);
				}
			}
		});
	}
},

'open-link-in-new-window': {
	local: false,
	handler: function(tab, event) {
		if (!!event.initevt.target.href) {
			chrome.windows.create({
				url: event.initevt.target.href
			});
		}
	}
},

'open-link-in-new-background-tab': {
	local: false,
	handler: function(tab, event) {
		if (!!event.initevt.target.href) {
			$.actions['new-tab'].handler(tab, event, {
				url: event.initevt.target.href,
				selected: false
			});
		}
	}
},

'open-link-in-new-foreground-tab': {
	local: false,
	handler: function(tab, event) {
		if (!!event.initevt.target.href) {
			$.actions['new-tab'].handler(tab, event, {
				url: event.initevt.target.href,
				selected: true
			});
		}
	}
},

'bookmark-this-link': {
	local: false,
	handler: function(tab, event, url, title) {
		url = url || event.initevt.target.href;
		title = title || event.initevt.target.textContent || url;

		if (!url) return;

		chrome.bookmarks.getChildren('0', function(root) {
			/* add to bookmarks bar */
			chrome.bookmarks.create({
				parentId: root[0].id,
				title: title,
				url: url
			}, function() {
				chrome.tabs.sendRequest(tab.id, {
					type: 'show-message',
					data: {
						html: 'Bookmark added',
						duration: 2
					}
				});
			});
		});
	}
},

'view-image': {
	local: false,
	handler: function(tab, event) {
		if (!!event.initevt.target.src) {
			$.actions['new-tab'].handler(tab, event, {
				url: event.initevt.target.src,
				selected: true
			});
		}
	}
},

'save-image': {
	local: false,
	handler: function(tab, event) {
		/* not implemented */
	}
},

'bookmark-this-page': {
	local: false,
	handler: function(tab, event) {
		$.actions['bookmark-this-link'].handler(tab, event, tab.url, tab.title);
	}
},

'remove-bookmark': {
	local: false,
	handler: function(tab, event) {
		/* search by host, full url sometimes won't return results even
		 * when there are exact matches */
		var host = $.create('a', { href: tab.url }).host;
		chrome.bookmarks.search(host, function(bks) {
			for (var i = 0; i < bks.length; ++i) {
				if (bks[i].url == tab.url) {
					chrome.bookmarks.remove(bks[i].id, function() {
						chrome.tabs.sendRequest(tab.id, {
							type: 'show-message',
							data: {
								html: 'Bookmark removed',
								duration: 2
							}
						});
					});
				}
			}
		});
	}
},

'reload': {
	local: true,
	frame: 'all',
	handler: function(tab, event) {
		location.reload();
	}
},

'skip-cache-reload': {
	local: true,
	frame: 'all',
	handler: function(tab, event) {
		location.reload(true);
	}
},

'stop-page-loading': {
	local: true,
	frame: 'all',
	handler: function(tab, event) {
		window.stop();
	}
},

'view-source': {
	local: false,
	handler: function(tab, event) {
		$.actions['new-tab'].handler(tab, event, {
			url: 'view-source:' + tab.url,
			selected: true
		});
	}
},

'take-screenshot': {
	local: false,
	handler: function(tab, event) {
		/* clear notifications if any */
		chrome.tabs.sendRequest(tab.id, { type: 'clear-message' });
		/* wait for trails being cleared */
		setTimeout(function() {
			chrome.tabs.captureVisibleTab(null, function(url) {
				$.actions['new-tab'].handler(tab, event, {
					selected: true,
					url: url
				});
			});
		}, 100);
	}
},

'text-zoom-in': {
	local: true,
	frame: 'all',
	handler: function(tab, event) {
		$.actions['text-zoom-reset'].handler(tab, event, 0.01);
	}
},

'text-zoom-out': {
	local: true,
	frame: 'all',
	handler: function(tab, event) {
		$.actions['text-zoom-reset'].handler(tab, event, -0.01);
	}
},

	/* zoom text */
'text-zoom-reset': {
	local: true,
	frame: 'all',
	handler: function(tab, event, step) {
		if (!document.zoom || isNaN(step)) document.zoom = 1;

		var zoom = document.zoom += isNaN(step) ? 0 : step;
		var css = $.get('ms-zoom-' + tab.id);

		if (1 == zoom) {
			if (!!css) $.erase(css);
		} else {
			if (!css) {
				css = $.create('style', {
					id: 'ms-zoom-' + tab.id,
					type: 'text/css'
				});
				document.head.appendChild(css);
			}
			css.textContent = '* { font-size: ' + zoom + 'em !important; }';
		}
	}
},

'search-selected-text': {
	local: false,
	handler: function(tab, event) {
		event.seltext = event.seltext.trim();
		if (!event.seltext) return;
		$.actions['new-tab'].handler(tab, event, {
			selected: true,
			url: event.cfg.search_engine + event.seltext
		});
	}
},

'mouse-stroke-options': {
	local: false,
	handler: function(tab, event) {
		chrome.tabs.create({
			url: $.OPTION_URL
		});
	}
}

}; /* $.actions */


/* make some chrome APIs available to the custom stroke */
$.custom_apis = {
	clipboard: {
		copy: function(copee, callback) {
			chrome.extension.sendRequest({
				type: 'remote-eval', data: {
					api: 'clipboard.copy',
					arg: copee
				}
			}, !callback ? function() {} : callback);
		}
	},

	tabs: {
		create: function(info, callback) {
			chrome.extension.sendRequest({
				type: 'remote-eval', data: {
					api: 'tabs.create',
					arg: info
				}
			}, !callback ? function() {} : callback);
		},
		remove: function(id, callback) {
			chrome.extension.sendRequest({
				type: 'remote-eval', data: {
					api: 'tabs.remove',
					arg: id
				}
			}, !callback ? function() {} : callback);
		}
	},

	windows: {
		create: function(info, callback) {
			chrome.extension.sendRequest({
				type: 'remote-eval', data: {
					api: 'windows.create',
					arg: info
				}
			}, !callback ? function() {} : callback);
		},
		remove: function(id, callback) {
			chrome.extension.sendRequest({
				type: 'remote-eval', data: {
					api: 'windows.remove',
					arg: id
				}
			}, !callback ? function() {} : callback);
		}
	},

	/* call built-in stroke handlers, this is a placeholder */
	builtin: function() {}
};

/* the sandbox used to evaluate scripts from custom strokes */
$.sandbox = function(tab, event, script) {
	var $ = window.$, _ = window._, _env = MS = event, ex;

	/* expose APIs */
	MS.apis = $.custom_apis;
	MS.apis.builtin = function(name, callback) {
		if (!$.actions[name])
			throw new ReferenceError(name + ' is not a built-in stroke');
		else {
			chrome.extension.sendRequest({
				type: 'remote-eval', data: {
					api: 'builtin',
					arg: {
						name: name,
						tab: tab,
						event: event
					}
				}
			}, !callback ? function() {} : callback);
		}
	}

	/* make sure global objects can't be accessed from custom strokes */
	window.$ = null;
	window._ = null;

	try {
		(function() {
			/* mask all local variables */
			var ex, $, tab, event;

			eval(script);
		})();
	} catch (e) {
		ex = e;
		/* tag as custom stroke error */
		ex.name = '[<strong>' + _('category_label_custom_strokes') + '</strong>] ' + ex.name;
	}

	/* recover global objects */
	window.$ = $;
	window._ = _;

	return undefined === ex ? true : ex;
}

/* the i18n function */
window._ = function(msg, sub)
{
	return chrome.i18n.getMessage(msg, sub);
}

})();
