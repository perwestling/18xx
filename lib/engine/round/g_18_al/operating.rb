# frozen_string_literal: true

require_relative '../operating'
require_relative '../one_train_per_turn_until_phase_4'

module Engine
  module Round
    module G18AL
      class Operating < Operating
        include OneTrainPerTurnUntilPhase4

        def process_lay_tile(action)
          super

          # Change Montgomery to use M tiles after first tile
          # placed there. From beginning Montgomery is a regular
          # city, but from "green" phase it has its own tiles.
          action.tile.label = 'M' if action.tile.hex.name == 'L5'
        end
      end
    end
  end
end
