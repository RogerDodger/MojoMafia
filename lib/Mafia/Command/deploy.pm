package Mafia::Command::deploy;
use Bytes::Random::Secure qw/random_bytes_base64/;
use Mojo::Base 'Mafia::Command';
use Mojo::Loader;
use Mafia::Config;
use Mafia::Schema;
use Mafia::Setup qw/decode_setup/;
use Mafia::Role qw/:all/;

my $loader = Mojo::Loader->new;

sub run {
	my $self = shift;

	# DBD::SQLite specific -- change to support more deployment options
	my $db = (split /:/, $self->config->{dsn})[-1];

	if (_prompt_write($db, 'SQLite database')) {
		my $schema = Mafia::Schema->connect(
			$self->config->{dsn},'','',
			{ sqlite_unicode => 1 }
		);

		say "Deploying database...";
		$schema->deploy;

		# Not sure if necessary
		say '+ Creating admin';
		my $admin = $schema->resultset('User')->create({
			admin => 1,
			login => 'cthor',
			name => 'cthor',
		});

		$admin->password_set('sekrit');

		say '+ Creating F11 setup...';
		my $setup = $schema->resultset('Setup')->create({
			name      => 'F11',
			descr     => 'Standard newbie setup',
			allow_nk  => 1,
			allow_nv  => 1,
			day_start => 1,
			final     => 1,
			private   => 0,
		});

		$setup->add_pools(
			decode_setup $loader->data('Mafia::Setup', 'f11.setup')
		);
	}

	my $conf = $self->config->{cfn};
	if (_prompt_write($conf, 'YAML config')) {
		my $template = $loader->data('Mafia::Config', 'conf-template.yml');

		say "Creating config file...";
		open my $fh, '>', $conf;
		printf $fh $template, random_bytes_base64(16);
		close $fh;
	}

}

sub _prompt_write {
	my ($fn, $desc) = @_;
	return 1 unless -e $fn;

	print "$desc '$fn' already exists. Do you want to overwrite it? [y/n] ";

	chomp(my $ans = <STDIN>);
	if ($ans =~ /^(?:y|yes)$/i) {
		unlink $fn;
		return 1;
	}
	return 0;
}

'Construction complete.';
