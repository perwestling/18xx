# frozen_string_literal: true

require_relative 'g_18_sj'

module Engine
  module Game
    class G18SJEvolved < G18SJ
      DEV_STAGE = :alpha

      GAME_RULES_URL = {
      }.freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'nationalization' => ['Nationalization check', 'The topmost corporation without trains are nationalized'],
      ).freeze

      STATUS_TEXT = {
      }.merge(Base::STATUS_TEXT).freeze

      def self.title
        '18SJ Evolved'
      end

      def init_corporations(stock_market)
        # Make all corporations full cap
        corporations = super
        corporations.each do |c|
            c.capitalization = :full
        end
        corporations
      end

      def setup
        super

        # Remove full cap event as all corporations are full cap
        @depot.trains.each do |t|
          t.events = t.events.reject { |e| e[:type] == 'full_cap' }
        end
      end
    end
  end
end
