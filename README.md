noam\_lemma
===============

[![Build Status](https://travis-ci.org/noam-io/lemma-ruby.svg?branch=0.2.1.3)](https://travis-ci.org/noam-io/lemma-ruby)

A Noam Lemma implementation for Ruby.

This library exposes the fundamental concepts in a Lemma to Ruby developers. It
handles registration, subscription, and message processing. All one needs to do
to create a new Lemma in a network is interact with the Noam::Lemma class. See
the `example/` directory in the project for further details on usage.

Install the gem
`gem install noam_lemma`

Known Issues
------------

* Listening fails un-gracefully when the server goes down.
