# frozen_string_literal: true

require_relative '../../g_1880_romania/round/stock'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Round
        class Stock < G1880Romania::Round::Stock
          def select_entities
            @game.players_without_amira
          end
        end
      end
    end
  end
end
