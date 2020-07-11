# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class TrainDiscount < Base
      attr_reader :discount, :absolute, :trains
      def setup(discount:, absolute:, trains:)
        @discount = discount
        @absolute = absolute
        @trains = trains
      end
    end
  end
end
