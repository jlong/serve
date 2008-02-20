== Serve

Serve is a small Ruby script that makes it easy to start up a WEBrick server
in any directory. Serve is ideal for HTML prototyping and simple file sharing.
If the haml, redcloth, and bluecloth gems are installed serve can handle Haml,
Sass, Textile, and Markdown (in addition to HTML).


=== Usage

At a command prompt all you need to type to start serve is:

  $ serve

This will launch a WEBrick server which you can access from any Web browser at
the following address:

  http://localhost:4000

Once the server is going it will output a running log of its activity. To
stop the server at any time, type CTRL+C at the command prompt. By default the
serve command serves up files from the current directory. To change this
behavior, `cd` to the appropriate directory before starting serve.


=== Advanced Options

The serve command automatically binds to 0.0.0.0 (localhost) and uses port
4000 by default. To serve files over a different IP (that is bound to your
computer) or port specify those options on the command line:

  $ serve 4000               # a custom port

  $ serve 192.168.1.6        # a custom IP

  $ serve 192.168.1.6:4000   # a custom IP and port


=== Rails Applications

For your convenience if the file "script/server" exists in the current
directory the serve command will start that instead of launching a WEBrick
server. You can specify the environment that you want to start the server
with as an option on the command line:

  $ serve production         # start script/server in production mode


=== File Types

Serve presently does special processing for files with following extensions:

textile :: Evaluates the document as Textile (requires the Redcloth gem) 
markdown :: Evaluates the document as Markdown (requires the Bluecloth gem)
haml :: Evaluates the document as Haml (requires the Haml gem)
sass :: Evaluates the document as Sass (requires the Haml gem)
email :: Evaluates the document as if it is an e-mail message; the format is identicle to a plain/text e-mail message's source
redirect :: Redirects to the URL contained in the document


=== Installation and Setup

It is recommended that you install serve via RubyGems:

  $ sudo gem install serve


=== More Information

For more information, be sure to look through the documentation over at
RubyForge:

* http://serve.rubyforge.org

Or visit the project page here:

* http://rubyforge.org/projects/serve


=== License

Serve is released under the MIT license and is copyright (c) 2006-2007
John W. Long. A copy of the MIT license can be found in the License.txt file.


Enjoy!

--
John Long :: http://wiseheartdesign.com
