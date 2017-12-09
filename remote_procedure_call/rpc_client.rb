#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'thread'

class FibonacciClient
  attr_reader :reply_queue
  attr_accessor :response, :call_id
  attr_reader :lock, :condition

  def initialize(channel, server_queue)
    @channel = channel
    @exchange = channel.default_exchange

    @server_queue = server_queue
    @reply_queue = @channel.queue('', exclusive: true)

    @lock = Mutex.new
    @condition = ConditionVariable.new
    that = self

    @reply_queue.subscribe do |delivery_info, properties, payload|
      if properties[:correlation_id] == that.call_id
        that.response = payload.to_i
        that.lock.synchronize { that.condition.signal }
      end
    end
  end

  def call(n)
    self.call_id = self.generate_uuid

    @exchange.publish(
      n.to_s,
      routing_key: @server_queue,
      correlation_id: call_id,
      reply_to: @reply_queue.name
    )

    @lock.synchronize { @condition.wait(@lock) }
    @response
  end

  protected

  def generate_uuid
    # very naive but good enough for code
    # examples
    "#{rand}#{rand}#{rand}"
  end
end

connection = Bunny.new(hostname: 'localhost', automatically_recover: false)
connection.start
channel = connection.create_channel
client = FibonacciClient.new(channel, 'rpc_queue')
puts ' [x] Requesting fib(30)'
response = client.call(30)
puts " [.] Got #{response}"

channel.close
connection.close
