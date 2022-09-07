# frozen_string_literal: true

require_relative '../../../round/choices'

module Engine
  module Game
    module G1824
      module Round
        class DraftCoalRailways2p < Engine::Round::Choices
          def name
            'Select Buy Price'
          end

          def select_entities
            @game.coal_railways_to_draft
          end
        end
      end
    end
  end
end
