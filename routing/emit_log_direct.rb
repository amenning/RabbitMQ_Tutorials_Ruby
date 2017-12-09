#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'

connection = Bunny.new(hostname: 'localhost')
connection.start

channel = connection.create_channel
# Direct exchange - a message goes to the queues whose binding key exactly 
# matches the routing key of the message.
exchange = channel.direct('direct_logs')

severity = ARGV.shift || 'info'
message = ARGV.empty? ? 'Hello World!' : ARGV.join(' ')

exchange.publish(message, routing_key: severity)
puts " [x] Sent #{message}"

connection.close
