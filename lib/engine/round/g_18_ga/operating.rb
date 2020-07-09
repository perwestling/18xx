# frozen_string_literal: true

require_relative '../operating'
require_relative '../one_train_per_turn_until_phase_4'

module Engine
  module Round
    module G18GA
      class Operating < Operating
        include OneTrainPerTurnUntilPhase4
      end
    end
  end
end
