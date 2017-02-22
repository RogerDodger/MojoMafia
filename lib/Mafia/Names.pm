use utf8;
package Mafia::Names;
use Mafia::Base 'Mojolicious::Plugin';

use File::stat;
use Mojo::Loader qw/data_section/;
use Mojo::JSON qw/encode_json/;

my %dicts;
for (keys data_section(__PACKAGE__)->%*) {
	next unless /^(.+)\.dict$/;
	my $name = $1;
	my $data = data_section(__PACKAGE__, $_);

	my @dict;
	for my $group (split /\n\n/, $data) {
		push @dict, [ split /\s+/, $group ];
	}
	$dicts{$name} = \@dict;
}

sub random_name {
	my $self = shift;
	my $dict = $dicts{shift // 'elvish'};

	my $n = 1 + _r(.5) + _r(.2) + _r(.1) + _r(.05);

	my $name = '';
	for (0..$n) {
		my $i = { 0 => 0, $n => 2 }->{$_} // 1;
		$name .= $dict->[$i][rand @{ $dict->[$i] }];
	}
	return $name;
}

sub register {
	my ($self, $app) = @_;

	my $in = $app->home->rel_file('templates/names.js.ep');
	my $out = $app->home->rel_file('public/js/src/names.js');
	return if stat($in)->mtime < stat($out)->mtime;

	# For some really weird reason, doing $app->build_controller->render
	# causes the renderer to throw complaints about "user" being undefined in
	# the templates, presumably because the helpers are going away for some
	# reason. I have no idea why this would happen, but making an entirely
	# new app context for the render here dodges the strange behaviour.
	my $app_ = Mojolicious->new(home => Mojo::Home->new('.'));

	my $output = $app_->build_controller->render_to_string('names',
		partial  => 1,
		format   => 'js',
		dicts    => encode_json([ @dicts{qw/elvish elements nordic/} ]),
	);

	$app->log->debug("Overwrite $out");
	open my $fh, '>', $out;
	print $fh $output;
	close $fh;
}

# Return 1 with given chance
sub _r { return rand() < shift }

1;

__DATA__

@@ elvish.dict

A Aeg Am An Ang Ar Be Ca Ce Cu Dae De Di E Ear Ec El Er Fae Fea Fein Fel Fin
Ga Gal Gel Gil Glor Guil Gwai Gwin Hal Hu Hu Ing Id Ind Leg Len Lin Lo Luth
Maed Maeg Mag Mah Mir Ner Nim Nin Ol Or Ru Ser Tel Thin Thran Tin Tu Tur Um
Und Vor

ar be bri brim brin da do dri du du ed el fin gar glo go gol i la le len li
liv lu mi nar ne ni nu ram ran re red rei ren ri rin ro rod ru the thi tho vi
wa

an bar bor born char dal dan de del dor dhel dil dir el en eth fin glin glor
gol gon gorm gund hil hir hros il ion is lad las lin marth miom mil mir moth
nas nion nor ol on oth or ras red reth rin rion rod ron rond ros roth stor tan
thir thor we wen wing

@@ elements.dict

A An Ar As Ba Be Ber Bis Bo Bro Ca Cad Cae Cal Car Ce Ch Chro Co Cop Cu Dys Er
Eu Flu Fran Ga Gal Ger Haf He Hol Hy In Io Ir Kryp Lan Li Lu Mag Man Mer Mo Ne
Nep Ni Os O Pal Phos Pla Plu Po Pra Pro Ra Rhe Rho Ru Sa Scan Se Si Sil So
Stron Sul Tan Tech Tel Ter Thal Tho Thu Ti Tung U Va Xe Zir

bi ci co cu de di do dro dy for ga i ke la le li lo lu lyb ma me mi mo na ne
ni o pho pi pro ra ri ro ryl se seo si ta tas te tha the thi ti to tri tro tu
xy

balt bon con dine don fur gen gon lum mine muth nese nic non num ny on per
rine ron rus ry sten tine ton um ver

@@ nordic.dict

A Ab Ad Ae Ag Al Alf An Ar Ark Arn Aum Ba Bar Bed Bjad Bor Bot Bra Bri Bru Cri
Dag Dath Dryn Ei Eig Ek Enn Erg Ey Fa Fjol Fjor Fra Gar God Gog Grei Gud Ha
Haa Hae Ham Hedd Hef Heid Heif Hel Herd Hi Hir Hjo Hjol Hjron Hlar Hlor Ho Hod
Hol Honth Hor Hrar Hrei Hris Hro Hron Hror Hrun Hu Hurg Hurn Hy I Id Ig Il Im
In Jol Kar Knur Kun Lo Mae Men Mer Met Nor Od On Ra Radd Raf Ran Ring Rogg
Rost Ru Sa Sae Sar Si Sif Sit Sjarn Sjo Sjor Sna Sno Snor Sork Sot Star Svog
Tha Tho Thon Thro Thu Thun Ur Val Vel Vir Vo Vong Yng

ad ge gok gu he ir ko la le lis lo raf ri ru

a bard bjof dar del di dil ding dir dis eas fhild fid fing fred ga gal gar
geir gerd gheid gi gil i ja jolf kar khi ki knir knolf kon la lin ling lod lof
ma man mar mi ming mir mod mund na nar ning nir ra rek ri rid ring rir rod
rolf si sin skar slod smar star steir stris stus ta tar te thar tilde to tra
tring und var vard vild vir

__END__

=pod

=head1 NAME

Mafia::Names - Generate fake but real-sounding names

=cut
