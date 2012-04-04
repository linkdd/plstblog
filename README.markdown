plstblog is a static blog generator written in Perl.
It is released under the BSD license.

Author: David Delassus <david.jose.delassus@gmail.com>

## REQUIREMENT

* XML::RSS
* Markdown :
  * Digest::MD5

## USAGE

     $ perl generate.pl [config file]

## CONFIGURATION

The configuration is pretty simple :

     blogurl=http://example.com/blog
     datefmt=%T %D
     localpath=/path/to/your/blog
     localposts=/path/to/your/articles/

     tmpl.top=/path/to/your/header.template
     tmpl.bot=/path/to/your/footer.template

     tmpl.idx.top=/path/to/your/index/header.template
     tmpl.idx.bot=/path/to/your/index/footer.template

The configuration is save in : `$HOME/.plstblog.conf` or `./plstblog.conf`.

### RSS 2.0

If you want generate a RSS 2.0 summary, just add this to your conf :

     rss=yes
     rss.title=Your RSS title
     rss.link=http://example.com/
     rss.lang=en
     rss.description=Example of RSS summary
     rss.author=author@example.com

### Templates

The templates are just HTML files with some special variables which are replaced by the generator.

For all templates, variables are :

* `{%rsslink%}` : Link to the RSS feeds (to put in `<head></head>`).
* `{%rssicon%}` : Link to the RSS feeds (to put in `<body></body>`).

For articles templates, variables are :

* `{%title%}` : Article's title.
* `{%idx%}` : Index of the article.
* `{%ohidden}` : If there is no previous article, its value is : `hidden` (can be added in a `class=` attribute).
* `{%nhidden}` : Same as above but for next article.
* `{%otitle%}` : Title of the previous article.
* `{%oidx%}` : Index of the previous article.
* `{%ntitle%}` : Title of the next article.
* `{%nidx%}` : Index of the next article.


Exemple of generated index :

     <table id="plstblog_index">
          <thead><tr><th class="title">Title</th><th class="lastedit">Last edition</th></tr></thead>
          <tbody>
               <tr><td class="link"><a href="@blogurl@/post/{%idx%}.html">{%title%}</a></td><td class="lastedit">@date according to datefmt@</td></tr>
               ...
          </tbody>
     </table>

## Writing articles

Articles are written in *Markdown* syntax, put all of them into the folder `localposts` defined in your config file.
The filename must be named `<idx>.<title>.markdown`.
