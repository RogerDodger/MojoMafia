/*
 * Copyright (c) 2014 Cameron Thornton.
 *
 * This library is free software; you can redistribute and/or modify it
 * under the same terms as Perl version 5.14.2.
 */

String.prototype.regex = function() {
	// http://stackoverflow.com/questions/3446170
	return this.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
};

function byId (id) {
	return document.getElementById(id);
}
