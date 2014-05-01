package MojoMafia::User;
use Mojo::Base 'Mojolicious::Controller';

sub auth {
	my $c = shift;
	return !!$c->user;
}

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
	$form->{audience} = $url->protocol . "://" . $url->host . ':' . $url->port;

	my $json = $c->ua->post($authority, form => $form)->res->json;

	if (!defined $json) {
		$c->res->code(500);
		return $c->render(json => {error => 'unknown'});
	} elsif ($json->{status} eq 'okay') {
		$c->session->{email} = $json->{email};
		if (!$c->user) {
			$json->{redirect} = '/register';
		}
		return $c->render(json => $json);
	} else {
		$c->res->code(401);
		$c->app->log->error('Login error: ' . $json->{reason});
		return $c->render(json => {error => $json->{reason}});
	}
}

sub logout {
	my $c = shift;
	delete $c->session->{email};
	$c->render(json => {status => 'okay'});
}

sub register {
	my $c = shift;

	if (!$c->session->{email} || $c->user) {
		return $c->redirect_to('/');
	}

	if (defined $c->req->headers->referrer) {
		$c->session->{register_redirect} = $c->req->headers->referrer;
	}

	$c->render(template => 'user/register');
}

sub do_register {
	my $c = shift;
	if ($c->user) {
		return $c->redirect_to($c->url_for('root/index'));
	}

	my $name = $c->param('username');
	my $email = $c->session->{email};
	if (defined $email && defined $name && $name ne '') {
		$c->db('Email')->create({
			address  => $c->session->{email},
			main     => 1,
			verified => 1,
			user => {
				name => $name,
			},
		});

		$c->redirect_to($c->session->{register_redirect} || '/');
		delete $c->session->{register_redirect};
	} else {
		$c->render(template => 'user/register');
	}
}

1;
