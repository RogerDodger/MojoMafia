package Mafia::Command::deploy;
use Mojo::Base 'Mojolicious::Command';

use Mafia;
__PACKAGE__->app(Mafia->new);

sub run {
	my $self = shift;
	Mafia->new->meta->{version};
}

1;
