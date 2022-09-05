# frozen_string_literal: true

require_relative '../../../round/choices'

module Engine
  module Game
    module G1824
      module Round
        class BuyCoalRailway2p < Engine::Round::Choices
          def name
            'Select Buy Price'
          end

          def select_entities
            puts "Choices, select entities for #{@game.buy_to_complete}"
            entity = @game.buy_to_complete[:player]
            puts "Entity = #{entity}"
            [entity]
          end
        end
      end
    end
  end
end
