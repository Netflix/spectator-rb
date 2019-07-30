# frozen_string_literal: true

require 'spectator/version'
require 'spectator/registry'
require 'spectator/meter_id'
require 'spectator/clock'
require 'spectator/timer'
require 'spectator/counter'
require 'spectator/distribution_summary'
require 'spectator/gauge'
require 'logger'

# Simple library for instrumenting code to record dimensional time series.
module Spectator
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
  end
end
