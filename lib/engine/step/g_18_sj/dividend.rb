# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G18SJ
      class Dividend < Dividend
        include MinorHalfPay

        def share_price_change(entity, revenue = 0)
          return {} if entity.minor?

          price = entity.share_price.price
          return { share_direction: :left, share_times: 1 } unless revenue.positive?

          times = 0
          times = 1 if revenue >= price
          times = 2 if revenue >= price * 2 && price >= 82
          if times.positive?
            { share_direction: :right, share_times: times }
          else
            {}
          end
        end
      end
    end
  end
end
