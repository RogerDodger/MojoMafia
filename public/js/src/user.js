/*
 * Copyright (c) 2013 Cameron Thornton.
 *
 * This library is free software; you can redistribute and/or modify it
 * under the same terms as Perl version 5.14.2.
 */

// ===========================================================================
// New user form
// ===========================================================================

$(document).ready(function() {
	var $uname = $('#uname');
	$('#dname').focus(function() {
		if (!this.value) {
			this.value = $uname.val();
			this.select();
		}
	});
});
