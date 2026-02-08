# frozen_string_literal: true

require_relative '../../g_1880/step/route'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Step
        class Route < G1880::Step::Route
          def actions(entity)
            return ACTIONS if @game.amira_corporation?(entity)

            return [] if !entity.operator? ||
            (entity.runnable_trains.empty? && !entity.minor?) ||
            (!@game.foreign_investors_operate && entity.minor?) ||
            !@game.can_run_route?(entity)

            ACTIONS
          end

          def process_run_routes(action)
            super

            return unless @game.amira_corporation?(action.entity)

            @game.log << "#{@game.acting_for_entity(action.entity).name} runs the route for #{action.entity.name}"
          end
        end
      end
    end
  end
end
