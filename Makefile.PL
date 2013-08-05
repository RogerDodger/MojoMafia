#/usr/bin/env perl

use 5.014;
use lib::App::cpanminus;
use Getopt::Long;

GetOptions(\my %opt, 'devel|development');

my @production = qw(
	Mojolicious~3.89
	DBIx::Class~0.08210
	SQL::Translator~0.11016
	DBIx::Class::DynamicDefault~0.04
	DBIx::Class::InflateColumn::Serializer
	Class::Null
);

say "Installing production dependencies...";
my $cpanm = App::cpanminus::script->new;
$cpanm->{argv} = \@production;
$cpanm->doit;

exit(0) unless $opt{devel};

my @development = qw(
	JavaScript::Minifier~1.05
	Text::Lorem::More~0.13
);

say "Installing development dependencies...";
$cpanm->{argv} = \@development;
$cpanm->doit;
