require "socket"
require "px/service/firehose/config"

module Px
  module Service
    module Firehose
      AWS_DEFAULT_REGION = "us-east-1"
    end
  end
end

require "px/service/firehose/version"
require "px/service/firehose/base_request"
