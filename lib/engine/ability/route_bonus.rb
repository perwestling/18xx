# frozen_string_literal: true

require_relative 'base'

class Bonus
  attr_reader :route_name, :bonus, :hexes
  def initialize(bonus_info)
    @route_name = bonus_info[:route_name]
    @bonus = bonus_info[:bonus]
    @hexes = bonus_info[:hexes]
  end

  def ==(other)
    @route_name == other.route_name && @bonus == other.bonus && @hexes == other.hexes
  end
end

module Engine
  module Ability
    class RouteBonus < Base
      attr_reader :bonuses

      def setup(bonuses:)
        @bonuses = []
        bonuses.each do |bonus_info|
          @bonuses << Bonus.new(bonus_info)
        end
      end
    end
  end
end
