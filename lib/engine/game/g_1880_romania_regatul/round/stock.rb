# frozen_string_literal: true

require_relative '../../g_1880/round/stock'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Round
        class Stock < G1880::Round::Stock
          def select_entities
            @game.players_without_amira
          end

          def finish_round
            super

            @game.amira_selection_at_end_of_stock_round
          end
        end
      end
    end
  end
end
