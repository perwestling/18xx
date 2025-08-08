# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1824
      module Step
        class Track < Engine::Step::Track
          def can_lay_tile?(entity)
            # Rule X.4: Regional created by construction railway does not lay any tiles
            return false if @game.bond_railway?(entity)

            super
          end
        end
      end
    end
  end
end
