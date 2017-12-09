#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'

if ARGV.empty?
  abort "Usage: #{$0} [binding key]"
end

connection = Bunny.new
connection.start

channel = connection.create_channel
# Topic exchange - a message goes to the queues whose binding fits the criteria.
# This allows for routing based on multiple criteria.
exchange = channel.topic('topic_logs')
queue = channel.queue('', exclusive: true)

# Create a new binding for each severity we're interested in
ARGV.each do |severity|
  queue.bind(exchange, routing_key: severity)
end

puts ' [*] Waiting for logs. To exit press CTRL+C'

begin
  queue.subscribe(block:true) do |delivery_info, properties, body|
    puts " [x] #{delivery_info.routing_key}:#{body}"
  end
rescue Interrupt => _
  channel.close
  connection.close
end
