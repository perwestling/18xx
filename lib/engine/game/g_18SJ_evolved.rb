# frozen_string_literal: true

require_relative 'g_18_sj'

module Engine
  module Game
    class G18SJEvolved < G18SJ
      DEV_STAGE = :alpha

      # Pay dividend for share pool shares to corporation (if full cap)
      SHARE_POOL_TO_BANK = false

      # E trains should not double any tokens
      E_TRAIN_DOUBLE_SOME_TOKENS = false

      GAME_RULES_URL = {
      }.freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'nationalization' => ['Nationalization check', 'The topmost corporation without trains are nationalized'],
      ).freeze

      STATUS_TEXT = {
      }.merge(Base::STATUS_TEXT).freeze

      MARKET = [%w[82 90 100p 110 125 140 160 180 200 225 250 275 300 325 350e],
                %w[76 82 90p 100 110 125 140 160 180 200 220 240 260 280 300],
                %w[71 76 82p 90 100 110 125 140 155 170 185 200],
                %w[67 71 76p 82 90 100 110 120 130],
                %w[65 67 71p 76 82 90 100],
                %w[63y 65 67p 71 76 82],
                %w[60y 63 65 67 71],
                %w[50y 60y 63 65],
                %w[40o 50y 60y],
                %w[30b 40o 50y],
                %w[20b 30b 40o],
               ]

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

      def init_train_handler
        trains = self.class::TRAINS.flat_map do |train|
          t = train
          if t['name'] == 'D'
            t['price'] = 900
            t['discount'] = {'4' => 200, '5' => 200, '6' => 200 }
            t['variants'] = [{ 'name' => 'E', 'price' => 1100 }]
          end
          (train[:num] || num_trains(train)).times.map do |index|
            Train.new(**train, index: index)
          end
        end

        Depot.new(trains, self)
      end

    end
  end
end
