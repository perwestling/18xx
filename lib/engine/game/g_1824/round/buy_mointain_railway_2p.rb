# frozen_string_literal: true

require_relative '../../../round/choices'

module Engine
  module Game
    module G1824
      module Round
        class BuyMountainRailway2p < Engine::Round::Choices
          def name
            'Optional Buy Of Mountain Railway'
          end

          def select_entities
            @game.players
          end
        end
      end
    end
  end
end
