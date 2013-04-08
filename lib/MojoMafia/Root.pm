package MojoMafia::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index {
	my $self = shift;

	$self->app->log->info("Root::index accessed.");

	require Text::Markdown;
	require Text::Lorem::More;
	my $lorem = Text::Lorem::More->new;
	$self->stash(
		posts => { all => [
			{
				id => 2,
				user => {
					name => 'Nolegs',
				},
				show_username => 1,
				class => 'day',
				gamedate => 1,
				plain => $lorem->paragraphs(2),
				created => DateTime->now->subtract(hours => 2, minutes => 4, seconds => 57),
			}, 
			{
				id => 3,
				class => 'day system',
				gamedate => 1,
				plain => $lorem->sentence,
				created => DateTime->now->subtract(hours => 1, minutes => 16, seconds => 32),
			},
			{
				id => 4,
				user => {
					name => 'Geoff',
				},
				player => {
					alias => 'Geoffery',
				},
				class => 'day',
				gamedate => 1,
				plain => $lorem->paragraphs(3),
				created => DateTime->now->subtract(hours => 1, minutes => 14, seconds => 2),
			},
			{
				id => 7,
				user => {
					name => 'Nolegs',
				},
				show_username => 1,
				class => 'day',
				gamedate => 1,
				plain => $lorem->paragraph,
				created => DateTime->now->subtract(hours => 1, minutes => 12, seconds => 11),
			},
			{
				id => 9,
				class => 'day system',
				gamedate => 1,
				plain => $lorem->sentence,
				created => DateTime->now->subtract(hours => 1, minutes => 3, seconds => 32),
			},
			{
				id => 11,
				user => {
					name => 'Sadida',
				},
				player => {
					alias => 'Alfred',
				},
				show_username => 1,
				class => 'day',
				gamedate => 1,
				plain => $lorem->paragraphs(3),
				created => DateTime->now->subtract(minutes => 27, seconds => 43),
			},
			{
				id => 12,	
				class => 'day system',
				gamedate => 1,
				plain => $lorem->sentence,
				created => DateTime->now->subtract(minutes => 27, seconds => 42),
			},
			{
				id => 15,
				user => {
					name => 'Sadida',
				},
				player => {
					alias => 'Alfred',
				},
				show_username => 1,
				class => 'night',
				gamedate => 1,
				plain => $lorem->paragraphs(4),
				created => DateTime->now->subtract(minutes => 24, seconds => 7),
			},
			{
				id => 18,
				user => {
					name => 'Sadida',
				},
				player => {
					alias => 'Alfred',
				},
				show_username => 1,
				class => 'night',
				gamedate => 1,
				plain => $lorem->paragraphs(2),
				created => DateTime->now->subtract(minutes => 14),
			},
		]}
	);

	$self->render();
}

1;
