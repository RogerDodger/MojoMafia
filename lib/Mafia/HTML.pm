package Mafia::HTML;

sub tidy {
	my $html = shift;

	if (ref $html eq 'SCALAR') {
		$$html = _tidy($$html);
	} else {
		return _tidy($html);
	}
}

sub _tidy {
	my $html = shift;

	# TODO - Low priority
	return $html;
}

1;
