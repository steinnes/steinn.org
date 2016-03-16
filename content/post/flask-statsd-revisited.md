+++
Categories = []
Description = ""
Tags = []
date = "2016-03-15T21:28:49Z"
title = "Flask and StatsD revisited"

+++

A couple of months ago I wrote about automatically emitting <a href="http://steinn.org/post/flask-statsd/">
statsd metrics</a> for Flask views using a <a hre_f="http://werkzeug.pocoo.org/">Werkzeug</a>
middleware.

There was one rather large caveat though: how I dealt with dynamic URL
parameters.  Optimally I would have matched the incoming request against
the available URL rules or routes in Flask, and used the URL rule metadata
to generate a stable metric name.  To save time I relied upon the fact that
all dynamic URL parts in our API were at the time UUID's.

Since then I've found the time to update it and use the URL map. So here's
the updated gist:

{{% gist 32aad08050f642245dd1 %}}

I've also updated the original <a href="http://steinn.org/post/flask-statsd/">Flask and StatsD</a>
post itself, and the <a href="https://github.com/steinnes/statsdmiddleware">example
github repo</a>.

On a humorous note, let me tell you it definitely took me a few seconds to
realize why I was suddenly seeing `phpmyadmin.<...>` metrics in the <a href="https://www.datadoghq.com">Datadog</a>
metric explorer.  Then I remembered the technical debt incurred by my
initial approach.  It's now been a little while since we fixed it, and it
sure feels good to share the improved solution :-)
