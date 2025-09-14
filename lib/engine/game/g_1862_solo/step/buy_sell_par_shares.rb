# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1862Solo
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          ACTIONS = %w[buy_company pass].freeze

          def actions(entity)
            return [] unless entity == current_entity

            actions = ACTIONS.dup
            actions << 'sell_shares' if can_sell_any?(entity)
            actions << 'choose'
            actions
          end

          # Shares only bought as companies
          def visible_corporations
            puts "visible_corporations called, player: #{@game.solo_player.inspect}, with shares: #{@game.solo_player.shares.map(&:corporation).uniq.map(&:name)}"
            @game.solo_player.shares.map(&:corporation).uniq
          end

          def choices
            choices = {}
            return choices unless choice_available?(current_entity)

            @game.all_rows_indexes.each do |index|
              next unless @game.ipo_rows[index].empty?
              
              choices["deal@#{index}"] = "Deal #{@game.cards_to_deal} cards to IPO Row #{index + 1}"
            end
            choices
          end

          def choice_available?(_entity)
            return unless @game.cards_to_deal.positive?

            @game.ipo_rows.find { |row| row.empty? }
          end

          def choice_name
            'Refill empty IPO Rows'
          end

          def can_buy_company?(player, company)
            @game.ipo_rows.flatten.include?(company) && available_cash(player) >= company.value
          end

          def get_par_prices(entity, _corp)
            @game.repar_prices.select { |p| p.price * 3 <= entity.cash }
          end

          def general_input_renderings_ipo_row(entity, company, index)
            renderings = []
            @game.all_rows_indexes.each do |i|
              next if i == index || @game.ipo_rows[i].empty?
              next unless company.treasury.corporation == @game.ipo_rows[i].first.treasury.corporation

              renderings << ["move@#{company.id}@#{i}", "Move to IPO Row #{i + 1}"]
            end
            renderings << ["remove@#{company.id}", "Remove #{company.name} from IPO Row #{index + 1}"]
            renderings
          end

          # Need to have false here as we are solo player
          def bought?
            false
          end

          def process_choose(action)
            puts "process_choose called with action: #{action.inspect}"
            choice = action.choice
            if choice.start_with?('deal')
              action_deal(choice)
            elsif choice.start_with?('move')
              action_move(choice)
            elsif choice.start_with?('remove')
              action_remove(choice)
            else
              raise GameError, "Unknown choice #{choice}"
            end
            
            track_action(action, @game.solo_player)
          end

          def process_buy_company(action)
            player = action.entity
            company = action.company
            price = action.price
            share = company.treasury
            owner = @game.bank
            puts "Remove from IPO row #{company.ipo_row_index}, company: #{company.inspect}, share: #{share.inspect}"
            @game.ipo_rows[company.ipo_row_index].delete(company)
            puts "Buy share"
            buy_shares(player, ShareBundle.new([share]), allow_president_change: true)
            player.spend(price, owner)
            track_action(action, company)
            @log << "#{player.name} buys 10% of #{share.corporation.name} (in row #{company.ipo_row_index}) from #{owner.name} for #{@game.format_currency(price)}"
            company.close!
          end

          private

          def action_deal(choice)
            index = choice.split('@').last.to_i
            puts "Dealing row #{index}"
            @game.deal_to_ipo_row(index)
            card_text = @game.cards_to_deal == 1 ? 'card is' : 'cards are'
            @log << "#{@game.cards_to_deal} #{card_text} added to IPO Row #{index + 1}"
          end

          def action_move(choice)
            parts = choice.split('@')
            raise GameError, "Incorrect choice format #{choice}" unless parts.size == 3
            id = parts[1]
            index = parts[2].to_i

            puts "Move to row #{index}, company: #{@game.company_by_id(id)}"
            company = @game.company_by_id(id)
            raise GameError, "Company with ID #{id} not found in IPO rows" unless company

            @game.ipo_rows[company.ipo_row_index].delete(company)
            @game.ipo_rows[index].prepend(company)
            company.ipo_row_index = index
            @log << "#{company.name} moves to top of IPO Row #{index + 1}"
          end

          def action_remove(choice)
            id = choice.split('@').last
            company = @game.company_by_id(id)
            raise GameError, "Company with ID #{id} not found in IPO rows" unless company

            @game.ipo_rows[company.ipo_row_index].delete(company)
            @log << "#{company.name} drops from IPO Row #{company.ipo_row_index + 1}"
          end
        end
      end
    end
  end
end
