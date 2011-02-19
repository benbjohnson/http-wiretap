HTTP Wiretap - An HTTP Recorder
===============================

## DESCRIPTION

HTTP Wiretap is a library used to log HTTP requests and responses within your
application. This can be useful when trying to determine what is occurring in
your application or when trying to debug someone else's application.

This library follows the rules of [Semantic Versioning](http://semver.org/).


## RUNNING

To install HTTP Wiretap, simply install the gem:

	$ [sudo] gem install http-wiretap

And enable it within your application:

	require 'http/wiretap'
	HTTP::Wiretap.start()

And disable it when you're done:

	HTTP::Wiretap.stop()

Or clear out your log directory while running:

	HTTP::Wiretap.clear()

By default, all requests will be logged to `http-log` of your present working
directory. Also, your `http-log` directory will be cleared out each time you
run `start()`.


## MODES

HTTP Wiretap will log HTTP traffic in two modes:

1. Raw - Logs traffic in the order that it occurred.
2. Host - Groups traffic by host and path

When logging, data written will be linked with a symbolic link to save space and
reduce I/O.

The `http-log` directory is separated by mode and then each request is written
into a directory that contains a `request` file and a `response` file. Each of
these files contain the headers and body.


## EXAMPLE

If your application were to make the following requests:

	http://abc.com/login
	http://xyz.com/users
	http://xyz.com/users/1/favorites
	http://abc.com/fetch_info.pl?foo=bar
	http://abc.com/fetch_info.pl?foo=baz

Then your `http-log` directory will show the following:

	+ http-log/
	  + raw/
	    + 0/
	      + request
	      + response
	    + 1/
	      + request
	      + response
	    + 2/
	      + request
	      + response
	    + 3/
	      + request
	      + response
	  + host/
	    + abc.com/
	      + login/
	        + 0/
	          + request
	          + response
	      + fetch_info.pl/
	        + 0/
	          + request
	          + response
	        + 1/
	          + request
	          + response
	    + xyz.com/
	      + users/
	        + 0/
	          + request
	          + response
	        + 1/
	          + favorites/
	            + 0/
	              + request
	              + response

There can be overlap when making calls to a `/users` path and then a `/users/0`
path since requests are numbered. If anyone has a better idea of how to
structure this while keeping it simple, please let me know.


## CONTRIBUTE

If you'd like to contribute to HTTP Wiretap, start by forking the repository
on GitHub:

http://github.com/benbjohnson/http-wiretap

Please add test coverage to your code when submitting pull requests.