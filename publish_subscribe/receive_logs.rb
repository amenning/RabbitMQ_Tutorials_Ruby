#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'

connection = Bunny.new
connection.start

channel = connection.create_channel
exchange = channel.fanout('logs')
# In the Bunny client, when we supply queue name as an empty string,
# we create a non-durable queue with a generated name
queue = channel.queue('', exclusive: true)

queue.bind(exchange)

puts ' [*] Waiting for logs. To exit press CTRL+C'

begin
  queue.subscribe(block:true) do |delivery_info, properties, body|
    puts " [x] '#{body}'"
  end
rescue Interrupt => _
  channel.close
  connection.close
end
