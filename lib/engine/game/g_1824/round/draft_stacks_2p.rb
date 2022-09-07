# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G1824
      module Round
        class DraftStacks2p < Engine::Round::Draft
          def name
            'Select company from stack'
          end

          def select_entities
            @game.players
          end
        end
      end
    end
  end
end
