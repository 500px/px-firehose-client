require "digest"
require "redis"
require "aws-sdk"
require "px-service-legacy-client"
require "circuit_breaker"

module Px::Service::Firehose
  class BaseRequest
    include Px::Service::Legacy::Client::CircuitBreaker

    DEFAULT_PUT_RATE = 0.25
    MAX_QUEUE_LENGTH = 1000

    attr_accessor :stream, :credentials
    attr_reader :firehose, :buffer

    # Circuit breaker configuration
    circuit_handler do |handler|
      handler.logger = nil # Or the configured logger
      handler.failure_threshold = 5
      handler.failure_timeout = 7
      handler.invocation_timeout = 10
      handler.excluded_exceptions = [Px::Service::ServiceRequestError]
    end

    def initialize
      @firehose = Aws::Firehose::Client.new(credentials: (@credentials || Px::Service::Firehose.config.credentials), region: Px::Service::Firehose.config.region)
      @redis = Px::Service::Firehose.config.redis
      @dev_queue_key = Px::Service::Firehose.config.dev_queue_key
      @last_send = Time.now
      @last_throughput_exceeded = nil

      @buffer = []
      @mutex = Mutex.new
    end

    ##
    # Check if buffer should be flushed and sent to Firehose.
    def flush_records
      # clear out nil value in buffer
      # TODO: fix and figure out why this is happening
      @buffer = @buffer.compact
      if @buffer.present? && can_flush?
        if Px::Service::Firehose.config.dev_mode && @redis && @dev_queue_key
          # push directly to redis queue if in dev
          @buffer.each do |a|
            @redis.zadd(@dev_queue_key, Time.now.to_f, a[:data])
            @redis.zremrangebyrank(@dev_queue_key, 0, -MAX_QUEUE_LENGTH - 1)
          end
          @buffer = []
        else
          response = @firehose.put_record_batch(delivery_stream_name: @stream, records: @buffer)

          # Add any failed records to our next batch.
          tmp_buffer = []
          if response[:failed_put_count] > 0
            response[:records].each_with_index do |r, index|
              next unless r.error_code

              if r.error_code == Aws::Firehose::Errors::ServiceUnavailableException.code
                @last_throughput_exceeded = Time.now
              end
              tmp_buffer << @buffer[index]
            end
          end

          @buffer = tmp_buffer
        end
        @last_send = Time.now
      end
    end
    circuit_method :flush_records

    ##
    # Takes a blob of data to send to Kinesis Firehose.
    #
    # Returns the number of unsent messages.
    def queue_record(data)
      @mutex.synchronize do
        data_blob = data.to_json

        @buffer << { data: data_blob }

        # Flush if ready.
        flush_records

        @buffer.size
      end
    end

    # Push a single record to Kinesis Firehose, bypass the buffer.
    #
    # Please don't use unless necessary.
    # Mainly used to bypass buffering when testing
    def put_record(data)
      return unless data

      data_blob = data.to_json
      @firehose.put_record(delivery_stream_name: @stream, record: {data: data_blob})
    end
    circuit_method :put_record

    ##
    # Returns true if the buffered messages can be flushed.
    def can_flush?
      (Time.now - @last_send).to_f > put_rate_decay || @buffer.size >= Px::Service::Firehose.config.max_buffer_length
    end

    private

    # Tune this function for handling throughput exceptions.
    # Decay linearly based on when last throughput failure happened.
    def put_rate_decay
      return DEFAULT_PUT_RATE unless @last_throughput_exceeded && (Time.now - @last_throughput_exceeded) < 10
      DEFAULT_PUT_RATE * (2 - ((Time.now - @last_throughput_exceeded) / 10))
    end
  end
end
