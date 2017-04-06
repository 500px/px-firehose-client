module Px
  module Service
    module Firehose
      class << self
        DefaultConfig = Struct.new(:region, :credentials, :redis, :dev_mode, :dev_queue_key, :logger, :max_buffer_length) do
          def initialize
            self.region = AWS_DEFAULT_REGION
            self.credentials = Aws::SharedCredentials.new
            self.dev_mode = false
            self.dev_queue_key = nil
            self.redis = nil

            # Maximum length of buffer before flushing.
            self.max_buffer_length = 200
          end
        end

        def configure
          @config ||= DefaultConfig.new
          yield(@config) if block_given?
          @config
        end

        def config
          @config || configure
        end
      end
    end
  end
end
