+++
Categories = []
Description = ""
Tags = ["redis"]
date = "2015-05-10T15:15:28Z"
title = "redis keysampling"
draft = true

+++

One of the most used datastores we have at QuizUp is <a href="http://www.redis.io">Redis</a>.
Redis is a very versatile in-memory key-value store which offers in our
opinion a very decent cross section of features, performance and reliability.
Reliability in Redis, from our perspective, is achieved by having a slave
instance for each master, which we setup to periodically dump it's dataset
onto disk.  These dumps we then backup to S3.  When it comes to scaling, we
have so far not resorted to any particularly dynamic solutions such as
twemproxy + hashing of keys, or the newly released <a href="http://redis.io/topics/cluster-spec">Redis Cluster</a> features.

In the beginning most QuizUp related data was stored in either of two Redis
instances, one for data which was considered persistent and one for data which
was considered volatile.  Persistent data is defined as data which if missing
from Redis would cause severe runtime issues in the game, while volatile data
is such that the app does not make hard availability expectations, for example
cached data which the application knows how to re-generate.

After the launch of the game the amount of data in especially the "volatile"
Redis instance grew very rapidly, and a few days after launch when running into
memory pressure the issues of running a large number of features on shared
datastores became apparent.

The main issue encountered was that we had no cheap and easy way to get an
overview of the keyspace, to determine which subsystems of QuizUp were
responsible for the greater portions of the datastore usage, or the workload
coming in.  This "volatile" instance was mainly used by three separate subsystems
for ephemeral or non-critical data: *games*, *notifications* and *cache*. Although
we had a decent hunch which ones were the largest, we could not determine the
following metrics down to subystem:

- commands / sec
- % of keys in the keyspace
- % of memory in the keyspace

In part due to this lack of visibility, we decided not to approach the problem
by scaling the system out via twemproxy or the at-the-time unstable Redis-cluster.
Instead we decided to increase the size of our main volatile redis instance
(scale vertically, not a sexy solution!) and to start migrating different subsystems
to their own respective Redis instances.  Also this had the effect that any new
features or refactored features which required Redis would always get their own
redis instance(s) to avoid a repeat of the "volatile problem".

Later we started analysing the workloads and wondering how we might simplify
our infrastructure by not only combining the systems we split up from Redis
"volatile", but perhaps also some of the new systems.  Combining their data in
a single cluster 
