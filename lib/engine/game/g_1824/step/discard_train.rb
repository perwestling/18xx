# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1824
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def process_discard_train(action)
            train = action.train
            @game.depot.reclaim_train(train)
            @game.depot.forget_train(train)

            @log << "#{action.entity.name} discards #{train.name} and it is removed from the game"
          end
        end
      end
    end
  end
end
