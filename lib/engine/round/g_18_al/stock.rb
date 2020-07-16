# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G18AL
      class Stock < Stock
        def initialize(entities, game:, **opts)
          super
          @bonus_controller = player_controlling_route_bonus_ability
          @game = game
        end

        def log_pass(entity)
          begin
            ability = route_bonus_ability
            ability.owner.remove_ability(ability.type)
            @bonus_controller = nil
            @game.log << "Removed from #{ability.owner.name} due to presidency change: #{ability.name}"
          end unless @bonus_controller.nil? || @bonus_controller == player_controlling_route_bonus_ability

          super
        end

        private

        def player_controlling_route_bonus_ability
          ability = route_bonus_ability
          ability.nil? ? nil : ability.owner.owner
        end

        def route_bonus_ability
          @corporations.each do |corporation|
            corporation.abilities(:route_bonus) do |ability|
              return ability
            end
          end

          nil
        end
      end
    end
  end
end
