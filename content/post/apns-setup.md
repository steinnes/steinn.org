+++
Categories = []
Description = ""
Tags = []
date = "2015-08-06T00:37:37Z"
title = "Setting up APNS for iOS"
draft = true

+++

This week we started setting up push notifications on the iOS app we are building
at work.  I knew from my work at QuizUp that this was slightly more complicated
than you'd think, but even I was stumped at the complexity Apple front-loads on
people developing for their platforms.

I read a couple of guides which were either slightly too vague, or really
detailed but contained directions for outdated versions of one of the many
graphical user interfaces Apple seems to think developers enjoy (hint: most
of us don't!).  First I attempted what I usually do: to understand what I am
doing before committing to any potentially confusing changes.  After spending
some with this layercake of cryptographic overengineering I abandoned hope of
abstract understanding and decided to learn by doing.

Thirty hours later I was left with a whole bunch of useless keys,
certificates, provisioning profiles, app ID's and various unspeakable things
done to my local keychain and our iOS "Certificates, Identifiers & Profiles"
in the Apple Developer Center, I ended up with these steps here.

I was helped *a lot* by this excellent guide <a href="http://www.raywenderlich.com/32960/apple-push-notification-services-in-ios-6-tutorial-part-1">here</a>,
by Ray Wenderlich.  I reworked his steps just a little and after figuring
out what was being done with the Keychain Access "Certificate Assistant",
decided to share with the world how to create a key and csr with openssl
on the command line.  Not being able to script or copy-paste this kind of
stuff must be a violation of developer rights, or something.

So without further ado, here are the steps I followed:

1. In your terminal of choice, Generate private key
    <pre>
    openssl genrsa -out com.example.app.key 2048
    </pre>


2. In that same terminal, create a CSR (Certificate Signing Request)
    <pre>
    openssl req -new -key com.example.app.key -out com.example.app.csr -subj "/emailAddress=you@example.com/CN=com.example.app/C=IS/O=Example Ltd"
    </pre>
   I recommend keeping these two files somewhere safe, you'll need them in step 5.

3. Log into the Apple Developer console. Go to "Certificates, Identifiers & Profiles",
   and create a new App ID, I'll use `com.example.app` for this guide.

4. Again in the Apple Developer console, Click "Edit" under "Application Services", and scroll down to "Push Notifications", click there "Create Certificate".
   Use the CSR created earlier (`com.example.app.csr`) to create the certificate, download it, it will have a filename like "aps_development.cer".

5. Convert the .cer file into a PEM file:
   openssl x509 -in aps_development.cer -inform der -out com.example.app.aps_developement.pem

6. Test your key and certificate against APNS:
    <pre>
    openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert com.example.app.aps_developement.pem -key com.example.app.key
    </pre>
   If everything is OK, you should see a "CONNECTED.." string, followed by a succesful SSL handshake.  You can stop by sending EOF (^D).

7. Combine the private key and the aps_development certificate into a single PEM file:
    <pre>
    cat com.example.app.key com.example.app.aps_developement.pem >> apns_com.example.app_combined.pem
    </pre>
   You will use this file later when sending notifications.

8. Go into the Apple Developer Console, open "Provisioning Profiles" click the "+" icon.  There choose "iOS Development", then click continue.
   There choose the App ID created earlier (com.example.app). Click continue.  Then choose the developer certificates, and then the devices, finally click "generate".
   Choose a name for it, then download!

9. Once you've downloaded your profile (should have a .mobileprovision suffix) drag it into XCode, or open it in XCode somehow.

