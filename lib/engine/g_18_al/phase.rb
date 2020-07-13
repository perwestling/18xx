# frozen_string_literal: true

require_relative '../phase'

module Engine
  module G18AL
    class Phase < Phase
      def rust_trains!(train, entity)
        super

        @game.corporations.each do |corporation|
          corporation.remove_ability(:hex_bonus) if corporation.abilities(:hex_bonus).any?
        end if train.sym == '6'
      end
    end
  end
end
