#!/usr/bin/perl -w

require "plstblog.pl";

my %config = ();

if (exists ($ARGV[0]) && -e $ARGV[0])
{
     print ("Reading ".$ARGV[0]." ...\n");
     %config = &load_configuration ($ARGV[0]);
}
elsif ( -e $ENV{HOME}."/.plstblog.conf" )
{
     print ("Reading ".$ENV{HOME}."/.plstblog.conf ...\n");
     %config = &load_configuration ($ENV{HOME}."/.plstblog.conf");
}
elsif ( -e "./plstblog.conf" )
{
     print ("Reading ./plstblog.conf ...\n");
     %config = &load_configuration ("./plstblog.conf");
}
else
{
     die "No configuration found.\n";
}

&set_conf (%config);

my @entries = &get_entries ();

&generate_html (@entries);
&generate_index (@entries);
