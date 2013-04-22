package Mafia::HTML;

sub tidy {
	my $html = shift;

	return unless eval { require HTML::Tidy };

	my $tidy = HTML::Tidy->new({
		new_blocklevel_tags => join(", ", qw/article aside details figcaption figure
		                                     footer header hgroup nav section summary/),
		new_inline_tags     => 'time',
		preserve_entities   => 1,
		char_encoding       => 'utf8',
		output_html         => 1, 
		tidy_mark           => 0,
		indent              => 1,
		wrap                => 110,
	});

	${$html} = $tidy->clean(${$html}) and return 1;
}

1;
