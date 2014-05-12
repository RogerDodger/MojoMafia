#/usr/bin/env perl
use Mojo::Base -strict;
use Test::More;
use Mafia::HTML qw/tidy_html/;

plan skip_all => "tidy_html not implemented yet";

my ($in, $out);

sub _test {
	my $msg = shift;
	is tidy_html($in), $out, $msg;
}

$in = <<EOF;
<!-- Foo bar baz -->
<html>
<head><title>Foo</title></head>
<body>
<p>Hello, World!</p>
<p>Goodbye, World.</p>
</body>
</html>
EOF

$out = <<EOF;
<!-- Foo bar baz -->
<html>
  <head>
    <title>Foo</title>
  </head>
  <body>
    <p>
      Hello, World!
    </p>
    <p>
      Goodbye, World.
    </p>
  </body>
</html>
EOF

_test("Basic HTML");
