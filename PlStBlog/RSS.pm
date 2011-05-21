#!/usr/bin/perl -w

package PlStBlog::RSS;
use strict;

use POSIX qw/strftime/;

sub have_rss
{
     if (exists ($PlStBlog::Config::conf{rss}) and $PlStBlog::Config::conf{rss} = "yes")
     {
          return 1;
     }
     else
     {
          return 0;
     }
}

sub generate_rss
{
     my @entries = reverse (@_);

     if (&have_rss)
     {
          print ("Generating RSS 2.0...\n");

          use XML::RSS;

          my $rss = XML::RSS->new ( version => "2.0" );

          $rss->channel (
               title          => $PlStBlog::Config::conf{"rss.title"},
               link           => $PlStBlog::Config::conf{"rss.link"},
               language       => $PlStBlog::Config::conf{"rss.lang"},
               description    => $PlStBlog::Config::conf{"rss.description"},
               lastBuildDate  => strftime ($PlStBlog::Config::conf{datefmt}, localtime (time)),
               managingEditor => $PlStBlog::Config::conf{"rss.author"},
               webMaster      => $PlStBlog::Config::conf{"rss.author"}
          );

          # Add entries
          foreach my $entry (@entries)
          {
               print ("-- Add entry for: $entry\n");

               my %nfo = ();
               $nfo{date} = strftime ($PlStBlog::Config::conf{datefmt}, localtime ((stat ($PlStBlog::Config::conf{localposts}."/$entry"))[9]));
               ($nfo{idx}, $nfo{title}) = split (/\./, $entry);

               open (MARKDOWN, "perl Markdown.pl --html4tags \"".$PlStBlog::Config::conf{localposts}."/$entry\" |") or die "Error: Can't execute Markdown.pl: $!";
               my $content = join ("\n", <MARKDOWN>);
               close (MARKDOWN);

               $rss->add_item (
                    title       => $nfo{title},
                    link        => $PlStBlog::Config::conf{blogurl}."/post/".$nfo{idx}.".html",
                    description => $content,
                    pubDate     => $nfo{date}
               );
          }

          # Write output
          $rss->save ($PlStBlog::Config::conf{localpath}."rss2.xml");
     }
}

1;
