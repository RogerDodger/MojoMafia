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

sub register {
	shift->render;
}

sub do_register {
	my $c = shift;
	return $c->redirect_to('/') if $c->user || !defined $c->session->{email};

	my $u = $c->param('username');

	if ($c->db('User')->find({ name => $u })) {
		# User already exists
		$c->redirect_to('/register');
	}

	$c->db('Email')->create({
		address  => $c->session->{email},
		main     => 1,
		verified => 1,
		user => {
			name => $u,
		},
	});

	$c->redirect_to('/');
}

1;
