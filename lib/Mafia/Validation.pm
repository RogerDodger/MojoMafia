package Mafia::Validation;
use Mojo::Base qw/Mojolicious::Plugin/;

sub register {
	my ($self, $app) = @_;

	my $v = $app->validator;

	$v->add_check(perlword => \&_perlword);
	$v->add_check(secure => \&_secure);
}

sub _perlword {
	return $_[2] !~ /^[0-9a-zA-Z_]+$/;
}

sub _secure {
	my ($v, $name, $password) = @_;

	return 1 if length $password < 5;

	# TODO: Check dictionary here

	return 0;
}

1;
