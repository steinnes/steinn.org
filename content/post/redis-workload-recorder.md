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
