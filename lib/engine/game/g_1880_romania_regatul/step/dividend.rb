# frozen_string_literal: true

require_relative '../../g_1880/step/dividend'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Step
        class Dividend < G1880::Step::Dividend
          def actions(entity)
            return [] if @game.amira_corporation?(entity)

            super
          end

          def skip!
            return super unless @game.amira_corporation?(current_entity)

            revenue = @game.routes_revenue(routes)
            kind = if revenue.zero?
                     'withhold'
                   else
                     'payout'
                   end
            process_dividend(Action::Dividend.new(current_entity, kind: kind))
          end
        end
      end
    end
  end
end
