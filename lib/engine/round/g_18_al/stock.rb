# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G18AL
      class Stock < Stock
        def initialize(entities, game:, **opts)
          super
          @controller_at_start = current_controller
        end

        def log_pass(entity)
          super
          return if @controller_at_start.nil? || @controller_at_start == current_controller

          @log << "#{route_bonus_ability.owner.name} removes route bonuses as presidency changed"
          president_changed(route_bonus_ability.owner)
          @controller_at_start = nil
        end

        private

        def current_controller
          route_bonus_ability&.owner&.owner
        end

        def route_bonus_ability
          @game.corporations.each do |corporation|
            corporation.abilities(:route_bonus) do |ability|
              return ability
            end
          end

          nil
        end

        def president_changed(corporation)
          corporation.abilities(:route_bonus) do |ability|
            corporation.remove_ability(ability)
          end
        end
      end
    end
  end
end
