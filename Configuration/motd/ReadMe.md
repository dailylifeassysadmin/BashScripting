<h1 align="center">MOTD (Message of the day)</h1>

## ReadMe file for MOTD (message of the day) configuration file.

This is a motd file which a user can put it into `/etc/motd.d` directory or `/etc/update-motd.d` directory in wsl machine.

## Introduction

When you log on to a Linux system, you're presented with a Message of the Day (MOTD). In early versions, this was a static message, read from a single file, but with recent releases of Ubuntu and other variations of Linux, it now contains dynamic information generated from a set of scripts. The idea behind the MOTD is to show SSH users pertinent information about the system and other policies that may govern usage of the system.

## Default MOTD

The default MOTD looks somewhat like this:

```
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-91-generic x86\_64)

&nbsp;\* Documentation:  https://help.ubuntu.com
&nbsp;\* Management:     https://landscape.canonical.com
&nbsp;\* Support:        https://ubuntu.com/advantage

&nbsp;System information disabled due to load higher than 1.0

23 updates can be applied immediately.
9 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/\*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
```

The information comes from various scripts located in  `/etc/update-modt.d/`  and the  `/etc/legal`  file. The scripts execute based on the first two digits of the name. 14 scripts make up the default MOTD. The  `motd-news`  service controls the data and its updates.

## MOTD News

The MOTD also imports news from a remote URL, controlled by  `/etc/default/motd-news`. To disable dynamic news, edit this file and change  `ENABLED=1`  to  `ENABLED=0`

## Disabling the MOTD Per User

To disable the MOTD on a per user basis, add a blank file to the home directory of the user. Name the file  `.hushlogin`. Create it by running:

```
touch $HOME/.hushlogin
```

and the MOTD stops showing when the specific user logs in.

## Removing Parts of the MOTD

To remove pieces of the MOTD, you can delete the corresponding script in  `/etc/update-motd.d/`  or set the execute bit to off by running  `chmod -x`  followed by the script name.

## Adding Your Own Custom MOTD

Adding your own message of the day is easy. Create a file in  `/etc/update-motd.d/`. The filename must be two digits followed by a hyphen and then a common name or reference for your script. Files should  \_not\_  contain an extension. The file can be any executable type your system is capable of running, usually defined by the she bang on the first line.

## Example Custom MOTD

To make the message of the day fun, add a Chuck Norris quote. The example uses PHP as the scripting language.

Add PHP scripting capabilities:

```
apt install -y php-cli
```

Disable all other MOTD scripts

```
chmod -x /etc/default/motd-news/*
```

Create a new script:

```
nano /etc/default/motd-news/05-chuck-norris
```

Add code to retrieve a quote from the public API containing Chuck Norris quotes:

```
#!/usr/bin/php
<?php

$handle = fopen("https://api.chucknorris.io/jokes/random", "rb");
$contents = stream_get_contents($handle);
fclose($handle);
$json = json_decode($contents);
print PHP_EOL;
print $json->value . PHP_EOL;
print PHP_EOL;
```

The script retrieves a random JSON payload, places it in to a JSON array and then prints a new line above and below the quote.

Ensure the script has the execute bit flipped:

```
chmod +x /etc/default/motd-news/05-chuck-norris
```

Log out and log back in and you should see a random Chuck Norris quote in your message of the day.

## Conclusion

The flexibility of dynamic message of the day provides lots of options. Enable or disable certain scripts to show load, users, package, required reboots, or even create your own custom scripts to display pertinent information or custom text related to your environment or system and user base.

## References

-   [Ubuntu update-motd man page](http://manpages.ubuntu.com/manpages/focal/man5/update-motd.5.html)

