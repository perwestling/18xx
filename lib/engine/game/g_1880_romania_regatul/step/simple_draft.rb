# frozen_string_literal: true

require_relative '../../g_1880/step/simple_draft'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Step
        class SimpleDraft < G1880::Step::SimpleDraft
          def entities
            @game.exclude_amira(@game.players)
          end
        end
      end
    end
  end
end
