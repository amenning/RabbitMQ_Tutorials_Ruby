#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'

connection = Bunny.new(hostname: 'localhost')
connection.start

channel = connection.create_channel
# durable: true ensures that queues are never lost even if RabbitMQ quits/crashes
# This option must be declared in both the producer and consumer
queue = channel.queue('task_queue', durable: true)

message = ARGV.empty? ? 'Hello World!' : ARGV.join(' ')

# persistent: true ensures that the messsages wont be lost if RabbitMQ restarts
queue.publish(message, persistent: true)
puts " [x] Sent #{message}"

sleep 1.0
connection.close
