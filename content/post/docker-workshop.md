+++
Categories = []
Description = ""
Tags = []
date = "2015-02-14T17:12:57Z"
title = "Docker Workshop"

+++

These are the instructions/background I wrote for a workshop on Docker
when we started deploying the backend services for
<a href="http://www.quizup.com">QuizUp</a> as Dockers, in November 2014.

What is Docker?
---------------

It is a server and client for creating lightweight machine images, known
as containers.  Currently these images can be run on Linux, in what are
known as LinuX Containers (LXC).  Docker uses AUFS (a union file system)
and some clever magic to save time when creating new images.  

How does it do this?
--------------------

On an LXC-capable host, you can run the "docker" daemon which allows any
docker client to create new images, and start them.  The images are created
using recipe files called "Dockerfiles", which look something like this:

{{< highlight docker >}}
    FROM debian
    ENV DEBIAN_FRONTEND noninteractive
    RUN apt-get update && apt-get install -y openssh-server
    ADD authorized_keys /root/.ssh/authorized_keys
    CMD mkdir -p /var/run/sshd && exec /usr/sbin/sshd -D
{{< /highlight >}}

If situated in a folder with a file called `Dockerfile` with the contents
from above, we can build an image based on it using the docker command line
client:

{{< highlight bash >}}
    $ docker build -t steinn/ssh-docker-1 .
    Sending build context to Docker daemon  2.56 kB
    Sending build context to Docker daemon
    Step 0 : FROM debian
     ---> 61f7f4f722fb
    Step 1 : ENV DEBIAN_FRONTEND noninteractive
     ---> Running in 18c5aa0fa614
     ---> f7fb51a8a0ec
    Removing intermediate container 18c5aa0fa614
    Step 2 : RUN apt-get update && apt-get install -y openssh-server
     ---> Running in efcaf53c9380
    Get:1 http://http.debian.net wheezy Release.gpg [1655 B]
    .... VERY LONG PRINTOUT SUPPRESSED ....
     ---> 6172db1d263d
    Removing intermediate container efcaf53c9380
    Step 3 : CMD mkdir -p /var/run/sshd && exec /usr/sbin/sshd -D
     ---> Running in 446fb44be23e
     ---> 914c4e3e928b
    Removing intermediate container 446fb44be23e
    Successfully built 914c4e3e928b
{{< /highlight >}}

Note the ` --->` commands in between "Steps".  They are indicating when
Docker is creating a new file system layer, so in effect an image, and stores
it after every step.  This makes it extremely fast to re-run docker builds
unless the build steps change.  Here is the output from the same command as
above, run again, and with `time` in front:

{{< highlight bash >}}
    $ time docker build -t steinn/ssh-docker-1 .
    Sending build context to Docker daemon  2.56 kB
    Sending build context to Docker daemon
    Step 0 : FROM debian
     ---> 61f7f4f722fb
    Step 1 : ENV DEBIAN_FRONTEND noninteractive
     ---> Using cache
     ---> f7fb51a8a0ec
    Step 2 : RUN apt-get update && apt-get install -y openssh-server
     ---> Using cache
     ---> 6172db1d263d
    Step 3 : CMD mkdir -p /var/run/sshd && exec /usr/sbin/sshd -D
     ---> Using cache
     ---> 914c4e3e928b
    Successfully built 914c4e3e928b

    real        0m0.236s
    user        0m0.007s
    sys 0m0.008s
{{< /highlight >}}


Let's analyse these messages a bit.  The first one says "Sending build
context to Docker daemon  2.56 kB".  What's happening here?  Basically
your docker client is making a tarball of the directory containing your
Dockerfile and all subdirectories, and posting them along with some
metadata to port 2375 of it's Docker host.  The Docker host defaults on
every machine to unix:///var/run/docker.sock, but can be set via the
DOCKER_HOST environment variable to another machine, such as:

{{< highlight bash >}}
    $ export DOCKER_HOST=tcp://192.168.22.8:2375
{{< /highlight >}}

A common approach on OS X machines is to use a set of scripts called
"boot2docker" which basically give you a very simple interface for
downloading and running a bare-bones linux image with a docker daemon
via virtualbox.  It will even tell you which environment variables to
export.  See:

{{< highlight bash >}}
    $ boot2docker up
    Waiting for VM and Docker daemon to start...
    .o
    Started.
    Writing /Users/ses/.boot2docker/certs/boot2docker-vm/ca.pem
    Writing /Users/ses/.boot2docker/certs/boot2docker-vm/cert.pem
    Writing /Users/ses/.boot2docker/certs/boot2docker-vm/key.pem

    To connect the Docker client to the Docker daemon, please set:
        export DOCKER_HOST=tcp://192.168.59.103:2376
        export DOCKER_CERT_PATH=/Users/ses/.boot2docker/certs/boot2docker-vm
        export DOCKER_TLS_VERIFY=1
{{< /highlight >}}


Exercise
========

Now that you've played around with docker a bit. It is time for an exercise.

A few weeks ago we did a little "testing kata" which was a Python Flask http
web service for making basic calculations.  Since that is a common problem
(ie. creating and dockerizing a little web service) I decided to base todays
exercise on that.

1. Go to https://github.com/plain-vanilla-games/flask-test-kata
   Clone the repo and checkout the "solution" branch or use your own older solution
2. Create a build folder, within which you write a Dockerfile for this service
3. Write a Makefile which builds and tags the docker, and is able to push it to
   a Docker registry
4. Update the Makefile of your project to run the unit and integration tests
   Inside the Docker you just created.

Solution: 
https://github.com/plain-vanilla-games/flask-test-kata/compare/solution...docker

When completing this exercise you will likely run into a couple of issues with
the approach of having the `Dockerfile` in a separate (`build`) folder.  I solve
those issues by using a Makefile -- which in it's most simple form could start
by copying the necessary files from `../` and rm-ing them afterwards.

Since at Plain Vanilla we always tag containers with the githash (commit) of the
code they contain, I decided to hit two birds with one stone, using either the
tip of the current branch or the githash given by the `GITHASH` make parameter and
`git archive` to deliver the code.

Additionally, as new timestamps on `ADD`-ed files will break the Docker cache I
am extracting the timestamp for the tip of the branch and setting the modification
date for some of the files to that.  Additionally I add requirements.txt manually
so that the `RUN pip install -r requirements.txt` step can benefit from the Docker
cache.

Your first, most basic version of the Makefile could be simpler -- and mine is not
without flaws, but I decided to employ some of the slightly more advanced methods
we use in order to expose some of the trickier parts of using Docker in production.
