+++
Categories = []
Description = ""
Tags = []
date = "2015-03-01T16:28:22Z"
title = "Changing redis maxmemory gradually"

+++

Today we've been busy migrating some AWS instances at work due to upcoming
maintenance events in AWS.  One of the instance families we used a lot when
building QuizUp is the m2 instance family and almost all of our m2 instances
will require restarts in the next few days.

On some of these we are running large redis instances with tens of GB of data
and restarting them is not pain-free, even if we would use the persistence
features of redis, which work by periodically dumping the entire dataset into
a `dump.rdb` file.  If the keyspace is tens of GB, the process of saving, and
reading the data is quite slow. Even with a disk subsystem capable of 100MB/s
sustained reads and writes, saving and reading will take around 500 seconds each.

In the mean time you probably do not want to serve requests.  While saving
because you'll write changes that won't be reflected in the `dump.rdb` file, so
you lose data on restart, and while reading the data redis does not allow writes
(at least by default) and even serving reads can be dangerous if your application
makes assumptions based on the availability of keys.

In order to deal nicely with this scenario we basically slave our redis instances
with newer instance types and then mostly seamlessly failover to them (I can
write another blog post on that later).  Slaving however is not problem-free.

Until redis 2.8.18 the only way to slave is for the master to start by making a
`dump.rdb` file, which when complete gets streamed to the slave, which saves it
to disk, then reads it up from disk, and all writes/changes happening on the
master are buffered in the mean-time.  This causes a series of problems (more:
<a href="http://java.dzone.com/articles/top-redis-headaches-devops">Top Redis Headaches for DevOps: Replication Buffer</a>)
which I won't expand on here, but let's suffice to say that the smaller the dataset
is, the easier time you will have making a slave of it.

If your dataset is mostly volatile, meaning that it's nice to have the data there
but not crucial, lowering the maxmemory down to force redis to evict keys is a
sound strategy to improve your life as a slavemaster.  Today I took a crappy script
I had which does just that and packaged it a little more nicely and it's on GitHub:
<a href="http://github.com/steinnes/redis-memslider">steinnes/redis-memslider</a>.
