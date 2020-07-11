# frozen_string_literal: true

require_relative '../single_depot_train_buy_before_phase4'

module Engine
  module Step
    module G18AL
      class Train < SingleDepotTrainBuyBeforePhase4
        def process_buy_train(action)
          ability = action.ability

          super

          return if ability.nil?

          action.entity.companies.each do |company|
            if ability == :train_discount && company.sym == 'NDY'
              @log << "Close company #{company.name}"
              company.close!
            end
          end
        end
      end
    end
  end
end
