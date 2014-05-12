package Mafia::Command::deploy;
use Mojo::Base 'Mafia::Command';
use Mafia::Schema;
use Data::Dump;

sub run {
	my $self = shift;

	# DBD::SQLite specific -- change to support more deployment options
	my $fn = (split /:/, $self->config->{dsn})[-1];
	if (-e $fn) {
		print "SQLite database '$fn' already exists and will be overwritten. "
		    . "Do you want to continue? [y/n] ";
		chomp(my $ans = <STDIN>);
		if ($ans =~ /^(?:y|yes)$/i) {
			unlink $fn;
		}
		else {
			say "Aborting deploy.";
			exit(1);
		}
	}

	say "Deploying database...";
	my $schema = Mafia::Schema->connect(
		$self->config->{dsn},'','',
		{ sqlite_unicode => 1, ignore_version => 1 }
	);
	$schema->deploy;

	say '+ Creating roles';
	$schema->resultset('Role')->populate([
		map { { name => $_ } } qw/townie cop doctor goon godfather roleblocker/
	]);

	say '+ Creating user `Nobody`';
	my $nobody = $schema->resultset('User')->create({
		name => 'Nobody',
	});

	say '+ Creating F11 setup...';
	my $setup = $schema->resultset('Setup')->create({
		user_id   => $nobody->id,
		name      => 'F11',
		descr     => 'Standard newbie setup',
		allow_nk  => 1,
		allow_nv  => 1,
		day_start => 1,
		final     => 1,
		private   => 0,
	});

	my %roles = map { $_->name, $_->id } $schema->resultset('Role')->all;

	my @pools = (
		[
			([ qw/townie/ ]) x 5,
			([ qw/townie cop/ ]) x 1,
			([ qw/townie doctor/ ]) x 1,
			([ qw/goon roleblocker/ ]) x 1,
			([ qw/goon/ ]) x 1,
		],
		[
			([ qw/townie/ ]) x 6,
			([ qw/townie cop/ ]) x 1,
			([ qw/goon/ ]) x 2,
		],
		[
			([ qw/townie/ ]) x 6,
			([ qw/townie doctor/ ]) x 1,
			([ qw/goon/ ]) x 2,
		],
		[
			([ qw/townie/ ]) x 7,
			([ qw/townie cop/ ]) x 1,
			([ qw/goon/ ]) x 1,
		],
	);

	my $i = 0;
	for my $pool (@pools) {
		for my $player (@$pool) {
			for my $role (@$player) {
				$setup->create_related('setup_roles', {
					player_no => 1 + $i % 9,
					role_id   => $roles{$role},
					pool      => 1 + int($i / 9),
				});
			}
			$i++;
		}
	}
}

'Construction complete.';
