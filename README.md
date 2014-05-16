noam\_lemma
===============

A Noam Lemma implementation for Ruby.

This library exposes the fundamental concepts in a Lemma to Ruby developers. It
handles registration, subscription, and message processing. All one needs to do
to create a new Lemma in a network is interact with the Noam::Lemma class. See
the `example/` directory in the project for further details on usage.

Build the ruby gem from noam lemma directory
`gem build noam_lemma.gemspec`

Install the gem
`gem install noam_lemma-version.gem`

Known Issues
------------

* Listening fails un-gracefully when the server goes down.
