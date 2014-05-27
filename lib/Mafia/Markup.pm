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
	link => qr{^ \[ (.*) \] \( (.+) \) $}x,
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
	s/"/&quot;/g;
	s/'/&#39;/g;

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
							my $open = pop @open;
							my $open_length = length $$open;

							# closing a level 3 style token
							if ($open_length >= 3) {
								my ($open_tag, $close_tag) = @{$style_tags[$length]};

								# close only part of the opening token
								$in &= ~$length;

								substr($$open, -$length, $length) = $open_tag;
								$_ = $close_tag;

								# reuse the level 3 opening token as the token we're left in
								push @open, \substr($$open, 0, $in);

								# closed our style level, so we're done
								last;
							}

							# close any style level we pass over
							$in &= ~$open_length;

							# closing the same style level
							if ($open_length & $length) {
								my ($open_tag, $close_tag) = @{$style_tags[$length]};

								$$open = $open_tag;
								$_ = $close_tag;

								# closed our style level, so we're done
								last;
							}
						}
					}
					# closing style token is level 3, which closes everything it can
					else {
						my $close_offset = 0;

						while (@open) {
							my $open = pop @open;
							my $open_length = length $$open;
							my ($open_tag, $close_tag) = @{$style_tags[$open_length]};

							substr($$open, -$open_length, $open_length) = $open_tag;
							substr($token, $close_offset, $open_length) = $close_tag;

							$close_offset += length $close_tag;
						}
						$_ = $token;

						# level 3 style tokens always close everything
						$in = 0;
					}
				}
				# opening token
				else {
					$_ = $token;
					push @open, \substr($_, -$length, $length);
					$in |= $length;
				}
			}
			elsif ($cat eq 'escape') {
				# chop \ from escape text
				$token = substr $token, 1;

				$_ = _html_escape($token);
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
			else {
				warn "Unknown category: '$cat'";
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
