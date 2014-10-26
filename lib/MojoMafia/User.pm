package MojoMafia::User;
use Mojo::Base 'Mojolicious::Controller';

sub auth {
	my $c = shift;

	if ($c->user) {
		return 1;
	}
	else {
		$c->flash(error_msg => 'You must be logged in to do that');
		$c->redirect_to($c->referrer || '/');
		return undef;
	}
}

sub create {
	my $c = shift;
	return $c->redirect_to('/') if $c->user;

	$c->render(template => 'user/register');
}

sub login {
	my $c = shift;

	my $user = $c->db('User')->find({ name => $c->param('uname') });
	if (defined $user) {
		if ($user->password_check($c->param('pword'))) {
			$c->session->{user_id} = $user->id;
		} else {
			$c->flash(error_msg => 'Login failed: invalid password');
		}
	} else {
		$c->flash(error_msg => 'Login failed: user not found');
	}

	$c->redirect_to($c->req->headers->referrer || '/');
}

sub logout {
	my $c = shift;
	delete $c->session->{user_id};
	$c->redirect_to($c->req->headers->referrer || '/');
}

sub post {
	my $c = shift;

	if (!$c->user) {
		# Validate input
		my $v = $c->validation;

		$v->required('uname')->perlword;
		$v->required('pword')->secure;
		$v->required('rword')->equal_to('pword');

		if ($v->has_error) {
			return $c->render(template => 'user/register');
		}

		# Create user
		my $user = $c->db('User')->create({
			name => $v->param('uname'),
			dname => $v->param('uname'),
			nname => lc $v->param('uname'),
		});
		$user->password_set($v->param('pword'), $c->app->config('bcost'));

		$c->app->log->info("User created: " . $user->name);

		$c->session->{user_id} = $user->id;
	}

	$c->redirect_to('/');
}

1;
