#!/usr/bin/env perl

use 5.014;
use Test::More;
use Mafia::Markup qw/render_markup/;
use Time::HiRes qw/gettimeofday/;

my $t0 = gettimeofday();

is(
	render_markup("Hello"),
	"<p>Hello</p>",
	"Basic paragraph",
);

is(
	render_markup("Hello, \n\n World!"),
	"<p>Hello,</p>\n\n<p>World!</p>",
	"Basic paragraphs",
);

is(
	render_markup("Lorem [ipsum dolor](http://example.com) sit amet."),
	q{<p>Lorem <a href="http://example.com">ipsum dolor</a> sit amet.</p>},
	"Link text",
);

is(
	render_markup("Lorem ipsum **dolor** sit amet."),
	"<p>Lorem ipsum <strong>dolor</strong> sit amet.</p>",
	"Bold text",
);

is(
	render_markup("Lorem ipsum *dolor* sit amet."),
	"<p>Lorem ipsum <em>dolor</em> sit amet.</p>",
	"Italic text",
);

is(
	render_markup("Lorem **ipsum** dolor **sit** amet."),
	"<p>Lorem <strong>ipsum</strong> dolor <strong>sit</strong> amet.</p>",
	"Bold text, multiple",
);

is(
	render_markup("Lorem *ipsum* dolor *sit* amet."),
	"<p>Lorem <em>ipsum</em> dolor <em>sit</em> amet.</p>",
	"Italic text, multiple",
);

is(
	render_markup("Lorem **ipsum *dolor* sit** amet."),
	"<p>Lorem <strong>ipsum <em>dolor</em> sit</strong> amet.</p>",
	"Bold and italic text, nested",
);


is(
	render_markup("Lorem **ipsum *dolor** sit* amet."),
	"<p>Lorem <strong>ipsum <em>dolor</em></strong> sit amet.</p>",
	"Bold and italic text, nested, bad order",
);

is(
	render_markup("Lorem **ipsum dolor sit amet."),
	"<p>Lorem **ipsum dolor sit amet.</p>",
	"Bold text, no terminator",
);

say STDERR gettimeofday - $t0;

done_testing;
