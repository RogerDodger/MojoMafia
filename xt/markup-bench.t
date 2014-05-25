#!/usr/bin/env perl

use 5.014;
use Test::More;
use Mafia::Markup qw/render_markup/;
use Benchmark qw/timethis/;

my $n = shift // 100;
srand(shift // 0);

sub timetext {
	my ($text) = @_;
	timethis $n, sub { render_markup $text };
}

diag "Bold and italic: * and **";
{
	my $text = join "\n\n", (
		"*Lorem* **ipsum** *dolor* **sit** amet.
		Lorem *ipsum **dolor** sit* amet.
		Lorem **ipsum *dolor* sit** amet
		* ** *** **** *****"
	) x 10;
	timetext $text;
}

diag "Links: []()";
{
	my $text = join "\n\n", ("Visit [Foo](http://foo) and [](http://bar) but not [Baz]() or []()" x 30) x 10;
	timetext $text;
}

diag "Escapes: \\";
{
	my $text = join "\n\n", (<<'SLASH') x 15;
\Sl\\a\\\s\\\\h \[\\i\t\\\ \)\\ \\\\\\\u\\p\\\\
SLASH
	timetext $text;
}

diag "Everything together";
for (1..5) {
	my @tokens = ("\n\n", ("aaaa") x 10, qw/* ** \\ [ ] ( )/);
	my $text = join "", map { $tokens[rand @tokens] } 1..1000;
	timetext $text;
}
