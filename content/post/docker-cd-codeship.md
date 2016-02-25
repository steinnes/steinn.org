+++
Categories = []
Description = ""
Tags = ["docker", "codeship", "ci", "cd", "aws", "elasticbeanstalk"]
date = "2016-02-24T20:57:15Z"
title = "Continuous delivered Dockers via Codeship + Elastic Beanstalk"
draft = true

+++

At Takumi we've been using AWS Elastic Beanstalk for our different app
environments, for a variety of reasons.  Most importantly EB solves a lot
of problems straight out of the box, with minimal effort and a low learning
curve for most developers:

- Autoscale groups + ELB for scale and redundancy
- Deploy git commits and branches with easy CLI commands
- Easy to recreate and redeploy variations of environments

However we've run into our fair share of niggling little issues, some of
which we've already solved, some which we are in the process of solving and
finally some which we won't bother trying to solve.  The world is changing
fast and I believe we'll be running on top of some container scheduler,
maybe ECS, but more likely Kubernetes, before the end of the year.

In this blog post I'm going to describe how and why we decided to start
deploying pre-built dockers, which we build with Codeship and push to our
ECR repositories, and deploy using a tool built around generating `Dockerrun.aws.json`
files based on extremely simple templates.

# Why ?

Why deploy dockers, and why pre-build them?  In order to explain that I
need to explain how the historical Docker support in Elastic Beanstalk has
functioned.  We've been using it for a while for our web app, and it
basically works like this:

If you set your EB environment type to one of the Docker types, and a
`Dockerfile` is found in your project root, then upon deployment EB will
run something akin to:

{{< highlight bash >}}
$ docker build -t aws_beanstalk/staging-app .
$ docker run -d aws_beanstalk/staging-app
{{< /highlight >}}

In addition to this, EB will inspect the newly started docker and generate
an upstream configuration file for nginx, pointing to the local docker and
the port defined by it's `EXPOSE` line:

{{< highlight bash >}}
$ cat elasticbeanstalk-nginx-docker-upstream.conf
upstream docker {
	server 172.17.0.5:5000;
	keepalive 256;
}
{{< /highlight >}}

This of course negates one of the major benefits of using dockers: building
once, and running anywhere.  If you have more than one app server, each one
will perform the build steps by themselves, not only wasting resources by
doing identical work, but also introducing the possibility for temporal
build issues affecting some nodes but not others, resulting in an inconsistent
build running on "identical" nodes.

In my opinion one of the main reasons to use Docker in production is to
build once, run tests on the built artifact, and once deemed safe for deployment
that same tested "binary" is rolled out to the different app servers.  If your
backend is written in C++, Go or Java, you might find this pointless as you're
used to being able to statically link a large binary or release a fully self-
contained jar.  However in Python, Ruby, and NodeJS things aren't quite so
peachy.  Builds are slow, rely on remote and possibly fragile package repositories,
which always means builds are slow, and sometimes inconsistent!

In our case this pattern of building on each node meant that we were basically
overprovisioned rather dramatically to speed up deployments and replacement
nodes.  Elastic Beanstalk takes care of utilizing local package caches so
that subsequent builds get faster as long as there are no major changes in
environment or dependencies.  Even so we faced harrowing 30+ minute build times
when spinning up new nodes, and deploying reasonable changes could take several
minutes per machine, and did I mention we were overprovisioned?  Between
deployments our machines would be 90-99% idle, no joke!

# How ?

So in order to build once and deploy that same tested artifact, what do you
need?

1. Configure your CI system to build a docker image and run your tests inside
   the docker, and if you have external integration test scripts to run them
   against a running container instance of your image.
2. A docker registry or repository to store tagged versions of your images.
   We decided to use ECR (Elastic Container Registry) because since January
   16th they are natively supported by Elastic Beanstalk.  We tag all of our
   builds with the githash (accessible as `$CI_COMMIT_ID` from within codeship
   containers.
3. Only push and tag container images which pass tests, appropriately for
   deployment or use further in your pipeline. We chose not to push any failing
   containers to ECR.  That's easy using Codeship's `codeship-steps.yml`.
4. Finally you need a tool which allows you to reliably tell a particular
   app environment that it should now run the image that you want.  We custom
   built a little tool which uses `git`, `awsebcli` and `boto3` to deploy a
   container with a specific tag, to a specific environment.

If you want continuous delivery as well, as we do with our dev and staging
environments (we still pull the trigger manually for production, call me old
fashioned!) you need a way to allow Codeship, or a similar CI system to deploy
your code.  Since we had already setup our encrypted credentials with codeship
to allow them to pull and push from our AWS ECR repositories, we decided to
build a docker image with the tool from section *4* here above, and push that
to a `utilities` ECR repository which we could then use from Codeship.  Since
we re-used an IAM identity we setup for Codeship to deploy to Elastic Beanstalk
the old fashioned way, when we integrated with the ECR, re-using the same
credentials for our "deployment docker" was a walk in the park.
