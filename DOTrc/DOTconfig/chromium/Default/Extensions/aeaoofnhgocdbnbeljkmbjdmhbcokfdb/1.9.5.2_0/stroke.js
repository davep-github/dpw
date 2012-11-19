(function() {
	/* inject content scripts at both document_start and document_end,
	 * avoid duplicate injection
	 * ISSUE=24 */
	if (window['cjabiokabamngnbigeeibddnihgllkgg-stroke.js']) return;
	window['cjabiokabamngnbigeeibddnihgllkgg-stroke.js'] = true;

	/* the unique identity of this frame */
	var _identity = location.href + new Date().getTime() + Math.random();

	/* one click install button */
	var _one_click;

	/* mouse pointer's last cordinates and distances moved */
	var _lastX, _lastY, _accuX, _accuY;

	/* threshold for leaned (like "left up") strokes
	 * this feature is on hold because the matching rate is low */
	var _lean = 1 / Math.tan(30 * Math.PI / 180);

	/* the stroking event object, will be passed to the stroke handler */
	var _event;

	/* the stroke movement's end time */
	var _endtm;

	/* true if the last regular/rocker/wheel stroke is fired */
	var _stroke_fired;

	/* the <canvas> element, its context for trail drawing
	 * and the hovering element to indicate drag strokes */
	var _tcanvas, _tcontext, _hover;

	/* the connection port between the backend page */
	var _port;

	/* configurations */
	var _cfg = {}

	/* css styles */
	var _styles = {
		canvas: 'left:0;position:fixed;top:0;z-index:' + new Date().getTime(),
		hover: 'background:#ebeff9;border-radius:5px;padding: 5px 5px 5px 15px;font-family:sans-serif;font-size:12px;max-width:150px;overflow:hidden;padding:1px 4px;position:fixed;white-space:nowrap;z-index:' + new Date().getTime()
	}

	/* global variable container */
	var _heap = {
		/* status of left and right mouse buttons,
		 * they are global because rocker or wheel strokes can be
		 * used to navigate between tabs, they depend on previous
		 * tabs' mouse button status to behave continuously */
		ldown: false, rdown: false,
		/* whether a rocker or wheel stroke has just been fired,
		 * the reason of making them global is similar to ldown/rdown:
		 * the currently selected tab should suppress the context menu
		 * once if it is given focus by a rocker or wheel stroke */
		rkfired: false, mwfired: false
	}

	/* connect to the backend page */
	var connect = function() {
		_port = chrome.extension.connect({
			name: 'stroke.html-stroke'
		});
	}

	/* calculate weights by distances moved in both directions */
	var weigh = function(x, y) {
		return Math.round(Math.sqrt(x * x + y * y));
	}

	/* search for image that is possibly positioned at the given
	 * element's coordinate */
	var imgsrc = function(el) {
		var src;
		if (!el || Node.ELEMENT_NODE != el.nodeType)
			return null;
		else if (/^IMG$/i.test(el.nodeName) && !!el.src)
			return el.src;
		else if (src = getComputedStyle(el).getPropertyValue('background-image'))
			/* getPropertyValue() returns string literal 'none' if
			 * no background images are set */
			return src.match(/^url\(.+\)$/) && src.replace(/^url\((.+)\)$/, '$1');
		else return imgsrc(el.parentNode);
	}

	/* search for link upward in the DOM tree */
	var linkhref = function(el) {
		while (!!el && !/^A$/i.test(el.nodeName)) el = el.parentNode;
		if (!!el && !/^javascript/i.test(el.href)) return el.href;
		else return null;
	}

	/* strip MouseEvent object to void 'Converting circular structure to
	 * JSON' errors when converting it to JSON string */
	var strip = function(ev) {
		/* unique ID for the target element, event type is added
		 * because there are two targets in one stroke session, the
		 * initevt.target and finevt.target */
		var id = $.EXT_ID + '-' + ev.type, last, el = ev.target;

		/* keep useful properties only, also retain the MouseEvent
		 * object structure */
		var e = {
			/* rocker strokes need this to know which button is
			 * pressed first */
			button: ev.button,
			/* custom strokes need to know if the ctrl key is
			 * pressed */
			ctrlKey: ev.ctrlKey,
			/* the target element of the event, the srcElement
			 * property in previous versions */
			target: {
				/* link type strokes need these properties */
				textContent: el.textContent,
				href: linkhref(el),
				/* image type strokes need these */
				src: imgsrc(el),
				/* they all got this */
				nodeName: el.nodeName
			}
		};

		/* custom strokes need ID to retrieve the target element,
		 * sometimes on code.google.com, .id != .getAttribute('id') */
		if (last = $.get(id)) last.setAttribute('id', '');
		while (!!el && Node.ELEMENT_NODE != el.nodeType) el = el.parentNode;
		if (!!el) {
			if (!el.getAttribute('id')) el.setAttribute('id', id);
			e.target.id = el.getAttribute('id');
		}

		/* for backward compatibility */
		e.srcElement = e.target;

		return e;
	}

	/* create the canvas element for trail drawing */
	var canvas = function() {
		_tcanvas = $.create('canvas', {
			width: window.innerWidth, height: window.innerHeight
		});
		_tcanvas.style.cssText = _styles.canvas;
		_tcontext = _tcanvas.getContext('2d');
		/* styling */
//		_tcontext.globalAlpha = 0.3;
		_tcontext.lineWidth = _cfg.trail_width;
		_tcontext.lineCap = 'butt';
		_tcontext.lineJoin = 'round';
		_tcontext.shadowOffsetX = _cfg.trail_width;
		_tcontext.shadowOffsetY = _cfg.trail_width;
		_tcontext.shadowBlur = 3;
		_tcontext.shadowColor = 'rgba(0, 0, 0, 0.4)';
		_tcontext.strokeStyle = _cfg.trail;
	}

	/* create the drag and drop indicator */
	var hover = function() {
		_hover = $.create('div');
		_hover.style.cssText = _styles.hover;
	}

	/* set global variable */
	var setg = function(name, value) {
		_heap[name] = value;
		/* tell background page to update */
		_port.postMessage({ type: 'set-global',
			data: { name: name, value: value }
		});
	}

	/* get global variable */
	var getg = function(name) {
		return _heap[name];
	}

	/* assemble a stroke event, NOTE: all types of strokes, including
	 * rockers and wheels, will use this event */
	var genevt = function(ev) {
		return {
			/****** general properties ******/
			/* identity of this frame */
			identity: _identity,
			/* stroke, drag, rocker or wheel */
			type: null,
			/* the initial event (mousedown for all 3 types) */
			initevt: strip(ev),
			/* the finish event (mouseup for stroke type, mousedown
			 * for rocker type and mousewheel for wheel type) */
			finevt: null,
			/* currently selected text */
			seltext: window.getSelection().toString(),
			/* all visited URLs in this tab, will be populated
			 * in stroke.html */
			visited: [],

			/****** stroke type properties ******/
			/* stroke array */
			stroke: [],
			/* weights of each stroke part in the stroke array */
			weights: [],

			/****** wheel type properties ******/
			/* wheel direction, UP, DOWN, LEFT or RIGHT */
			wheel: null,

			/****** rocker type properties ******/
			/* rocker direction, LEFT -> RIGHT or RIGHT -> LEFT */
			rocker: null
		};
	}

	/* reset everything */
	var reset = function() {
//		setg('ldown', false);
//		setg('rdown', false);
//		setg('rkfired', false);
//		setg('mwfired', false);
//		_event = undefined;
//		trail_clear();
//		hover_clear();
		if (_tcanvas && _tcanvas.parentNode) {
			_tcanvas.parentNode.removeChild(_tcanvas);
			_tcanvas.appended = false;
		}
		if (_hover && _hover.parentNode) {
			_hover.parentNode.removeChild(_hover);
			_hover.appended = false;
		}
	}

	var trail_init = function(ev) {
		if (!_tcontext) canvas();
		_tcanvas.counter = 0;
		_tcontext.beginPath();
		_tcontext.moveTo(ev.clientX, ev.clientY);
	}

	var trail_track = function(ev) {
		/* insert the canvas into the DOM tree now, other
		 * than on the moment when it was created, because
		 * operations on <body> will cause any selected
		 * elements to lose focus
		 * ISSUE=11
		 */
		if (!_tcanvas.appended) {
			document.body.appendChild(_tcanvas);
			_tcanvas.appended = true;
		}

		/* the margin area of <body> doesn't generate 'mousemove'
		 * events, to enable strokes in such area, we need to create
		 * the canvas to ensure that 'mousemove' events are generated
		 * on all visiable areas, even when the trail_width is 0
		 * ISSUE=110 */
		if (!_cfg.trail_width) return;

		_tcontext.lineTo(ev.clientX, ev.clientY);
		/* lessen rendering stress */
		if (2 == _tcanvas.counter++ % 3) {
			_tcontext.stroke();
			_tcontext.beginPath();
			_tcontext.moveTo(ev.clientX, ev.clientY);
		}
	}

	var trail_clear = function(ev) {
		if (!_tcanvas) return;
		$.erase(_tcanvas);
		_tcanvas.appended = false;
		_tcontext.clearRect(0, 0, _tcanvas.width, _tcanvas.height);
	}

	var hover_init = function(ev) {
		if (!_hover) hover();
	}

	var hover_track = function(ev) {
		if (_event.stroke.length <= 0) return;

		if (!_hover.appended) {
			document.body.insertBefore(_hover, document.body.firstChild);
			_hover.appended = true;
			$.fade_in(_hover);
		}
		_hover.style.top = (ev.clientY - _hover.offsetHeight + 4) + 'px';
		_hover.style.left = (ev.clientX - _hover.offsetWidth/2) + 'px';
	}

	var hover_clear = function(ev) {
		if (!_hover) return;
		$.fade_out(_hover, function() {
			$.erase(_hover);
			_hover.appended = false;
		});
	}

	/* test if the stroke array is empty, this function returns true
	 * doesn't mean that there are no lines being drawn on screen, because
	 * lines shorter than _cfg.minstep will not be put into the stroke
	 * array but will be drawn on screen */
	var stroke_empty = function() {
		return !_event || !_event.stroke.length;
	}

	/* test if required keys of regular strokes are pressed */
	var stroke_keys = function(ev) {
		return ev.button == _cfg.trigger && !!_event &&
			/* left mouse button should not be holding down */
			!getg('ldown') &&
			/* rocker and wheel should not be just fired */
			!getg('rkfired') && !getg('mwfired') &&
			/* not suppressed by Alt key */
			(!_cfg.suppress || !ev.altKey && !ev.metaKey);
	}

	/* initate a regular or drag stroke */
	var stroke_init = function(ev, drag) {
		/* prepare to draw trails */
		if (!drag) trail_init(ev);

		/* start recording path, reset everything */
		_lastX = ev.screenX;
		_lastY = ev.screenY;
		_accuX = _accuY = 0;

		_event.type = !drag ? 'stroke' : 'drag';

		/* disable auto-scroll to support strokes on Linux and Mac */
		if ($.MBUTTON == ev.button) {
			ev.preventDefault();
		}
	}

	/* track mouse movements in a regular or drag stroke transaction */
	var stroke_move = function(ev, drag) {
		var move, last_idx,
			x = ev.screenX, y = ev.screenY,
			offsetX = x - _lastX, offsetY = y - _lastY,
			absX = Math.abs(offsetX), absY = Math.abs(offsetY);

		if (!drag) {
			trail_track(ev);
			/* clear trails when the stroke expires
			 * ISSUE=126 */
			clearTimeout(reset.timeout);
			reset.timeout = setTimeout(reset, _cfg.timeout);
		}

		/* the movement is negligible */
		if (absX < _cfg.minstep && absY < _cfg.minstep) return;

		_lastX = x;
		_lastY = y;
		_accuX += absX;
		_accuY += absY;

		/* ignore leaning, blurrer strokes are more recognizable */
//		if (0 == absY || (absX / absY > _lean)) {
//		} else if (0 == absX || (absY / absX > _lean)) {
//		} else {
//			move = (offsetX > 0 ? $.RIGHT : $.LEFT)
//				+ (offsetY > 0 ? $.DOWN : $.UP);
//		}
		if (absX > absY) {
			move = offsetX > 0 ? $.RIGHT : $.LEFT;
		} else {
			move = offsetY > 0 ? $.DOWN : $.UP;
		}

		last_idx = _event.stroke.length - 1;
		if (-1 == last_idx || _event.stroke[last_idx] != move) {
			/* first move or direction changed */
			_accuX = absX;
			_accuY = absY;
			_event.stroke.push(move);
			_event.weights.push(weigh(_accuX, _accuY));
			if ('stroke' == _event.type)
				$.prompt('[' + _event.stroke.join(' ') + ']', 2);
		} else {
			/* update weights */
			_event.weights[last_idx] = weigh(_accuX, _accuY);
		}
		/* update movement's ending time */
		_endtm = new Date().getTime();
	}

	/* fire a regular or drag stroke */
	var stroke_fire = function(ev, drag) {
		/* timeouted */
		if ((new Date().getTime() - _endtm) > _cfg.timeout) return;

		/* it's a valid stroke */
		_event.finevt = strip(ev);
		if (!drag) _stroke_fired = true;

		_port.postMessage({ type: 'stroke', data: _event });

		/* stopPropagation() causes troubles on websites which rely on
		 * these events
		 * ISSUE=54 */
		ev.preventDefault();
	}

	/* test if required keys of drag strokes are pressed */
	var drag_keys = function(ev) {
		return _cfg.enable_dnd && draggable() &&
			/* the right mouse button must be up */
			!getg('rdown') &&
			!getg('rkfired') && !getg('mwfired') &&
			(!_cfg.suppress || !ev.altKey && !ev.metaKey);
	}

	/* test if the _event.target is draggable */
	var draggable = function() {
		var el = _event && _event.initevt.target;
		/* links, images and selected text can be dragged */
		return _event && _event.seltext || el && (el.href || el.src);
	}

	/* initiate drag'n'drop stroke */
	var drag_init = function(ev) {
		var el = _event.initevt.target;

		/* prepare dragging indicator */
		hover_init(ev);

		_hover.textContent = _event.seltext || el.href || el.src;

		stroke_init(ev, true);
	}

	/* track drag direction */
	var drag_move = function(ev) {
		/* tracking the mouse cursor */
		hover_track(ev);
		/* clear the hovering element when the drag action expires
		 * ISSUE=126 */
		clearTimeout(reset.timeout);
		reset.timeout = setTimeout(reset, _cfg.timeout);

		stroke_move(ev, true);
	}

	/* fire a drag stroke */
	var drag_fire = function(ev) {
		/* TODO: the url regexp is rudimentary */
		var regex = /^(\w{3,6}|(view|chrome)\-\w+):\/\/\S+$/;

		hover_clear(ev);

		/* accept the last drag direction */
		_event.stroke.splice(0, _event.stroke.length - 1);
		_event.drag = _event.stroke[0];

		/* selected text has the highest priority */
		_event.seltext = _event.seltext.trim();
		if (_event.seltext && regex.test(_event.seltext)) {
			/* a text link is selected */
			_event.initevt.target.textContent =
			_event.initevt.target.href = _event.seltext;
		} else if (_event.seltext) {
			/* search text */
			_event.initevt.target.href = _cfg.search_engine + _event.seltext;
		}

		stroke_fire(ev, true);
	}

	/* fire a rocker */
	var rocker_fire = function(ev) {
		var dir;

		/* rocker stroke is buggy on Linux */
		if (!$.WIN) {
			setg('ldown', false), setg('rdown', false);
			return;
		}

		/* it's tricky to decide rocker strokes' direction, the easiest
		 * way is to make decisions based on the 'mouseup' event, if the
		 * 'mouseup' event comes from the left button, then fire a
		 * right->left stroke, otherwise fire a left->right stroke.
		 * however, in practice, especially when making fast inputs, it's
		 * easy to do un-standard clicks like this:
		 * 1. press down left button, press down right button
		 * 2. release left button, release right button
		 * although the left button is first released, the desired stroke
		 * is left->right other than right->left.
		 * as a result the direction of rocker strokes is based on the
		 * order of key press, instead of on the order of key release */
		if (!_event) {
			/* when navigating between tabs by rocker or wheel strokes,
			 * _event is undefined when the user do contineous strokes,
			 * because the initial 'mousedown' events is fired in
			 * another tab, in this case, both _event.initevt and
			 * _event.finevt will be the finishing 'mouseup' event */
			_event = genevt(ev);
			/* because the user is still holding the other button, the
			 * released button must be pressed later than that button */
			dir = $.LBUTTON == ev.button ? $.LEFT : $.RIGHT;
		} else {
			/* when the initial event is available, the button of the
			 * the initial event must be pressed first */
			dir = $.LBUTTON == _event.initevt.button ? $.RIGHT : $.LEFT;
		}
		_event.type = 'rocker';
		_event.finevt = strip(ev);
		_event.rocker = dir;
		setg('rkfired', true);
		_port.postMessage({ type: 'stroke', data: _event });
		ev.preventDefault();
	}

	/* fire a wheel */
	var wheel_fire = function(ev) {
		if (!$.WIN) {
			setg('ldown', false), setg('rdown', false);
			return;
		}

		if (!_event) _event = genevt(ev);

		_event.type = 'wheel';
		_event.finevt = strip(ev);
		_event.wheel = ev.wheelDeltaY < 0 ? $.DOWN :
				ev.wheelDeltaY > 0 ? $.UP :
				ev.wheelDeltaX < 0 ? $.RIGHT :
				ev.wheelDeltaX > 0 ? $.LEFT : null;
		setg('mwfired', true);
		_port.postMessage({ type: 'stroke', data: _event });
		ev.preventDefault();
	}

	/* test if the current url is blocked in the blacklist */
	var blacklisted = function() {
		var i, list = _cfg.blacklist ? _cfg.blacklist.split("\n") : [];
		for (i = 0; i< list.length; ++i)
			if (list[i] && -1 != window.location.href.indexOf(list[i]))
				return true;
		return false;
	}

	/* (un)register event handlers */
	var register = function(blocked) {
		var action = blocked ? 'removeEventListener' : 'addEventListener';

		if (blocked && !register.registered || !blocked && register.registered)
			return;

		window[action]('resize', resize, true);
		document[action]('contextmenu', contextmenu, true);
		document[action]('drag', drag, true);
		document[action]('dragend', dragend, true);
		document[action]('dragstart', dragstart, true);
		document[action]('mousedown', mousedown, true);
		document[action]('mousemove', mousemove, true);
		document[action]('mouseup', mouseup, true);
		document[action]('mousewheel', mousewheel, true);

		register.registered = !blocked;
	}

	/****** event handlers ******/
	/* resize canvas on window resize */
	var resize = function(ev) {
		$.erase(_tcanvas);
		_tcanvas = _tcontext = undefined;
	}

	/* suppress the context menu when the trigger is right mouse button */
	var contextmenu = function(ev) {
		/* right button is bound to be involved in both rocker and
		 * wheel strokes, after firing such strokes, a contextmenu
		 * should always been killed */
		if (getg('rkfired') || getg('mwfired') ||
			/* stroke fired and the trigger is the right button */
			_stroke_fired && _cfg.trigger == $.RBUTTON ||
			/* left button is still down, maybe still draging or
			 * in a continueous rocker stroke */
			getg('ldown')) {
			/* the point of all *fired variables is to prevent
			 * context menu, so reset them all after suppression */
			_stroke_fired = false;
			setg('rkfired', false);
			setg('mwfired', false);
			ev.preventDefault();
		}
	}

	/* detect wheel strokes */
	var mousewheel = function(ev) {
		if (getg('rdown') && stroke_empty())
			wheel_fire(ev);
	}

	/* decide if we should prevent browser's drag action */
	var dragstart = function(ev) {
		if (drag_keys(ev)) {
			drag_init(ev);
		} else {
			/* prevent further dragging actions, but don't prevent
			 * browser's default behaviors
			 * ISSUE=57 */
			_event = undefined;
		}
	}

	var drag = function(ev) {
		/* chrome started to send a "reset" drag event (screenX = 0,
		 * screenY = 0) at the end of each dragging session (version
		 * unknown).
		 * ISSUE=130 */
		if (0 == ev.screenX && 0 == ev.screenY) return;

		/* discard drag events when the mouse doesn't move */
		if (drag.lastX == ev.screenX && drag.lastY == ev.screenY) return;
		drag.lastX = ev.screenX;
		drag.lastY = ev.screenY;

		if (drag_keys(ev)) drag_move(ev);
	}

	var dragend = function(ev) {
		if (!stroke_empty() && drag_keys(ev)) drag_fire(ev);

		/* drag events will suppress 'mouseup' events, just like
		 * no 'mouseup' events after 'contextmenu' events, so we
		 * need to do some cleanup works here */
		setg('ldown', false);
		_event = undefined;
	}

	/* initiate stroke events, 'mousedown' will be fired before 'dragstart',
	 * so drag events are also initiated here */
	var mousedown = function(ev) {
		var target = ev.target;
		/* ignore events on <object> and <embed>, they should not
		 * generate mouse events but sometimes we do receive
		 * 'mousedown'events from them
		 * ISSUE=79 */
		if (/^(OBJECT|EMBED)$/i.test(target.nodeName)) return;

		/* guess if the user is clicking on scroll bars, if so ignore
		 * such events because Chrome only generates mousedown events
		 * on scroll bars, no paired mouseup events will be generated,
		 * this causes rocker/wheel strokes being fired accidentally.
		 * 18 pixels is the width of the scroll bar on Windows XP
		 * ISSUE=74 */
		if (document.body.scrollHeight > window.innerHeight &&
			window.innerWidth - ev.clientX < 18 ||
			document.body.scrollWidth > window.innerWidth &&
			window.innerHeight - ev.clientY < 18 ||
			/* element scroll bars */
			target.scrollHeight > target.clientHeight &&
			target.clientWidth < ev.offsetX ||
			target.scrollWidth > target.clientWidth &&
			target.clientHeight < ev.offsetY)
			return;

		/* don't create _event if both buttons are down, the first
		 * 'mousedown' of a rocker stroke should be kept */
		if ($.LBUTTON == ev.button) {
			setg('ldown', true);
			if (!getg('rdown')) _event = genevt(ev);
		} else if ($.RBUTTON == ev.button) {
			setg('rdown', true);
			if (!getg('ldown')) _event = genevt(ev);
		} else {
			_event = genevt(ev);
		}

		if (stroke_keys(ev)) stroke_init(ev);
	}

	/* track mouse movements */
	var mousemove = function(ev) {
		if (stroke_keys(ev)) stroke_move(ev);
	}

	/* finish stroking */
	var mouseup = function(ev) {
		/* not sure if mouseup happens on these nodes, but since
		 * we've blocked their mousedown events, block mouseup too */
		if (/^(OBJECT|EMBED)$/i.test(ev.target.nodeName)) return;

		/* a dirty workaround, sometimes after jump to a tab by rocker
		 * stroke, the first 'mousedown' event of the right button
		 * will not be fired (may be fired in another tab like ISSUE 30?) */
		if ($.RBUTTON == ev.button && !getg('rdown')) setg('rdown', true);

		if (getg('ldown') && getg('rdown') && stroke_empty()) {
			/* rockers are fired when both mouse buttons were
			 * pressed and the mouse was not moved since the last
			 * 'mousedown' event */
			rocker_fire(ev);
		} else if (stroke_keys(ev) && !stroke_empty()) {
			stroke_fire(ev);
		}

		/* clear trails in some unusual situations
		 * ISSUE=105 */
		if (ev.button == _cfg.trigger) trail_clear();

		if ($.LBUTTON == ev.button) setg('ldown', false);
		else if ($.RBUTTON == ev.button) setg('rdown', false);

		/* if not both buttons are released, there might be a contineous
		 * stroke followed, so not delete _event in such cases */
		if (!getg('ldown') && !getg('rdown')) _event = undefined;
	}

	/* response to requests from background page */
	chrome.extension.onRequest.addListener(function(msg, sender, resp) {
		if ('update-config' == msg.type) {
			_cfg = msg.data;
			register(blacklisted());

			/* trail color and thickness might be affected by _cfg update */
			$.erase(_tcanvas);
			_tcanvas = _tcontext = undefined;
		} else if (blacklisted()) {
			/* in the blacklist, do nothing */
			return;
		} else if ('local-eval' == msg.type) {
			var ex, id = msg.data.id, tab = msg.data.tab,
				event = msg.data.event,
				custom = msg.data.custom,
				script = msg.data.script,
				action = $.actions[id],
				frame = custom ? script.frame : action.frame;

			if (!!frame && 'all' != frame &&
				('target' != frame || event.identity != _identity) &&
				('top' != frame || window.top != window))
				return;

			/* make configurations available to stroke handlers */
			event.cfg = $.copy(_cfg);

			try {
				if (custom) {
					/* event is passed as the magic _env
					 * variable to the sandbox */
					ex = $.sandbox.call(tab, tab, event, script.script);
					if (true !== ex) throw ex;
				} else {
					$.actions[id].handler.call(tab, tab, event);
				}
			} catch (ex) {
				console.error(ex.stack);
				$.prompt(ex, 5);
			}
		} else if ('put-globals' == msg.type) {
			/* just be selected, reset _heap and _event */
			_heap = msg.data;
			_event = undefined;
		} else if ('show-message' == msg.type) {
			$.prompt(msg.data.html, msg.data.duration);
		} else if ('clear-message' == msg.type) {
			$.clear_prompts();
		} else if ('connect-port' == msg.type) {
			/* the backend page is asking us to reconnect */
			connect();
		} else {
			/* both stroke.js and options.html are listening to
			 * onRequest events, although all listeners can receive
			 * the same event, the sender will only get the first
			 * response, all listeners' responses except the first
			 * one will be lost. so don't send response if the
			 * message type is unknown, another listener who
			 * understand the message will send the response */
			return;
		}
		resp({});
	});

	/* establish connection between background page and content script */
	connect();

	/* query config from the background page */
	_port.postMessage({ type: 'pull-config' });
	_port.postMessage({ type: 'get-globals' });
	/* report page info */
	_port.postMessage({
		type: 'report-info',
		data: {
			'history': history.length
		}
	});

	/* custom stroke one click installation */
	window.addEventListener('load', function() {
		_one_click = $.get($.ONE_CLICK_BUTTON);
		if (_one_click &&
			/* only accept strokes hosted on ganq.net */
			/^(www\.)?ganq\.net$/i.test(location.hostname) &&
			/^\/mouse\-stroke\//i.test(location.pathname)) {

			_one_click.disabled = false;
			_one_click.addEventListener('click', function() {
				try {
					_port.postMessage({
						type: 'one-click-install',
						data: {
							'title': $.get($.ONE_CLICK_TITLE).textContent,
							'frame': $.get($.ONE_CLICK_FRAME).value,
							'script': $.get($.ONE_CLICK_SCRIPT).textContent
						}
					});
				} catch (ex) {
					console.error(ex.stack);
					$.prompt(ex, 5);
				}
			}, false);
		}
	}, false);
})();
