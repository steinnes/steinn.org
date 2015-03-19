+++
Categories = []
Description = ""
Tags = []
date = "2015-03-19T01:11:52Z"
title = "redis workload recorder"

+++

Recently I've been working on some redis profiling and research, and since
we run several distinct redis instances at Plain Vanilla (due to reliability
and configuration reasons) the necessity to record a certain amount of commands
for several different redis instances became rather apparent.

<!--more-->

Rather than relying on my usual `redis-cli monitor > /some/file` inside a
screen, then remembering to `ctrl+c` after say 3600 seconds, I decided to 
script this for the benefit of my future self (and maybe others).

{{% gist ead90afa9882e89b995f %}}

Usage:
{{< highlight bash >}}
$ screen
$ ./redis-workload-record.py 3600 localhost > 3600-sec-redis-something.log
^A d
{{< /highlight >}}

This will start a screen where the workload recorder will run for 3600 seconds.
As can be seen from the code, the exit message will be printed to stderr so
your output can be safely redirected into a file, which then can be read and
replayed by something like this:

{{% gist 212f3273d17a7549ac46 %}}

By running something like this:
{{< highlight bash >}}
$ cat 3600-sec-redis-something.log | python redis-pipe-commands.py
{{< /highlight }}

Hope this benefits someone (other than my future self :-)
