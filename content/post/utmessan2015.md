+++
date = "2015-02-10T11:44:14Z"
title = "From Monolith to Services @ QuizUp"
type = "post"

+++

Last week I had a talk at a local IT conference, <a
href="https://www.utmessan.is">UT Messan</a>.  The title of my talk was the
rather inflated "From Monolith to Services at Scale: How QuizUp is making the
(inevitable?) transition, one endpoint at a time".

In the talk I try to tell the story of how we at QuizUp are transitioning to
a more service-oriented architecture, and which steps we decided to take first.

The route we chose was to setup ZooKeeper as the heart of our system for
service registration, discovery and configuration, and then figure out how to
route client requests to services running inside Docker containers.  The
building blocks we ended up using were basically ZooKeeper, NGiNX, Docker, our
own Docker registries (which we refer to as "dockistries"), as well as a few
custom components which I outline in the talk.

{{% youtube GhgH_8-HCVQ %}}

Here are just slightly updated slides, I didn't manage to get them to the
conference technician in time on Friday, but I put the tweaked version on
Speakerdeck.
{{% speakerdeck a36212c2dcc8418290d98ec6b9c0c8a1 %}}

I would have liked to tell a bit more of a story, as we did create a couple
of services in the spring of 2014 which we always had issues deploying, and
we realized that without standardized containers, a service registry and why
not a dynamic router as well -- we'd probably just confuse ourselves into
unexpected outages.  However my timeslot for this talk was only 30 minutes
so I condensed this into 20-25 + questions.
