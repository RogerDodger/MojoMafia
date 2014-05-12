package Mafia::Util;
use Mojo::Base qw/Exporter/;

our @EXPORT_OK = qw/maybe/;

sub maybe ($$) { defined $_[1] ? @_ : () }

1;
