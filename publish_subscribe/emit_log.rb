#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'

connection = Bunny.new(hostname: 'localhost')
connection.start

channel = connection.create_channel
# The fanout exchange is very simple. As you can probably guess from the name,
# it just broadcasts all the messages it receives to all the queues it knows.
exchange = channel.fanout('logs')

message = ARGV.empty? ? 'Hello World!' : ARGV.join(' ')

exchange.publish(message)
puts " [x] Sent #{message}"

connection.close
