+++
Categories = []
Description = "A flask/werkzeug view middleware to emit statsd metrics."
Tags = []
date = "2015-11-30T09:58:33Z"
title = "Flask and StatsD"
draft = true

+++

I've written about <a href="/post/reinventing-the-wheel">StatsD</a> <a href="/post/datadog">before</a>,
but it's time to pick up the pen again, at least in the proverbial sense (I'm
typing this on a laptop-chiclet keyboard).

A few months ago I joined a new company: <a href="http://takumi.com">Takumi</a>
and we're building an iOS app married to a Python Flask-based backend. From
many perspectives, a very similar tech stack as we used at QuizUp.  And it's no
coincidence.  One of the founders of Takumi is <a href="http://twitter.com/jokull">Jökull Sólberg</a>,
who I worked closely with at QuizUp and as far as I know had a major effect on
the initial technology stack used there.

Having used this technology to build a product which got a million active users
in little over a week, I think it's a fair assumption that we are comfortable
with the problems and solutions presented on the backend by this choice of tech.
But it's always possible to tweak, and that's what this blog post is about.

At QuizUp, one of the lessons I learned, and I've openly <a href="https://speakerdeck.com/steinnes/quizup-zero-to-a-million-users-in-8-days?slide=16">spoken of</a>
is the importance of metrics and instrumenting code, specifically using StatsD
and <a href="http://www.datadog.com">Datadog</a> is my preferred service for
making those metrics visible and reacting to them.  The way we did this there
was mainly in two ways:

1. A fairly ingenious view decorator which took the metric name as a paremeter,
wrapped a Flask view and and emitted a statsd timing for the view.  Instant
visibility into your view latencies!  I credit <a href="https://twitter.com/johannth">Jói</a>,
the CTO of QuizUp for this.  He's an amazing developer and generally one of the
nicest human beings you'll ever meet.

2. For those views which did a lot of things, we wrote a little context manager
which could do the same as the view decorator, but for any code block.  This
piece of code was born as our "home" endpoint (a big-fat-gimme-everything for
the client home screen) started becoming slower and slower.  We needed some
way of monitoring which parts of the response were taking the longest to retrieve
or generate.

As I mentioned before, now I'm with another company and doing similar things, and
as I'm wont to do, I try and improve/iterate on what I'm doing.  At Takumi I
started implementing a similar view decorator, meaning some potentially repetitive
code like this everywhere:

{{% gist 507d894df8f445172c8b %}}

Basically adding a `view_metric` decorator around every view with a metric
name which should be easily derivable from the view name or request path.  First
I thought "Ah, the metric name should be derived from the request endpoint name!",
but replacing `@view_metric("...")` with `@view_metric` for over a hundred
different views still is quite repetitive.

Thinking back I remembered having used Werkzeug's <a href="http://werkzeug.pocoo.org/docs/0.10/contrib/profiler/">ProfilingMiddleware</a>
back when performance tuning QuizUp, so I thought I'd explore writing my own
StatsD MiddleWare for Flask.:

{{% gist 32aad08050f642245dd1 %}}

This code assumes a couple of things, first that the app name is `takumi`.  This
could easily be changed by supplying the actual Flask app instead of the wsgi_app,
to the middleware constructor, and then relying on `self.app.name`.  Also it might
be a good idea to use that prefix for all metrics, to be able to use this middleware
for multiple Flask apps all sending metrics to the same statsd service (such as Datadog).

The second assumption is that the only dynamic parts of a URL are UUIDs.  Look at
`def _metric_name_from_path` for details, but there I basically use a regular expression
to replace any UUID's in the URL string with `id`.  Probably a more robust approach
would be to parse the request path and construct it out of safe characters found
between slashes.  I'll fix these things once I make an actual flask module out of this.

The code above includes a couple of little extras:

- `StatsD`: a statsd wrapper I wrote to automatically add certain tags to all metrics
emitted.  That's something I've done before, and not really related to Flask or Werkzeug,
but we are using this at Takumi so I decided to include it.
- `get_cpu_time`: the middleware and the context manager both always retrieve the actual
cpu time and submit that as a separate metric.  This is a neat little trick I suppose most
devops people will be used to, and is a great indicator of both wasted cpu cycles and external
bottlenecks.


The way you'd use the code above would be like so:

{{% gist ebe4b170a46b3b74d7da %}}

We launched Takumi on the 11th of November and we're using this code in production,
and alhtough I have a nagging suspicion I'll discover some unpaid price for this magic,
we are seeing metrics for all of our views completely automatically :-)
