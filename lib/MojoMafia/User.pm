package MojoMafia::User;
use Mojo::Base 'Mojolicious::Controller';

sub auth {
	my $c = shift;
	return 1 if $c->user;

	$c->render(text => 'You are not logged in');
	undef;
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
	return $c->redirect_to('/') if $c->user;

	# Validate input
	my $v = $c->validation;

	$v->required('uname')->perlword;
	$v->required('rpword')->equal_to($c->param('pword'));
	$v->required('pword')->secure;

	return $c->render(template => 'user/register') if $v->has_error;

	# Create user
	my $user = $c->db('User')->create({
		name => $v->param('uname'),
		dname => $v->param('uname'),
		nname => lc $v->param('uname'),
	});

	$user->password_set($v->param('pword'), $c->app->config('bcost'));
}

1;
