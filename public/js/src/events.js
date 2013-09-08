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
		var checkcss = function() {
			console.log("Checking CSS");
			var url = '/events';
			var matches = sheet.href.match(/\d+$/);
			if (matches) {
				url += '?mtime=' + matches[0];
			}
			$.ajax({
				type: 'GET',
				url: url,
				success: function(res, status, xhr) {
					if (sheet.href.match(/mtime=\d+$/)) {
						sheet.href = sheet.href.replace(/\d+$/, res);
					} else {
						sheet.href += '?mtime=' + res;
					}
					checkcss();
				},
				error: function() {
					// If it fails, the server probably went down
					// Better to just stop now and refresh the page
				}
			});
		};
		checkcss();
	})();
}
