+++
Categories = []
Description = ""
Tags = ["aws", "elasticbeanstalk", "tools", "pip"]
date = "2016-02-24T23:30:28Z"
title = "ebenv: Elastic Beanstalk environment copy/dump tool"

+++

At Takumi we use Elastic Beanstalk, which is a nice API/service from AWS
which strikes a decent balance between a heroku-esque simplified service
interface for developers, and the hands-on control required by those of
the devops persuasion, such as myself.

One of the main benefits of using Elastic Beanstalk is how quick and easy
it is to spin up new environments, and I make heavy use of that in my work.
Basically what I find relatively often useful is the ability to copying an
existing environment to test new code with the same configuration and
resources, with a limited set of clients.  Reasons to do that might be;

- Rolling out new features to a limited set of clients
- Making a new environment for a new developer who wants to test something
  with minimal risk of disruption
- Making new development environments with "production-esque" configuration
  as needed, and as the app needs evolve
- Keeping a separate environment which gets 5% of traffic via weighted DNS
  (canary-ing)

Basically it's a logical conclusion that once you treat your infrastructure
as programmable outputs which can be recreated and discarded at will, that
your development patterns and needs evolve to take advantage of that.

One thing though that slightly bugged me when dealing with Elastic Beanstalk
was the fact that there was no programmatic way of doing the following:

1. Dump the environment variables for an app env to an envfile, usable by
   `foreman`, `honcho` or similar tools
2. Same as *1* but an envdir, usable by `envdir`, `chpst` or similar tools
3. Copy the environment variables (config) from one environment to another
4. Load the environment variables in an envfile or an envdir into an
   existing EB environment

Recently I was doing a lot of work and needed to replace some of our existing
environments because we're migrating everything from language specific EB
environments to the Docker environments, so I basically needed to create new
EB environments for existing ones, but I couldn't just clone them because
the platform gets cloned as well and you can't change the platform, only the
version:

{{< figure src="http://static.steinn.org/blog/post/change-platform.png" title="\"changing\" a platform version :-)" >}}

Doing this I sorely missed the ability to copy the environment configuration
because I was essentially making clones of existing environments without
being able to actually *clone* the environments.

Another semi-common issue I encountered was dumping values from an existing
environment, in order to start a server locally or on another instance using
the same configuration.  Intermittently over the last few months I'd been
missing a tool to deal with EB environments programmatically, partially
because we have a decent amount of configuration values which don't play nice
with <a href="https://github.com/gxela/awsebcli">awsebcli</a>, and these
forementioned issues were popping up once in a while.

I decided to finally do something about it and I wrote <a href="https://github.com/steinnes/ebenv">ebenv</a>.

Currently it can handle issues 1-3 here above, and I'm planning to add
counterpart commands to the `env` and `envdir` commands to easily sync
local changes (which might even be maintained in a *gasp* repository!)
with a remote Elastic Beanstalk environment.
