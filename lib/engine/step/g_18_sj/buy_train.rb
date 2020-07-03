# frozen_string_literal: true

require_relative '../base'
require_relative '../buy_train'

module Engine
  module Step
    module G18SJ
      class BuyTrain < BuyTrain
        def buy_train_action(action, entity = nil)
          super

          @game.perform_nationalization if @game.pending_nationalization?
        end
      end
    end
  end
end
