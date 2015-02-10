+++
Categories = []
Description = ""
Tags = []
date = "2015-02-10T21:08:21Z"
title = "brute force still going strong"

+++

While setting up this blog I was looking through my little VMs scattered around
different cloud providers to find one which could serve as the A record for
`steinn.org` and redirect traffic to `steinnes.github.io`.  I logged on to one of my
<a href="https://www.digitalocean.com">digital ocean</a> droplets that I haven't used in
a while so I was slightly surprised to see more than 100k lines in `/var/log/auth.log`.

<script type="text/javascript" src="https://asciinema.org/a/16270.js" id="asciicast-16270" async></script>

I remember being a teenager and attempting to get access to random systems
I stumbled across on the internet.  I'm not going to lie, sometimes I'd get in
but the fear of being discovered was more than enough to prevent both any overt
attempts to connect, and to make sure if lucky enough to gain access, no damage
would be done.

I have the distinct feeling something has changed since the late 90's when I
was pretty much convinced that brute force attacks were just a stupid way to
get caught.

Here's a little `iptables` snippet if you're wondering how I made my `auth.log`
file stop growing:
{{< highlight bash >}}
iptables -F  # flush

iptables -A INPUT -p tcp -s your-ip/32 --destination-port 22 -j ACCEPT

iptables -A INPUT -p tcp -s 0.0.0.0/0 --destination-port 80 -j ACCEPT
iptables -A INPUT -p tcp -s 0.0.0.0/0 --destination-port 443 -j ACCEPT

iptables -A INPUT -j REJECT  # reject everything else
{{< /highlight >}}
