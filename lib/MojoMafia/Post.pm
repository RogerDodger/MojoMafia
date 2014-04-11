package MojoMafia::Post;
use Mojo::Base "Mojolicious::Controller";

sub preview {
	my $c = shift;

	Mojo::IOLoop->timer(2 => sub {
		$c->render(text => '<p>' . $c->req->param('text') . '</p>');
	});
}

1;
