package MojoMafia::User;
use Mojo::Base 'Mojolicious::Controller';

sub login {
	my $c = shift;
	my $form = {};
	state $authority = 'https://verifier.login.persona.org/verify';

	$form->{assertion} = $c->param('assertion');
	if (!defined $form->{assertion}) {
		$c->res->code(400);
		return $c->render(json => {error => 'no assertion sent'});
	}

	my $url = $c->req->url->to_abs;
	$form->{audience} = $url->protocol . "://" . $url->host;

	my $json = $c->ua->post($authority, form => $form)->res->json;

	if (!defined $json) {
		$c->res->code(500);
		return $c->render(json => {error => 'unknown'});
	}
	elsif ($json->{status} eq 'okay') {
		$c->session->{email} = $json->{email};
		return $c->render(json => {status => 'okay'});
	}
	else {
		$c->res->code(401);
		return $c->render(json => {error => $json->{reason}});
	}
}

sub logout {
	my $c = shift;
	delete $c->session->{email};
	$c->render(json => {status => 'okay'});
}

1;
