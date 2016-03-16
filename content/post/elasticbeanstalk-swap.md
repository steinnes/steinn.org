+++
Categories = []
Description = ""
Tags = []
date = "2016-03-14T09:02:25Z"
title = "Adding swap to Elastic Beanstalk"

+++

If you're using small t2 instances on Elastic Beanstalk which only have 1GB or
less of memory, you may run out of memory while doing rare, yet memory intensive
tasks such as deploying (and/or building) your app.

If your app does not require a lot of memory except during those rare moments,
increasing your instance size and being overprovisioned 99% of the time is not a
solution which should satisfy a good engineer.

A better solution would be to add swap space to the machine, which on Linux is
something you can easily do at runtime, even though most distributions will
guide you towards setting up a separate swap partition.  A swapfile can be
created with these three simple commands:

{{< highlight bash >}}
# dd if=/dev/zero of=/var/swapfile bs=1M count=1024   # create a 1GB file of 0's
# mkswap /var/swapfile
# swapon /var/swapfile
{{< /highlight >}}

The simplest way I know to do this with Elastic Beanstalk is to use <a href="http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/ebextensions.html">
.ebextensions</a>.  Simply create a folder in your elastic beanstalk deployable
project named `.ebextensions`, and within it add two files, the first a more
elaborate version of the three commands above, something akin to this script,
and call it `setup_swap.sh`:

{{% gist 3a1de7250de10687ade1 %}}

Then add a `.config` file which tells EB to run the setup script on deployment.
The script checks if a swapfile already exists, and if so exits peacefully.

{{% gist 1f8a1b44fed4b136005f %}}

Once done your project directory tree should look partially like this:

{{< highlight bash >}}
project
├── .ebextensions
│   ├── 01_setup_swap.config
│   └── setup_swap.sh
...
{{< /highlight >}}

If you inspect your `/var/log/eb-activity.log` you should see something like this:
{{< highlight bash >}}
[2016-03-15T03:43:31.452Z] INFO  [8044]  - [Application update/AppDeployStage0/EbExtensionPostBuild] : Starting activity...
[2016-03-15T03:43:31.722Z] INFO  [8044]  - [Application update/AppDeployStage0/EbExtensionPostBuild/Infra-EmbeddedPostBuild] : Starting activity...
[2016-03-15T03:43:31.723Z] INFO  [8044]  - [Application update/AppDeployStage0/EbExtensionPostBuild/Infra-EmbeddedPostBuild/postbuild_0_project] : Starting activity...
[2016-03-15T03:43:31.943Z] INFO  [8044]  - [Application update/AppDeployStage0/EbExtensionPostBuild/Infra-EmbeddedPostBuild/postbuild_0_project/Command 01setup_swap] : Starting activity...
[2016-03-15T03:44:24.967Z] INFO  [8044]  - [Application update/AppDeployStage0/EbExtensionPostBuild/Infra-EmbeddedPostBuild/postbuild_0_project/Command 01setup_swap] : Completed activity. Result:
  2048+0 records in
  2048+0 records out
  2147483648 bytes (2.1 GB) copied, 51.3331 s, 41.8 MB/s
  Setting up swapspace version 1, size = 2097148 KiB
  no label, UUID=b4c8a86f-e34d-43f2-8bc0-21c97aa5223e

[2016-03-15T03:44:24.967Z] INFO  [8044]  - [Application update/AppDeployStage0/EbExtensionPostBuild/Infra-EmbeddedPostBuild/postbuild_0_project] : Completed activity.
{{< /highlight >}}

And finally you should see your new swap space:
{{< highlight bash >}}
[ec2-user@ip-172-31-40-245 var]$ free
             total       used       free     shared    buffers     cached
Mem:       1019452    1005548      13904       2308        248      43104
-/+ buffers/cache:     962196      57256
Swap:      2097148      18868    2078280
{{< /highlight >}}
