

use Irssi;
use strict;
use vars qw($VERSION %IRSSI);

$VERSION = "0.0.1";
%IRSSI = (
    authors     => 'slyfox',
    name        => 'public message signal',
    description => 'wave sound player on PRIVMSG #channel',
    license     => 'Public Domain'
);

sub all_up
{
    my $sound="pubmsg.wav";
    `aplay ~/.irssi/sounds/$sound >/dev/null 2>&1 &`;
}

Irssi::signal_add_last('message public', 'all_up');
