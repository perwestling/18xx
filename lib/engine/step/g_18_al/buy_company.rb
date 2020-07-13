# frozen_string_literal: true

require_relative '../buy_company'

module Engine
  module Step
    module G18AL
      class BuyCompany < BuyCompany
        def process_buy_company(action)
          super

          return unless action.company.sym == 'M&C'

          # Add a revenue bonus for the corporation
          # that remains until corporation change president
          ability = Engine::Ability::RouteBonus.new(
              type: :route_bonus,
              name: 'Specific route bonuses',
              value: '$20 / $40',
              **{
                'bonuses' =>
                  [
                    {
                      'route_name' => 'Robert E. Lee: Atlanta-Birmingham',
                      'hexes' => %w[G4 G8],
                      'bonus' => 20,
                    },
                    {
                      'route_name' => 'Pan American: Nashville-Mobile',
                      'hexes' => %w[A4 Q2],
                      'bonus' => 40,
                    },
                  ],
                }
            )
          action.entity.add_ability(ability)
        end
      end
    end
  end
end
