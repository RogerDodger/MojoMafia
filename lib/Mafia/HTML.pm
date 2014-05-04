package Mafia::HTML;
use Mojo::Base qw/Exporter/;
use Mojo::Util qw/xml_escape/;
use Mojo::DOM;
use Data::Dump;

our @EXPORT_OK = qw/tidy_html/;

my %BLOCK = map $_ => 1, qw{
	html head body
};

my %INLINE = map $_ => 1, qw{
	title
};

sub tidy {
	_tidy(Mojo::DOM->new->parse(shift), 0);
}

*tidy_html = \&tidy;

sub _tidy {
	my ($tree, $depth) = @_;

	# TODO - low priority
	return "$tree";
}

1;
