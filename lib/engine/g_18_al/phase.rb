# frozen_string_literal: true

require_relative '../phase'

module Engine
  module G18AL
    class Phase < Phase
      def rust_trains!(train, entity)
        super

        @game.corporations.each do |corporation|
          corporation.abilities(:hex_bonus) do |ability|
            corporation.remove_ability(ability)
          end
        end if train.sym == '6'
      end
    end
  end
end
