package Mafia::Markup;
use Mojo::Base 'Exporter';
use Mojo::URL;
use List::Util ();

our @EXPORT_OK = qw/render_markup/;

# Inline grammar
my %igrammar = (
	escape => qr{ \\ . }x,
	style  => qr{ \*+ }x,
	link   => qr{ \[ .* \] (?<!\]\\) \( .* [^\\] \) }x,
);

# Captures grammar
my %cgrammar = (
	link    => qr{^ \[ (.*) \] \( (.+) \) $}x,
);

# Lookup table for style tags
my @style_tags = (
	undef,
	[ '<em>', '</em>' ],
	[ '<strong>', '</strong>' ],
	[ '<strong><em>', '</em></strong>' ],
);

sub markup {
	my $text = shift;

	if (!utf8::is_utf8 $text) {
		$text = Encode::decode_utf8($text);
	}

	$text = _parse_block($text);
}

BEGIN { *render_markup = \&markup }

sub _html_escape {
	local $_ = shift;

	s/</&lt;/g;
	s/>/&gt;/g;
	s/'/&#39;/g;
	s/"/&quot;/g;

	$_;
}

sub _parse_block {
	join "\n\n",
	  map { '<p>' . _parse_inline($_) . '</p>' }
	    split /\n\n+/, shift;
}

sub _parse_inline {
	my $text = shift;
	$text =~ s/^\s+|\s+$//g;

	my @tokens = _tokenise_inline($text);

	# bit mask of which font style we're in. a value of 3 means we're in both style 1 and 2
	my $in = 0;

	# references of up to two font style opening tokens in order
	my @open;

	# modify the array of tokens in-place
	# all special tokens are turned into strings according to the token's rules
	for (@tokens) {
		# special token
		if (ref) {
			my ($cat, $token) = @$_;

			if ($cat eq 'style') {
				# effective length of style token
				my $length = List::Util::min(length $token, 3);

				# if we're in a style that we can close, this token is a closing token
				# otherwise this token is an opening token. it's never both

				# closing token
				if ($in & $length) {
					# closing style token is level 1 or 2, which closes from the end only what it needs to
					if ($length < 3) {
						while (@open) {
							my ($open, $open_length) = @{pop @open};

							# close any opened style level we pass over
							$in &= ~$open_length;

							# closing either the same style level, or closing level 3
							if ($open_length & $length) {
								my ($open_tag, $close_tag) = @{$style_tags[$length]};

								substr($$open, 0, $length) = $open_tag;
								$_ = $close_tag;

								# closed our style level, so we're done
								last;
							}
						}
					}
					# closing style token is level 3, which closes everything it can
					else {
						# substitutions happen from the outside of the closing token. keep track of the position
						my $close_offset = length $token;

						# start from the outside of the open token list
						for my $open_item (@open) {
							my ($open, $open_length) = @$open_item;
							my ($open_tag, $close_tag) = @{$style_tags[$open_length]};

							substr($$open, 0, $open_length) = $open_tag;

							$close_offset -= $open_length;
							substr($token, $close_offset, $open_length) = $close_tag;
							$_ = $token;
						}

						# close everything
						$in = 0;
						@open = ();
					}
				}
				# opening token
				else {
					$_ = $token;
					push @open, [ \$_, $length ];
					$in |= $length;
				}
			}
			elsif ($cat eq 'escape') {
				$token = _html_escape($token);

				# chop \ from escape text
				$token = substr $token, 1;

				$_ = $token;
			}
			elsif ($cat eq 'link') {
				if (my ($name, $url) = $token =~ $cgrammar{link}) {
					$name = _html_escape(length $name ? $name : $url);
					$url  = Mojo::URL->new($url);

					if (defined $url->scheme && $url->scheme eq 'javascript') {
						delete $url->{scheme};
					}

					$_ = qq{<a href="$url">$name</a>};
				}
				else {
					warn "Token '$token' doesn't match cgrammar{link}";
					$_ = _html_escape($token);
				}
			}
		}
		# plain text token
		else {
			$_ = _html_escape($_);
		}
	}

	# now that all the tokens are strings, we can simply join them
	join "", @tokens;
}

sub _tokenise_inline {
	my $text = shift;

	my @tokens;
	my $prev_end = 0;
	while ($text =~ m{(?<escape> $igrammar{escape})
	                | (?<style>  $igrammar{style})
	                | (?<link>   $igrammar{link})}gxo
	) {
		push @tokens, substr $text, $prev_end, $-[0] - $prev_end;
		push @tokens, [ %+ ];
		$prev_end = $+[0];
	}
	push @tokens, substr $text, $prev_end, length($text) - $prev_end;

	@tokens;
}

1;
