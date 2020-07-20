# frozen_string_literal: true

require_relative '../operating'
require_relative '../one_train_per_turn_until_phase_4'

module Engine
  module Round
    module G18AL
      class Operating < Operating
        include OneTrainPerTurnUntilPhase4

        def process_lay_tile(action)
          super

          # Change Montgomery to use M tiles after first tile
          # placed there. From beginning Montgomery is a regular
          # city, but from "green" phase it has its own tiles.
          action.tile.label = 'M' if action.tile.hex.name == 'L5'
        end

        def place_token(action)
          super

          action.entity.abilities(:destination) do |ability|
            if action.city.hex.name == ability.hex
              @log << "#{action.entity.name} receives $100 as it has reached its historical objective"
              action.entity.cash += 100
              action.entity.remove_ability(ability.type)
            end
          end
        end

        def buy_company(company, price)
          super
          return unless company.sym == 'M&C'

          # # Add a revenue bonus for the corporation
          # # that remains until corporation change president
          # ability = Engine::Ability::RouteBonus.new(
          #     type: :route_bonus,
          #     name: 'Specific route bonuses',
          #     value: '$20 / $40',
          #     **{
          #       'bonuses' =>
          #         [
          #           {
          #             'route_name' => 'Robert E. Lee: Atlanta-Birmingham',
          #             'hexes' => %w[G4 G8],
          #             'bonus' => 20,
          #           },
          #           {
          #             'route_name' => 'Pan American: Nashville-Mobile',
          #             'hexes' => %w[A4 Q2],
          #             'bonus' => 40,
          #           },
          #         ],
          #       }
          #   )
          # @current_entity.add_ability(ability)
        end
      end
    end
  end
end
