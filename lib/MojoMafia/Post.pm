package MojoMafia::Post;
use Mojo::Base "Mojolicious::Controller";
use Mafia::Markup qw/markup/;

sub post_game {
	my $c = shift;
	my ($body, $audience) = $c->param([qw/body audience/]);

	return unless $c->stash->{player} && $body && $audience;

	my $public = $audience eq 'town';
}

sub preview {
	my $c = shift;

	my $response = markup $c->param('text');
	Mojo::IOLoop->timer(2 => sub {
		$c->render(text => $response);
	});
}

1;
