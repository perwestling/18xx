# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1824
      module Step
        class Dividend < Engine::Step::Dividend
          ACTIONS = [].freeze

          def actions(entity)
            return ACTIONS if @game.bond_railway?(entity)
            # return [] if @game.bond_railway?(entity)
            return [] if entity.minor?

            super
          end

          def dividend_options(entity)
            mine_revenue = @game.mine_revenue(routes)
            revenue = @game.routes_revenue(routes) - mine_revenue
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue, mine_revenue)
              payout[:divs_to_corporation] = 0
              [type, payout.merge(share_price_change(entity, payout[:per_share].positive? ? revenue : 0))]
            end
          end

          def process_dividend(action)
            entity = action.entity
            kind = action.kind.to_sym
            amount = action.amount
            if amount
              mine_revenue = 0
              revenue = action.amount
              payout = { corporation: 0, per_share: revenue / 10, share_direction: :right, share_times: 1 }
            else
              mine_revenue = @game.mine_revenue(routes)
              revenue = @game.routes_revenue(routes) - mine_revenue
              payout = dividend_options(entity)[kind]
            end            
            @game.log << "AMOUNT: #{amount}"

            entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
              routes,
              action,
              revenue + mine_revenue,
              @round.laid_hexes
            )

            entity.trains.each { |train| train.operated = true }

            @round.routes = []

            log_run_payout(entity, kind, revenue, mine_revenue, action, payout)

            @game.bank.spend(payout[:corporation], entity) if payout[:corporation].positive?

            payout_shares(entity, revenue) if payout[:per_share].positive?

            change_share_price(entity, payout)

            pass!
          end

          def skip!
            @game.log << "### SKIP ###"
            puts "#### SKIP!"
            return revenue_for_bond_railway(current_entity) if @game.bond_railway?(current_entity)
            return super unless current_entity.minor?

            revenue = @game.routes_revenue(routes)

            process_dividend(Action::Dividend.new(
              current_entity,
              kind: revenue.positive? ? 'payout' : 'withhold',
            ))
          end

          def revenue_for_bond_railway(bond_railway)
            @game.log << "### DO PROCESS DIVIDEND FOR BOND RAILWAY"
            revenue = bond_railway.share_price.price

            process_dividend(Action::Dividend.new(
              current_entity,
              kind: 'payout',
              amount: revenue,
            ))
          end

          def share_price_change(entity, revenue = 0)
            return super if !entity.minor? || @game.bond_railway?(entity)

            {}
          end

          def withhold(_entity, revenue, mine_revenue)
            { corporation: revenue + mine_revenue, per_share: 0 }
          end

          def payout(entity, revenue, mine_revenue)
            if entity.minor?
              fifty_percent = revenue / 2
              { corporation: fifty_percent + mine_revenue, per_share: fifty_percent }
            else
              { corporation: mine_revenue, per_share: payout_per_share(entity, revenue) }
            end
          end

          def payout_shares(entity, revenue)
            return super unless entity.minor?

            owner_revenue = revenue / 2
            @log << "#{entity.owner.name} receives #{@game.format_currency(owner_revenue)}"
            @game.bank.spend(owner_revenue, entity.owner)
          end

          private

          def log_run_payout(entity, kind, revenue, mine_revenue, action, payout)
            unless Dividend::DIVIDEND_TYPES.include?(kind)
              @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
            end

            if payout[:per_share].zero? && payout[:corporation].zero?
              @log << "#{entity.name} does not run"
            elsif payout[:per_share].zero?
              @log << "#{entity.name} withholds #{@game.format_currency(revenue)}"
            end

            return unless payout[:corporation].positive?

            mine = mine_revenue.positive? ? " of which #{@game.format_currency(mine_revenue)} is from mine(s)" : ''
            @log << "#{entity.name} receives #{@game.format_currency(payout[:corporation])}#{mine}"
          end
        end
      end
    end
  end
end
