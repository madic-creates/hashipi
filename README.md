# hashipi

> Rasberry Pi rack running clustered Hashicorp datacenter infrastructure (nomad, vault, consul)

+ [Preamble](#preamble)
+ [Hardware Buildout](#hardware-buildout)
+ [Software Deployment](#software-deployment)

## Preamble
This project is heavily inspired by the [hashpi ansible scripts from timperrett](https://github.com/timperrett/hashpi). Special thanks to him! The hashipi project isn't just a copy of his project but heavily extends it.

In order to follow along with this build, you would need to have the following components available. Because I'm from germany, I link to the german amazon website. In this repo I will not explain on how to use the software from hashicorp. I've written about this on my german blog post.

### Hardware Shopping List

+ 4x [Raspberry Pi 3 Model B](https://www.amazon.de/gp/product/B01CD5VC92/)
+ 4x [16GB SDHC cards](https://www.amazon.de/gp/product/B01EAKB0YK/)
+ 1x [Anker 5-Port powered USB recharger](https://www.amazon.de/gp/product/B00VUGOSWY/)
+ 4x [Askbork USB-B to USB-micro cable](https://www.amazon.de/gp/product/B01D8AWFVK/)
+ 1x [Stackable Raspberry Pi Case](https://www.amazon.de/gp/product/B00NB1WPEE/)
+ 3x [Intermediate plate for the stackable case](https://www.amazon.de/gp/product/B00NB1WQZW/)
+ 1x [W-Linx 10/100 5 Port Switch (USB Powered)](https://www.amazon.de/gp/product/B010FWLEJI/)
+ 4x small Cat5e cable (e.g. 0.25m or 0.5m). I buy mine from [kab24.de](https://www.kab24.de/netzwerk/kab24-cat6-patchkabel-netzwerkkabel-weiss-sftp-pimf-geschirmt-gigabit.html)


## Hardware Buildout
![stage 1](/img/build01.jpg)

+ Assemble the motherboards with the case (instructions from the case)

![stage 2](/img/build02.jpg)

+ Connect the USB power cords and the network cables to the motherboards

![stage 3](/img/build03.jpg)

## Software Deployment

These instructions assume you are running *Raspbian Lite Stretch* (Jessie not tested). The roles included require systemd. You can download [Raspbian Lite from here](https://www.raspberrypi.org/downloads/raspbian/).
On Windows you can use [Win32DiskImager](https://sourceforge.net/projects/win32diskimager/) to copy the image to the sd card.
For Mac I've heard [etcher from resin.io](https://etcher.io/) should be great for copying images to the sd card.

For the rest of the guide I assume a working ansible connection from your client to the pis.

#### Debug Playbook

The debug playbook only outputs the default ipv4 / ipv6 addresses from the hosts in the inventory.ini. But it's easy to expand on this if required.

#### Site Playbook

The site playbook will do the following thinks:

+ bootstrap the pis (disables avahi-daemon and bluetooth)
+ install [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) on every pi
+ install [consul](https://www.consul.io/) on 3 nodes for the quorum
+ install [nomad](https://www.nomadproject.io/) on the pi in the master group as the server and on every other pi as client
+ install [vault](https://www.vaultproject.io/) only on the pi in the master group; uses consul as secure backend
+ install [docker](https://docker.com/) only on the pis which are also nomad clients
+ install [hashiui](https://github.com/jippi/hashi-ui) NOT on the pis, requires a cpu with x86 architecture! Therefore the group hashiui

Most of the setup is automatic, except for the vault initialisation. During initialisation vault generates 5 per installation unique keys. The keys are required to unlock vault after e.g. a reboot to unlock it again. The steps for the first setup are documented in this [blog post](https://www.vaultproject.io/intro/getting-started/deploy.html). In short:
```
$ ssh <master>
$ export VAULT_ADDR="http://$(ip -4 route get 8.8.8.8 | awk '{print $7}' | xargs echo -n):8200"
$ vault operator init
```
Be sure to keep the generated keys in a safe place, and absolutely do not check them in anywhere!

To unlock vault after a restart:
```
$ vault operator unseal -tls-skip-verify
```
Due to the nature of this project, beeing a test environment, I'm not really testing ssl for the moment. Priority lies on functionality. For production use you absolutly need to use ssl! This components are too important to risk anything.

## Testing
On the master you can find some nomad example files under /var/lib/nomad/examples.

To run them:
```
nomad run /var/lib/nomad/examples/nginx.nomad
nomad run /var/lib/nomad/examples/redis.nomad
nomad run /var/lib/nomad/examples/fabio.nomad
```
This will start 4 nginx and 1 redis docker container and 3 fabio load balancer instances without docker.
Check the result with hashiui:3000. In the logs of fabio, visible in hashiui, you can see that it will pick up all in consul registered nginx servers and serve them through port :9999.
You can also check the ressource allocation and how much the instances use.