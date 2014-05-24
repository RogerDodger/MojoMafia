#!/usr/bin/env perl

use 5.014;
use Test::More;
use Mafia::Markup qw/render_markup/;

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

is(
	render_markup(q{[](http://www.example.com)}),
	q{<p><a href="http://www.example.com">http://www.example.com</a></p>},
	"Link autotext",
);

is(
	render_markup(q{[foo]("><script>alert('Hello');</script>)}),
	q{<p><a href="%22%3E%3Cscript%3Ealert('Hello');%3C/script%3E">foo</a></p>},
	"Link XSS, endquote + tag in link",
);

is(
	render_markup(q{[foo](//x.com?"><script>alert('Hello');</script>)}),
	q{<p><a href="//x.com?%22%3E%3Cscript%3Ealert('Hello');%3C/script%3E">foo</a></p>},
	"Link XSS, endquote + tag in query",
);

is(
	render_markup(q{[foo](javascript:alert('Hello');)}),
	q{<p><a href="alert('Hello');">foo</a></p>},
	"Link XSS, javascript scheme",
);

done_testing;
