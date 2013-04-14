package Mafia::Command::minjs;

use Mojo::Base 'Mojolicious::Command';
use JavaScript::Minifier;

sub run {
	my $self = shift;
	my $script = '';
	my $fn = 'public/js/mafia.min.js';

	for my $js (glob 'public/js/src/*.js') {
		say "+ $js";
		open my $fh, '<', $js;
		$script .= join '', $fh->getlines;
		close $fh;
	}

	say "Minifying...";
	my $min = JavaScript::Minifier::minify(input => $script);

	say "[write] $fn";
	open my $mafiajs, ">", $fn;
	print $mafiajs do { local $/; <DATA> };
	print $mafiajs $min;
	close $mafiajs;
}

1;

__DATA__
/*
 * Copyright (c) 2013 Cameron Thornton.
 *
 * This library is free software; you can redistribute and/or modify it
 * under the same terms as Perl version 5.14.2.
 */
