

use Irssi;
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "0.0.1";
%IRSSI = (
    authors     => 'slyfox',
    name        => 'hilight signal',
    description => 'wave sound player on HILIGHT',
    license     => 'Public Domain'
);

sub wake_up
{
    my $sound="hilight.wav";
    `aplay ~/.irssi/sounds/$sound >& /dev/null &`;
}

Irssi::signal_add_last('window item hilight', 'wake_up');
