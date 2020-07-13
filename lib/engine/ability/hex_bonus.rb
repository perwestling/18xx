# frozen_string_literal: true

require_relative 'base'

module Engine
  module Ability
    class HexBonus < Base
      attr_reader :bonus_name, :hex, :bonus

      def setup(bonus_name:, hex:, bonus:)
        @bonus_name = bonus_name
        @hex = hex
        @bonus = bonus
      end
    end
  end
end
