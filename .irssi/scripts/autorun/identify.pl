use Irssi;
use strict;
use vars qw($VERSION %IRSSI);
use utf8;

$VERSION = "0.1.0";
%IRSSI = (
    authors     => 'slyfox',
    name        => 'nickserv registration',
    description => 'autoregisters on services reraise',
    license     => 'GPLv2+'
);

my @passdict=(
               ['sf@bynets', '[e`htcnm'],
               ['slyfox@bynets', '[e`htcnm'],
               ['wraith@bynets', '[e`htcnm'],
               ['warg@bynets', '[e`htcnm'],
               ['skogtroll@bynets', '[e`htcnm'],
               ['Fenrisulfr@bynets', '[e`htcnm'],
               ['reify@bynets', '[e`htcnm'],
               ['mergemaster@bynets', '[e`htcnm'],
               ['kettu@bynets', '[e`htcnm'],
               ['northstar@bynets', '[e`htcnm'],

               ['trofimovich@freenode', 'CahXeeK6eiph5eighiePhahwoinu1A'],
               ['trofi@freenode',       'CahXeeK6eiph5eighiePhahwoinu1A'],
               ['slyfox@freenode',      'CahXeeK6eiph5eighiePhahwoinu1A'],
               ['slyfox_@freenode',     'CahXeeK6eiph5eighiePhahwoinu1A'],

               ['slyfox@oftc', 'slyfoxonoftc']
           );
sub find_pass
{
    my $sig = $_[0];
    print ("try lookup ".$sig);
    #
    #
    #  [ user@network => password ]
    for my $i (@passdict)
    {
        return $i->[1] if ( $sig eq $i->[0] );
    }
    return ;
};

sub ns_callback
{
  my ($server, $data, $nick, $host, $mynick) = @_;
  if ( ! $nick or !($nick =~ /^nickserv$/i ) or !($data =~ /IDENTIFY/i)) 
  {
    return;
  }
  
  my $fullname = $mynick.'@'.$server->{'chatnet'};
  my $pass = find_pass($fullname);
  if ($pass)
  {
      $server->command("/^msg nickserv IDENTIFY $pass");
  }
};

Irssi::signal_add_last('message irc notice', 'ns_callback');
