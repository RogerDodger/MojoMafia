package Mafia::Command::deploy;
use Mojo::Base 'Mojolicious::Command';
use Mafia::Schema;

sub run {
	my $self = shift;

	my $fn = $self->rel_file('data/mafia.db');

	if (-e $fn) {
		print "! $fn already exists and will be overwritten.\n"
		    . "! Do you want to continue? [y/n] ";
		chomp(my $ans = <STDIN>);
		if (lc $ans ~~ ['y', 'yes']) {
			unlink $fn;
		}	
		else {
			say "Aborting deploy.";
			exit(0);
		}
	}

	say "Deploying database...";
	my $schema = Mafia::Schema->connect(
		"dbi:SQLite:$fn",'','',
		{ ignore_version => 1 }
	);
	$schema->deploy;

	$schema->resultset('Team')->populate([
		[  qw/name type/   ],
		[ 'Town',   'Town' ],
		[ 'Mafia',  'Scum' ],
		[ 'Bratva', 'Scum' ],
		[ 'Yakuza', 'Scum' ],
		[ 'Other',  'Other' ],
	]);
}

'Construction complete.';
