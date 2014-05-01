/*
 * Copyright (c) 2013 Cameron Thornton.
 *
 * This library is free software; you can redistribute and/or modify it
 * under the same terms as Perl version 5.14.2.
 */

$(document).ready(function() {
	navigator.id.watch({
		loggedInUser: Mafia.user.email,
		onlogin: function(assertion) {
			$.ajax({
				type: 'POST',
				url: Mafia.paths["user-login"],
				data: { "assertion" : assertion },
				success: function(res, status, xhr) {
					if ('redirect' in res) {
						window.location = res.redirect;
					} else {
						window.location.reload();
					}
				},
				error: function(xhr, status, err) {
					alert("Login failure: " + err);
					navigator.id.logout();
				}
			});
		},
		onlogout: function() {
			$.ajax({
				type: 'POST',
				url: Mafia.paths["user-logout"],
				success: function(res, status, xhr) {
					window.location.reload();
				},
				error: function(xhr, status, err) {
					alert("Logout failure: " + err);
				}
			});
		}
	});

	$('#login')
		.click(function(e) {
			e.preventDefault();
			navigator.id.request({ "siteName" : "MojoMafia" });
		});
	$('#logout')
		.click(function(e) {
			e.preventDefault();
			navigator.id.logout();
		});
});
