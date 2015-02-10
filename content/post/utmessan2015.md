+++
date = "2015-02-10T11:44:14Z"
title = "From Monolith to Services @ QuizUp"
type = "post"

+++

Last week I did a talk at a local IT conference, <a href="https://www.utmessan.is">UT Messan</a>.
The title was the rather inflated "*From Monolith to Services at Scale: How
QuizUp is making the (inevitable?) transition, one endpoint at a time*".

In it I try to tell the story of how we at QuizUp are transitioning to a more
service-oriented architecture, and which steps we decided to take first.

The route we chose was to use ZooKeeper as the heart of our system for
service registration, discovery and configuration, and then figure out how to
route client requests to services running inside Docker containers.  The
building blocks we ended up using were basically ZooKeeper, NGiNX, Docker, our
own Docker registries (which we refer to as "dockistries"), as well as a few
custom components which are outlined in the talk:


## video

{{% youtube GhgH_8-HCVQ %}}


## slides

{{% speakerdeck a36212c2dcc8418290d98ec6b9c0c8a1 %}}
<small>*The slides here above are slightly updated from the ones I used during my talk.</small>

I would have liked to tell a bit more of a story, as we did create a couple
of services in the spring of 2014 which we always had issues deploying. After
some pondering we realized that without some kind of deployable packages (we
rolled our own, and also looked at using .deb), or standardized containers,
a service registry we would probably end up with a lot of confusion (and
unexpected outages).  We decided on ZooKeeper, Docker and since we're doing
that why not a dynamic router as well.

Since the timeslot was only 30 minutes so I condensed this into 20-25 minutes
+ questions.
