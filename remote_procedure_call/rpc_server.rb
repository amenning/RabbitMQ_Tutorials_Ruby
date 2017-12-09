#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'

class FibonacciServer
  def initialize(channel)
    @channel = channel
  end

  def start(queue_name)
    @queue = @channel.queue(queue_name)
    @exchange = @channel.default_exchange

    @queue.subscribe(block: true) do |delivery_info, properties, payload|
      n = payload.to_i
      response = self.class.fib(n)

      @exchange.publish(
        response.to_s,
        routing_key: properties.reply_to,
        correlation_id: properties.correlation_id
      )
    end
  end

  def self.fib(n)
    case n
    when 0 then 0
    when 1 then 1
    else
      fib(n - 1) + fib(n - 2)
    end
  end
end

begin
  connection = Bunny.new
  connection.start
  channel = connection.create_channel
  server = FibonacciServer.new(channel)
  puts ' [x] Awaiting RPC requests'
  server.start('rpc_queue')
rescue Interrupt => _
  channel.close
  connection.close
end
