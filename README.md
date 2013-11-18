rails-sound-spy
===============

Fully-featured web application for use on a server taking in audio input and providing analytics. We have this running on a raspberry (s)pi, running raspian, hooked up to a mic on our ping pong table in the break room. YMMV on the amount of customization required here.


## Getting Started


### Prerequisites
You'll need a few things before you can get going with this.

#### Required

Some server (We used a [Raspberry Pi](http://www.raspberrypi.org/) with [Raspian](http://www.raspbian.org/) installed)

A microphone and USB sound card (Raspberry Pis don't have an onboard one)

A ping pong table

[Ruby on Rails](http://elinux.org/RPi_Ruby_on_Rails)

[FFTW3](http://www.fftw.org)
```bash
$ sudo aptitude install fftw3-dev
```

A clone of this repo (you should probably fork it so you can easily make changes. Feel free to submit your changes back to us!)


#### Optional

[nginx with passenger](https://www.chiliproject.org/boards/1/topics/2371)

Allows for web hosting at port 80. Point the config to where you have stored this repo at.

### Things you'll probably want to modify

* The *acrecord* command in **pingpong.rb**
  * Your server may be able to handle higher recording frequencies
* The default settings in **fft.rb**
  * I'll eventually get around to making this more portable. In the mean time, modify!
* Where **pingpong.rb** stores logs and writes *out.wav*
  
### How to run it

```bash
$ cd /path/to/rails_sound_spy
$ bundle install
$ RAILS_ENV=production bundle exec rake db:migrate
$ ./pingpong.rb
```

We've turned **pingpong.rb** into a daemon that runs on startup. To do that, you'll need the *daemons* gem.

```bash
$ gem install daemons
```

For nginx, you need to precompile the css:
```bash
$ bundle exec rake assets:precompile
```
You'll also need to start nginx or restart it each time you do this.

If you aren't using nginx (or a similar service), and are instead hosting on port 3000, you may need to modify pingpong.rb to write to the development database, and use
```bash
$ rake db:migrate
```
instead of 
```bash
$ RAILS_ENV=production bundle exec rake db:migrate
```
