# Px::Service::Firehose

A simple Ruby Gem wrapper for Amazon Kinesis Firehose.

Built-in features:

* circuit breaker pattern on networking errors
* linear backoff on throughput error
* timed/length buffering and bulk sending


## Installation

Add this line to your application's Gemfile:

    gem 'px-firehose-client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install px-firehose-client


### Basic Configuration

qDefault configurations are set in *Px::Service::Firehose*, they can be changed by
passing block to *Px::Service::Firehose.configure*


### #queue_records

Call this function to queue up data blobs for dispatching.


### #flush_records

Call this function to check and send data to Kinesis Firehose. If conditions pass, buffered data is consumed and flushed to Kinesis Firehose.

For documentation on CircuitBreaker usage, refer to [Px-Service-Client](https://github.com/500px/px-service-client) docs.


## Contributing

1. Fork it ( https://github.com/[my-github-username]/px-firehose-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
