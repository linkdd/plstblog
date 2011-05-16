#!/usr/bin/perl -w

sub load_configuration
{
     ($config) = @_;

     my %ret = ();

     open (CONFIG, "<$config");
     my @conf = <CONFIG>;
     close (CONFIG);

     foreach $line (@conf)
     {
          next if ($line =~ m/^\n/);

          ($key, $value) = split (/=/, $line);
          $value =~ s/\n//g;
          $ret{$key} = $value;
     }

     return %ret;
}

1;
