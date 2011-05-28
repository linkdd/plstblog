#!/usr/bin/perl -w

package PlStBlog::Config;
use strict;

our %conf = ();

sub strip
{
     my ($str) = @_;

     $str =~ s/^( +)//g;
     $str =~ s/( +)$//g;
     $str =~ s/\n//g;

     return $str;
}

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

          # Strip useless spaces
          $key   = &strip ($key);
          $value = &strip ($value);

          $conf{$key} = $value;
     }
}

1;
