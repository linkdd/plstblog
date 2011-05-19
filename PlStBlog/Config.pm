#!/usr/bin/perl -w

package PlStBlog::Config;
use strict;

our %conf = ();

sub load_configuration
{
     my ($confpath) = @_;

     open (CONFIG, "<$confpath") or die "Error: Can't read $confpath : $!";
     my @content = <CONFIG>;
     close (CONFIG);

     foreach my $line (@content)
     {
          next if ($line =~ m/^\n/);

          my ($key, $value) = split (/=/, $line);
          $value =~ s/\n//g;
          $conf{$key} = $value;
     }
}

1;
