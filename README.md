
# CentOS 6.9 Image with Ruby 1.8.6-p383 and Ruby 2.0.0-p353


This contains a Dockerfile and CI configuration for building an image used for running the haiku-lms test suite.

It includes the following pieces:

* ruby 1.8.6-p383 (compiled with gcc 4.1.2) for use in haiku-lms
* ruby 2.0.0-p353 for use in haiku-lms/config/193
* mysql 5.6.39
* redis 1.3
* redis 2.6
* bundler 1.0.23 (customized to work here)
* gemsets created for haiku-lms to work

This image is primarily for use in a CI environment.


# Local Usage

* Install docker
* Clone this repository
* Run `docker build .`
* Start the image using `docker run -ti --rm <imageID from above> '/bin/bash'`
