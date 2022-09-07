# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'skip_bond_railways'

module Engine
  module Game
    module G1824
      module Step
        class Track < Engine::Step::Track
          include SkipBondRailways
        end
      end
    end
  end
end
