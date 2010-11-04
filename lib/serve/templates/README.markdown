What is this?
=============

This is a simple HTML prototype written in HAML or ERB that is designed to be
viewed with Serve.

What is Serve? Serve is a rapid prototyping framework for Rails applications.
It is designed to compliment Rails development and enforce a strict separation
of concerns between designer and developer. Using Serve with Rails allows the
designer to happily work in his own space creating an HTML prototype of the
application, while the developer works on the Rails application and copies
over HTML from the prototype as needed. This allows the designer to focus on
presentation and flow while the developer can focus on the implementation.


How do I install and run Serve?
-------------------------------

Serve is distributed as a gem to make it easy to get up and running. To
install, type the following at the command prompt:

    gem install serve

(OSX and Unix users may need to prefix the command with `sudo`.)

After Serve is installed, you can start it up in a given directory like this:

    serve

This will start Serve on port 4000. You can now view the prototype in your
Web browser at this URL:

<http://localhost:4000>

Click around. You will find that Serve enables you to prototype most
functionality without writing a single line of backend code.


Rack and Passenger
------------------

Astute users may notice that this project is also a simple Rack application.
This means that it is easy to deploy it on Passenger or rack it up with the
`rackup` command. For more information about using Serve and Passenger see:

<http://bit.ly/serve-and-passenger>