# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1862Solo
      module Round
        class Stock < Engine::Round::Stock
          def next_entity!
            if finished?
              finish_round
              return
            end

            start_entity
          end
        end
      end
    end
  end
end
