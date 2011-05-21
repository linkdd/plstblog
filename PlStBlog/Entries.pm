#!/usr/bin/perl -w

package PlStBlog::Entries;
use strict;

use POSIX qw/strftime/;

sub open_template
{
     my ($tmpl) = @_;

     open (FILEIN, "<".$PlStBlog::Config::conf{$tmpl}) or die "Error: Can't read ".$PlStBlog::Config::conf{$tmpl}.": $!";
     my @ret = <FILEIN>;
     close (FILEIN);

     return @ret;
}

sub get_entries
{
     my @entries = ();

     opendir (DIR, $PlStBlog::Config::conf{localposts}) or die "Error: Can't read directory ".$PlStBlog::Config::conf{localposts}.": $!";

     while (my $file = readdir (DIR))
     {
          next if ($file =~ m/^\./);
          @entries = (@entries, $file);
     }
     closedir (DIR);

     @entries = sort (@entries);
     return @entries;
}

sub generate_html
{
     my (@entries) = @_;

     for (my $i = 0; $i < @entries; $i++)
     {
          my $file = $entries[$i];
          my %nfo;

          ($nfo{idx}, $nfo{title}) = split (/\./, $file);

          $nfo{old} = 0;
          $nfo{new} = 0;

          # previous entry
          if ($i > 0)
          {
               $nfo{old} = 1;
               ($nfo{oidx}, $nfo{otitle}) = split (/\./, $entries[$i - 1]);
          }

          # next entry
          if ($i < (@entries - 1))
          {
               $nfo{new} = 1;
               ($nfo{nidx}, $nfo{ntitle}) = split (/\./, $entries[$i + 1]);
          }

          # Start generating
          print ("Generating $file...\n");

          my @output = &open_template ("tmpl.top");

          open (MARKDOWN, "perl Markdown.pl --html4tags \"".$PlStBlog::Config::conf{localposts}."/$file\" |") or die "Error: Can't execute Markdown.pl: $!";
          @output = (@output, <MARKDOWN>);
          close (MARKDOWN);

          @output = (@output, &open_template ("tmpl.bot"));

          # Replace template variables by their values
          foreach my $line (@output)
          {
               $line =~ s/{%idx%}/$nfo{idx}/g;
               $line =~ s/{%title%}/$nfo{title}/g;

               if ($PlStBlog::RSS::have_rss)
               {
                    $rsslink = "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"".$PlStBlog::Config::conf{"rss.title"}."\" href=\"".$PlStBlog::Config::conf{blogurl}."/rss2.xml";
                    $rssicon = "<a class=\"feed\" href=\"".$PlStBlog::Config::conf{blogurl}."/rss2.xml\">RSS Feeds</a>";
                    $line =~ s/{%rsslink%}/$rsslink/g;
                    $line =~ s/{%rssicon%}/$rssicon/g;
               }

               # previous entry
               if ($nfo{old})
               {
                    $line =~ s/{%oidx%}/$nfo{oidx}/g;
                    $line =~ s/{%otitle%}/$nfo{otitle}/g;
                    $line =~ s/{%ohidden%}//g;
               }
               else
               {
                    $line =~ s/{%oidx%}//g;
                    $line =~ s/{%otitle%}//g;
                    $line =~ s/{%ohidden%}/hidden/g;
               }

               # next entry
               if ($nfo{new})
               {
                    $line =~ s/{%nidx%}/$nfo{nidx}/g;
                    $line =~ s/{%ntitle%}/$nfo{ntitle}/g;
                    $line =~ s/{%nhidden%}//g;
               }
               else
               {
                    $line =~ s/{%nidx%}//g;
                    $line =~ s/{%ntitle%}//g;
                    $line =~ s/{%nhidden%}/hidden/g;
               }
          }

          # Write output
          if ( ! -e $PlStBlog::Config::conf{"localpath"} )
          {
               mkdir ($PlStBlog::Config::conf{"localpath"}) or die "Error: Can't create directory ".$PlStBlog::Config::conf{localpath}.": $!";
          }

          if ( ! -e $PlStBlog::Config::conf{"localpath"}."/post" )
          {
               mkdir ($PlStBlog::Config::conf{"localpath"}."/post") or die "Error: Can't create directory".$PlStBlog::Config::conf{localpath}."/post: $!";
          }

          open (OUTPUT, ">".$PlStBlog::Config::conf{"localpath"}."/post/$nfo{idx}.html") or die "Error: Can't write to ".$PlStBlog::Config::conf{"localpath"}."/post/$nfo{idx}.html: $!";
          foreach my $line (@output)
          {
               printf (OUTPUT "%s", $line);
          }
          close (OUTPUT);
     }
}

sub generate_index
{
     my @entries = @_;

     print ("Generating index...\n");

     my @output = (&open_template ("tmpl.idx.top"), "<ul>\n");

     @entries = reverse (@entries);

     # list entries
     foreach my $entry (@entries)
     {
          my %nfo;
          $nfo{date} = strftime ($PlStBlog::Config::conf{datefmt}, localtime ((stat ($PlStBlog::Config::conf{localposts}."/$entry"))[9]));

          ($nfo{idx}, $nfo{title}) = split (/\./, $entry);

          @output = (@output, "<li><span class=\"link\"><a href=\"".$PlStBlog::Config::conf{blogurl}."/post/".$nfo{idx}.".html\">".$nfo{title}."</a></span>".
                    "<span class=\"date\">Last edition: ".$nfo{date}."</span></li>\n");
     }

     @output = (@output, "</ul>\n", &open_template ("tmpl.idx.bot"));

     # write output to the file
     if ( ! -e $PlStBlog::Config::conf{"localpath"} )
     {
          mkdir ($PlStBlog::Config::conf{"localpath"}) or die "Error: Can't create directory ".$PlStBlog::Config::conf{localpath}.": $!";
     }

     open (INDEX, ">".$PlStBlog::Config::conf{localpath}."/index.html") or die "Error: Can't write to ".$PlStBlog::Config::conf{localpath}."/index.html: $!";
     foreach my $line (@output)
     {
          if ($PlStBlog::RSS::have_rss)
          {
               $rsslink = "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"".$PlStBlog::Config::conf{"rss.title"}."\" href=\"".$PlStBlog::Config::conf{blogurl}."/rss2.xml";
               $rssicon = "<a class=\"feed\" href=\"".$PlStBlog::Config::conf{blogurl}."/rss2.xml\">RSS Feeds</a>";
               $line =~ s/{%rsslink%}/$rsslink/g;
               $line =~ s/{%rssicon%}/$rssicon/g;
          }

          printf (INDEX "%s", $line);
     }
     close (INDEX);
}

1;
