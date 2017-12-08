#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'

connection = Bunny.new
connection.start

channel = connection.create_channel
queue = channel.queue('hello')

begin
  puts " [*] Waiting for messages. To exit press CTRL+C"
  queue.subscribe(block: true) do |delivery_info, properties, body|
    puts " [x] Recieved #{body}"
  end
rescue Interrupt => _
  connection.close

  exit(0)
end
