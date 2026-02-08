# frozen_string_literal: true

require_relative '../../g_1880/step/simple_draft'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Step
        class SimpleDraft < G1880::Step::SimpleDraft
          def setup
            super

            @leftover_minors = @minors.size - @game.players_without_amira.size
          end

          def entities
            @game.exclude_amira(@game.players)
          end
        end
      end
    end
  end
end
