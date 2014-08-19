#/usr/bin/env perl

use 5.014;
use Getopt::Long;

GetOptions(\my %opt, 'devel|development');

my @production = qw/
	Mojolicious~3.89
	Mojolicious::Plugin::PlainRoutes~0.04
	DBIx::Class~0.08210
	SQL::Translator~0.11016
	DBIx::Class::DynamicDefault~0.04
	DBIx::Class::InflateColumn::Serializer~0.06
	IO::Socket::SSL~1.84
	Class::Null~2.110730
	HTML::Entities~3.69
	Bytes::Random::Secure~0.28
	Crypt::Eksblowfish::Bcrypt~0.009
/;

my @development = qw/
	JavaScript::Minifier~1.05
	Text::Sass::XS~0.10
	Text::Lorem::More~0.13
/;

if (eval { require App::cpanminus; 1; }) {
	*install = sub { system 'cpanm', @_ };
}
else {
	require CPAN;
	CPAN->import;
}

say "Installing production dependencies...";
install(@production);

if ($opt{devel}) {
	say "Installing development dependencies...";
	install(@development);
}
