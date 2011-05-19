#!/usr/bin/perl -w

use strict;
use PlStBlog;

my %config = ();

if (exists ($ARGV[0]) && -e $ARGV[0])
{
     print ("Reading ".$ARGV[0]." ...\n");
     PlStBlog::Config::load_configuration ($ARGV[0]);
}
elsif ( -e $ENV{HOME}."/.config/plstblog.conf" )
{
     print ("Reading ".$ENV{HOME}."/.config/plstblog.conf ...\n");
     PlStBlog::Config::load_configuration ($ENV{HOME}."/.config/plstblog.conf");
}
elsif ( -e "./plstblog.conf" )
{
     print ("Reading ./plstblog.conf ...\n");
     PlStBlog::Config::load_configuration ("./plstblog.conf");
}
else
{
     die "No configuration found.\n";
}

my @entries = PlStBlog::Entries::get_entries ();

PlStBlog::Entries::generate_html (@entries);
PlStBlog::Entries::generate_index (@entries);
PlStBlog::RSS::generate_rss (@entries);
