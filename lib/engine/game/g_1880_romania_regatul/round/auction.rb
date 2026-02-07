# frozen_string_literal: true

require_relative '../../../round/auction'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Round
        class Auction < Engine::Round::Auction
          def select_entities
            @game.players_without_amira
          end
        end
      end
    end
  end
end
