+++
Categories = []
Description = ""
Tags = []
date = "2015-03-09T16:03:03Z"
title = "Reinventing the wheel"

+++

We all tend to reinvent the wheel once in a while, and often it's just
a question of not having found the right tool with a quick search, or
better: we prefer doing something differently and/or we enjoy the process
of building something just for the heck of it.  This is a small story of
me being slightly stupid, but also about UDP and how awesome it is :-)

<!--more-->

I'm fond of UDP.  The user datagram protocol.  Unlike it's cousin TCP,
UDP packets do not contain a sequence number and the protocol does not
ack packets.  For practical purposes this means it gets used in scenarios
where latency is more important than reliability: you prefer to lose some
packets, rather than adding any overhead of acknowledging packets or waiting
for packets if they arrive out-of-sequence or get lost on the way.

When streaming audio or video it's usually better to drop packets (and thus
frames) than to stall a live stream or conversation while syncing up so
streaming applications often use UDP, and it is also commonly used as the
underlying network protocol in FPS games (Quake 3, and probably the other
Quake games spring to mind).

A major reason for my current love of UDP is because of it's use in StatsD,
a wonderful protocol developed (afaik) at <a href="https://codeascraft.com/2011/02/15/measure-anything-measure-everything/">Etsy</a>
to measure "anything and everything" in their app.  I came to know StatsD
when I started working for <a href="http://www.plainvanilla.is">Plain Vanilla</a>
who were already using it for monitoring the first single-topic QuizUp
games.  To make a long story short the fire-and-forget approach to massive
amounts of statistical data made my heart stir.

A job for UDP!
--------------

For the last few weeks I've been working on ways to profile and optimize
<a href="http://redis.io">redis</a> for caching purposes.  The research is
far from conclusive results, but one of the things we needed to do was find
an unobtrusive way to monitor key touches in redis.

What we decided to do was to patch it to add a "key sampling" mechanism which
fires UDP packets containing a key when it gets touched.  This allows us to
reather cheaply allow an external program to receive a sampling of key touches
with a minimal performance hit or overhead in redis itself.

To read this data and pipe it into different analyzers, I hacked up a little
program which listens on an UDP socket and writes anything it receives to
stdout.  Here's a gist of that program:

{{% gist e017ea610a2ee2872e3a %}}

I named the gist "pointless udp dumper"... so why pointless?

Well because as a close friend pointed out I could have used `netcat`.
My ego was slightly stroked by the fact that he said "Ah, I guess you want
to do something more complex later, which is why you don't just use netcat..".

But the answer was: No, I just keep forgetting that netcat supports UDP,
and these eight bytes (excl. the port!) will do the same as my pointless udp
dumper, on any machine with netcat installed:

{{< highlight bash >}}
$ nc -l -u 12345
{{< /highlight >}}

It can be fun to re-invent the wheel, but I must admit that I prefer to do
it consciously :-)
