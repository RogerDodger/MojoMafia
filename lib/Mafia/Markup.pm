package Mafia::Markup;
use Mojo::Base 'Exporter';
use Mojo::Util qw/xml_escape/;

our @EXPORT_OK = qw/render_markup/;

sub markup {
	my $text = shift;

	return join q{},
	         map { "<p>$_</p>" }
	           grep /\S/,
	             split /\n\n/, xml_escape $text;
}

*render_markup = \&markup;

1;
