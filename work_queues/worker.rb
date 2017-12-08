#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'

connection = Bunny.new
connection.start

channel = connection.create_channel
# durable: true ensures that queues are never lost even if RabbitMQ quits/crashes
# This option must be declared in both the producer and consumer
queue = channel.queue('task_queue', durable: true)

# prefetch(1) tells RabbitMQ not to give more than one message to a worker at a time.
# Or, don't dispatch a new message to a worker until it has processed and acknowledged the previous one
channel.prefetch(1)
puts ' [*] Waiting for messages. To exit press CTRL+C'

begin
  # manual_ack: true turns on Message Ack(nowledgement).
  # If a consumer dies and hasn't sent an acknowledgement, RabbitMQ will requeue that message
  queue.subscribe(manual_ack: true, block:true) do |delivery_info, properties, body|
    puts " [x] Received '#{body}'"
    # imitate some work
    sleep body.count('.').to_i
    puts ' [x] Done'
    channel.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _
  connection.close
end
