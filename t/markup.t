#!/usr/bin/env perl

use utf8;
use 5.014;
use Encode;
use Test::More;
use Mafia::Markup qw/render_markup/;

is(
	render_markup("Hello"),
	"<p>Hello</p>",
	"Basic paragraph",
);

is(
	render_markup("Hi \n World"),
	"<p>Hi \n World</p>",
	"Basic paragraph with inline whitespace",
);

is(
	render_markup("Hello, \n\n World!"),
	"<p>Hello,</p>\n\n<p>World!</p>",
	"Basic paragraphs",
);

is(
	render_markup("\nOne\n \n\n \nTwo\n"),
	"<p>One</p>\n\n<p>Two</p>",
	"Leading and trailing space",
);

is(
	render_markup("One \n\n\n Two \n\n\n\n Three"),
	"<p>One</p>\n\n<p>Two</p>\n\n<p>Three</p>",
	"More than two newlines",
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
	render_markup("Lorem *ipsum **dolor** sit* amet."),
	"<p>Lorem <em>ipsum <strong>dolor</strong> sit</em> amet.</p>",
	"Italic and bold text, nested",
);

is(
	render_markup("Lorem *ipsum dolor sit amet."),
	"<p>Lorem *ipsum dolor sit amet.</p>",
	"Italic text, no terminator",
);

is(
	render_markup("Lorem **ipsum dolor sit amet."),
	"<p>Lorem **ipsum dolor sit amet.</p>",
	"Bold text, no terminator",
);

is(
	render_markup("Lorem **ipsum* dolor sit amet."),
	"<p>Lorem **ipsum* dolor sit amet.</p>",
	"Bold and italic text, no terminator",
);

is(
	render_markup("Lorem *ipsum** dolor sit amet."),
	"<p>Lorem *ipsum** dolor sit amet.</p>",
	"Italic and bold text, no terminator",
);

is(
	render_markup("Lorem **ipsum *dolor** sit* amet."),
	"<p>Lorem <strong>ipsum *dolor</strong> sit* amet.</p>",
	"Bold and italic text, nested, bad order",
);

is(
	render_markup("Lorem *ipsum **dolor* sit** amet."),
	"<p>Lorem <em>ipsum **dolor</em> sit** amet.</p>",
	"Italic and bold text, nested, bad order",
);

is(
	render_markup("** * ** ** * **"),
	"<p><strong> * </strong> <strong> * </strong></p>",
	"Bad bold, bad bold",
);

is(
	render_markup("** * ** ** * **"),
	"<p><em> * </em> <em> * </em></p>",
	"Bad italic, bad italic",
);

is(
	render_markup("** * ** * ** * ** * ** * ** *"),
	"<p><strong> * </strong> <em> ** </em> <strong> * </strong> <em> ** </em></p>",
	"Bad bold, bad italic, bad bold, bad italic",
);

is(
	render_markup("*** ***"),
	"<p><strong><em> </em></strong></p>",
	"Simple oblique",
);

is(
	render_markup("Foo *** Bar"),
	"<p>Foo *** Bar</p>",
	"Unterminated oblique",
);

is(
	render_markup("** * ***"),
	"<p><strong> <em> </em></strong></p>",
	"Oblique ends bold and italic",
);

is(
	render_markup("* ** ***"),
	"<p><em> <strong> </strong></em></p>",
	"Oblique ends italic and bold",
);

is(
	render_markup("* *** * **\n\n* *** ** *\n\n* *** ***"),
	"<p><em> **</em> * **</p>\n\n<p><em> **</em> ** *</p>\n\n<p><em> **</em> ***</p>",
	"Oblique ends italic only",
);

is(
	render_markup("** *** * **\n\n** *** ** *\n\n** *** ***"),
	"<p><strong> **</strong> * **</p>\n\n<p><strong> **</strong> ** *</p>\n\n<p><strong> **</strong> ***</p>",
	"Oblique ends bold only",
);

is(
	render_markup("*** * **\n\n*** * ***"),
	"<p><em>** </em> **</p>\n\n<p><em>** </em> ***</p>",
	"Italic badly-terminates oblique",
);

is(
	render_markup("*** ** *\n\n*** ** ***"),
	"<p><strong>* </strong> *</p>\n\n<p><strong>* </strong> ***</p>",
	"Bold badly-terminates oblique",
);

is(
	render_markup("****\n\n*****\n\n******\n\n*******"),
	"<p>****</p>\n\n<p>*****</p>\n\n<p>******</p>\n\n<p>*******</p>",
	"Unterminated >3 character obliques",
);

is(
	render_markup("**** ***\n\n***** ***"),
	"<p><strong><em>* </em></strong></p>\n\n<p><strong><em>** </em></strong></p>",
	"Oblique with more * on left side",
);

is(
	render_markup("*** ****\n\n*** *****"),
	"<p><strong><em> *</em></strong></p>\n\n<p><strong><em> **</em></strong></p>",
	"Oblique with more * on right side",
);

is(
	render_markup("**** *****\n\n***** ****"),
	"<p><strong><em>* **</em></strong></p>\n\n<p><strong><em>** *</em></strong></p>",
	"Oblique with more * on both sides",
);

is(
	render_markup("* ****\n\n** ****"),
	"<p><em> ***</em></p>\n\n<p><strong> **</strong></p>",
	">3 oblique ending bold or italics",
);

is(
	render_markup("* ** ****\n\n** * ****"),
	"<p><em> <strong> *</strong></em></p>\n\n<p><strong> <em> *</em></strong></p>",
	">3 oblique ending nested bold and italics",
);

is(
	render_markup("**** * **\n\n**** * ***"),
	"<p><em>*** </em> **</p>\n\n<p><em>*** </em> ***</p>",
	"Italic badly-terminates >3 oblique",
);

is(
	render_markup("**** ** *\n\n**** ** ***"),
	"<p><strong>** </strong> *</p>\n\n<p><strong>** </strong> ***</p>",
	"Bold badly-terminates >3 oblique",
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

is(
	render_markup(q{[<script>''""](/)}),
	q{<p><a href="/">&lt;script&gt;&#39;&#39;&quot;&quot;</a></p>},
	"Link XSS, tag in link text",
);

is(
	render_markup(q{[](/<script>''"")}),
	q{<p><a href="/%3Cscript%3E''%22%22">/&lt;script&gt;&#39;&#39;&quot;&quot;</a></p>},
	"Link XSS, tag in link autotext",
);

is(
	render_markup(Encode::encode_utf8 '[☃](http://☃.com)'),
	'<p><a href="http://xn--n3h.com">☃</a></p>',
	"UTF-8 bytes handled properly",
);

done_testing;
