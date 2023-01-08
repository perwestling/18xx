# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1824
      module Step
        class Track < Engine::Step::Track
          def actions(entity)
            return [] if entity.receivership?

            super
          end
        end
      end
    end
  end
end
