/*
 * Copyright (c) 2013 Cameron Thornton.
 *
 * This library is free software; you can redistribute and/or modify it
 * under the same terms as Perl version 5.14.2.
 */

$(document).ready(function() {
	navigator.id.watch({
		loggedInUser: currentUser,
		onlogin: function(assertion) {
			$.ajax({
				type: 'POST',
				url: '/login',
				data: {assertion: assertion},
				success: function(res, status, xhr) { 
					window.location.reload(); 
				},
				error: function(xhr, status, err) {
					navigator.id.logout();
					alert("Login failure: " + err);
				}
			});
		},
		onlogout: function() {
			$.ajax({
				type: 'POST',
				url: '/logout',
				success: function(res, status, xhr) { window.location.reload(); },
				error: function(xhr, status, err) { alert("Logout failure: " + err); }
			});
		}
	});

	$('#login')
		.click(function(e) {
			e.preventDefault();
			navigator.id.request();
		});
	$('#logout')
		.click(function(e) {
			e.preventDefault();
			navigator.id.logout();
		});
});
