/*
 * Copyright (c) 2013 Cameron Thornton.
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the same terms as Perl version 5.14.2.
 */

// This is only polling for CSS reloads right now. Doing this with EventSource
// doesn't work with morbo for whatever reason.

if (Mafia.mode == 'development') {
	(function() {
		var sheet = document.getElementById('main-stylesheet');
		(function watch_css() {
			console.log("Checking CSS");
			$.ajax({
				type: 'GET',
				url: '/watch/css',
				success: function(res, status, xhr) {
					if (sheet.href.match(/mtime=\d+$/)) {
						sheet.href = sheet.href.replace(/\d+$/, res);
					}
					else {
						sheet.href += '?mtime=' + res;
					}
				},
				complete: watch_css
			});
		})();
	})();
}
