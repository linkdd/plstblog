#!/usr/bin/perl -w

use POSIX qw/strftime/;

my %conf;

sub set_conf
{
     %conf = @_;
}

sub open_template
{
     ($tmpl) = @_;

     open (FILEIN, "<".$conf{$tmpl}) or die $!;
     my @ret = <FILEIN>;
     close (FILEIN);

     return @ret;
}

sub get_entries
{
     my @entries = ();

     opendir (DIR, $conf{localposts}) or die $!;

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
     (@entries) = @_;

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

          open (MARKDOWN, "perl Markdown.pl --html4tags \"".$conf{localposts}."/$file\" |");
          @output = (@output, <MARKDOWN>);
          close (MARKDOWN);

          @output = (@output, &open_template ("tmpl.bot"));

          # Replace template variables by their values
          foreach $line (@output)
          {
               $line =~ s/{%idx%}/$nfo{idx}/g;
               $line =~ s/{%title%}/$nfo{title}/g;

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
          if ( ! -e $conf{"localpath"} )
          {
               mkdir ($conf{"localpath"}) or die $!;
          }

          if ( ! -e $conf{"localpath"}."/post" )
          {
               mkdir ($conf{"localpath"}."/post") or die $!;
          }

          open (OUTPUT, ">".$conf{"localpath"}."/post/$nfo{idx}.html") or die $!;
          foreach $line (@output)
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
     foreach $entry (@entries)
     {
          my $date = strftime ($conf{datefmt}, localtime ((stat ($conf{localposts}."/$entry"))[9]));
          my %nfo;

          ($nfo{idx}, $nfo{title}) = split (/\./, $entry);

          @output = (@output, "<li><span class=\"link\"><a href=\"".$conf{blogurl}."/post/".$nfo{idx}.".html\">".$nfo{title}."</a></span>".
                    "<span class=\"date\">Last edition: $date</span></li>\n");
     }

     @output = (@output, "</ul>\n", &open_template ("tmpl.idx.bot"));

     # write output to the file
     if ( ! -e $conf{"localpath"} )
     {
          mkdir ($conf{"localpath"}) or die $!;
     }

     open (INDEX, ">".$conf{localpath}."/index.html") or die $!;
     foreach $line (@output)
     {
          printf (INDEX "%s", $line);
     }
     close (INDEX);
}

1;
