# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G18AL
      class Token < Token
        def process_place_token(action)
          super

          entity = action.entity
          entity.abilities(:destination) do |ability|
            if action.city.hex.name == ability.hex
              @log << "#{entity.name} receives $100 as it has reached its historical objective"
              entity.cash += 100
              entity.remove_ability(ability)
            end
          end
        end
      end
    end
  end
end
