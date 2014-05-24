package Mafia::Markup;
use Mojo::Base 'Exporter';
use Mojo::URL;

our @EXPORT_OK = qw/render_markup/;

# Inline grammar
my %igrammar = (
	escape  => qr{ \\ . }x,
	bold    => qr{ \*{2} }x,
	italics => qr{ \* }x,
	link    => qr{ \[ .* \] (?<!\]\\) \( .* [^\\] \) }x,
);

# Captures grammar
my %cgrammar = (
	link    => qr{^ \[ (.*) \] \( (.+) \) $}x,
);

my %tag = (
	bold    => 'strong',
	italics => 'em',
);

sub markup {
	my $text = shift;

	$text = _parse_block($text);
}

*render_markup = \&markup;

sub _html_escape {
	local $_ = shift;

	s/</&lt;/g;
	s/>/&gt;/g;
	s/'/&#39;/g;
	s/"/&quot;/g;

	$_;
}

sub _parse_block {
	return join "\n\n",
	         map { '<p>' . _parse_inline($_) . '</p>' }
	           split /\n{2}/, shift;
}

sub _parse_inline {
	my $text = shift;
	$text =~ s/^\s+|\s+$//g;

	my @tokens = _tokenise_inline($text);

	my $buf = "";
	my @stack;

	# Used to indicate whether a capture of the given type has started
	my %in = ( bold => undef, italics => undef );

	# Used to indicate when a token should be eaten, on account of one
	# having been inserted by the parser earlier
	my %eat;
	for my $token (@tokens) {
		my @cats = grep { $token =~ /^$igrammar{$_}$/ } keys %igrammar;

		if (@cats > 1) {
			warn "Token $token has multiple lexicographical categories: @cats";
		}

		my $cat = $cats[0];

		# Token needs to be eaten, so do nothing with it
		if (defined $cat && $eat{$cat}) {
			$eat{$cat}--;
		}
		# Capturing tokens, utilising stack
		elsif (defined $cat and $cat eq 'bold' || $cat eq 'italics') {
			if (!$in{$cat}) {
				# Start of capture
				push @stack, [ $token, $cat ];
				$in{$cat} = 1;
			}
			else {
				# End of capture
				my $cap = '';
				while (@stack) {
					my $pop = pop @stack;

					if (ref $pop) {
						my $popcat = $pop->[1];
						$cap = "<$tag{$popcat}>$cap</$tag{$popcat}>";
						$in{$popcat} = 0;

						if ($popcat ne $cat) {
							# Oh oh, someone's given us a bad tree. We'd
							# better fix it up.
							$eat{$popcat} = 1;
						}
						else {
							# All is as it should be
							last;
						}
					}
					else {
						$cap = $pop . $cap;
					}
				}

				if (@stack) {
					push @stack, $cap;
				}
				else {
					$buf .= $cap;
				}
			}
		}
		# Non-capturing
		else {
			my $escaped;

			if (!defined $cat || $cat eq 'escape') {
				# Escape HTML special chars
				$escaped = _html_escape($token);

				if (defined $cat) {
					# Chop \ from escape text
					$escaped = substr $escaped, 1;
				}
			}
			elsif ($cat eq 'link') {
				if ($token =~ $cgrammar{link}) {
					my ($name, $url) = ($1, $2);

					$name = _html_escape(length($name) ? $name : $url);
					$url  = Mojo::URL->new($url);

					if (defined $url->scheme && $url->scheme eq 'javascript') {
						delete $url->{scheme};
					}

					$escaped = qq{<a href="$url">$name</a>};
				}
				else {
					warn "Token '$token' doesn't match cgrammar{link}";
				}
			}

			if (@stack) {
				push @stack, $escaped;
			}
			else {
				$buf .= $escaped;
			}
		}
	}

	# Some caps were left on the stack without terminating
	if (@stack) {
		my $cap = '';
		while (@stack) {
			my $pop = pop @stack;
			if (ref $pop) {
				my $popcat = $pop->[1];
				if ($eat{$popcat}) {
					$eat{$popcat}--;
				}
				else {
					$cap = $pop->[0] . $cap;
				}
			}
			else {
				$cap = $pop . $cap;
			}
		}
		$buf .= $cap;
	}

	$buf;
}

sub _tokenise_inline {
	my $text = shift;

	my @tokens = grep defined && length,
	               split qr{( $igrammar{escape}
	                        | $igrammar{bold}
	                        | $igrammar{italics}
	                        | $igrammar{link} )}x, $text;

	return @tokens;
}

1;
