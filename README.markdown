plstblog is a static blog generator written in Perl.
It is released under the BSD license.

Author: David Delassus <david.jose.delassus@gmail.com>

## USAGE

     $ perl generate.pl [config file]

## CONFIGURATION

The configuration is pretty simple :

     blogurl=http://example.com/blog
     datefmt=%T %D
     localpath=/path/to/your/blog
     localposts=/path/to/your/articles.markdown

     tmpl.top=/path/to/your/header.template
     tmpl.bot=/path/to/your/footer.template

     tmpl.idx.top=/path/to/your/index/header.template
     tmpl.idx.bot=/path/to/your/index/footer.template

The configuration is save in : `$HOME/.plstblog.conf` or `./plstblog.conf`.

### Templates

The templates are just HTML files with some special variables which are replaced by the generator.

***NB:** There is no variables for index templates, they are just HTML files.*

For the other templates, variables are :

* `{%title%}` : Article's title.
* `{%idx%}` : Index of the article.
* `{%ohidden}` : If there is no previous article, its value is : `hidden` (can be added in a `class=` attribute).
* `{%nhidden}` : Same as above but for next article.
* `{%otitle%}` : Title of the previous article.
* `{%oidx%}` : Index of the previous article.
* `{%ntitle%}` : Title of the next article.
* `{%nidx%}` : Index of the next article.

Exemple of generated index :

     <ul>
          <li><span class="link"><a href="@blogurl@/post/{%idx%}.html">{%title%}</a></span><span class="date">Last edition: @date according to datefmt@</span></li>
          <li>...</li>
     </ul>

## Writing articles

Articles are written in *Markdown* syntax, put all of them into the folder `localposts` defined in your config file.
The filename must be named `<idx>.<title>.markdown`.
