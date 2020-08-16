# frozen_string_literal: true

require_relative '../phase'

module Engine
  module G18TN
    class Phase < Phase
      THREE_TRAINS = %w[3 3'].freeze

      def rust_trains!(train, entity)
        return super unless THREE_TRAINS.include(train.name)

        salvage_value = 50
        @rusted = {}
        @game.trains.each do |t|
          next if t.rusted || t.rusts_on != train.sym || !t.owner&.corporation?

          @rusted[t.owner] ||= 0
          @rusted[t.owner] += salvage_value
        end

        super

        @rusted.each do |k, v|
          @log << "#{k.name} receives a salvage value of #{format_currency(v)}"
          @bank.spend(v, k)
        end
      end
    end
  end
end
