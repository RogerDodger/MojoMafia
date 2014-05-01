package Mafia::Markup;
use Mojo::Base 'Exporter';

our @EXPORT_OK = qw/markup/;

sub markup {
	my $text = shift;

	return join '',
	         map { "<p>$_</p>" }
	           split /\n\n/, $text;
}

1;
