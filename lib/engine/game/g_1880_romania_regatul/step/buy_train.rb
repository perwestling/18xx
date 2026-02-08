# frozen_string_literal: true

require_relative '../../g_1880/step/buy_train'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Step
        class BuyTrain < G1880::Step::BuyTrain
          def actions(entity)
            return [] if @game.amira_corporation?(entity)

            super
          end

          def avoid_discarding_all_trains?(train_name, _train_index)
            %w[8 2P].include?(train_name) || !discard_trains?
          end
        end
      end
    end
  end
end
