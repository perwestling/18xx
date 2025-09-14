# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1862Solo
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          ACTIONS = %w[pass].freeze

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
            return renderings if @game.ipo_rows[index].empty?
            
            share = company.treasury
            puts "#{share.corporation.name} floated? #{share.corporation.floated?}"

            @game.all_rows_indexes.each do |i|
              next if i == index || @game.ipo_rows[i].empty?
              next unless company.treasury.corporation == @game.ipo_rows[i].first.treasury.corporation

              renderings << ["move@#{company.id}@#{i}", "Move to IPO Row #{i + 1}"]
            end

            renderings << ["remove@#{company.id}", "Remove #{company.name} from IPO Row #{index + 1}"]

            if share.corporation.share_price
              renderings << ["buy@#{company.id}", "Buy #{company.name} for #{@game.company_value(company)}"]
            else
              # TODO: Need to get all possible par prices - separate view?
              # TODO: Is it possible to use interval?
              price1 = @game.repar_prices.first.price
              renderings << ["par_unchartered@#{price1}@#{company.id}", "Par at #{price1} (unchartered)"]
              price2 = @game.par_prices.first.price
              renderings << ["par_chartered@#{price2}@#{company.id}", "Par at #{price2} (chartered)"]
            end

            renderings
          end

          # Need to have false here as we are solo player
          def bought?
            false
          end

          def process_choose(action)
            puts "process_choose called with action: #{action.inspect}"
            choice = action.choice
            if choice.start_with?('buy')
              action_buy(choice)
            elsif choice.start_with?('deal')
              action_deal(choice)
            elsif choice.start_with?('move')
              action_move(choice)
            elsif choice.start_with?('par_chartered')
              action_par_chartered(choice)
            elsif choice.start_with?('par_unchartered')
              action_par_unchartered(choice)
            elsif choice.start_with?('remove')
              action_remove(choice)
            else
              raise GameError, "Unknown choice #{choice}"
            end
            
            track_action(action, @game.solo_player)
          end

          private

          def action_buy(choice)
            company = get_company_from_choice(choice)
            price = @game.company_value(company)
            share = company.treasury
            corporation = share.corporation
            owner = @game.bank
            player = @game.solo_player

            @game.ipo_rows[company.ipo_row_index].delete(company)
            buy_shares(player, ShareBundle.new([share]), allow_president_change: true)
            player.spend(price, owner)

            @log << "#{player.name} buys 10% of #{share.corporation.name} (in row #{company.ipo_row_index}) from #{owner.name} for #{@game.format_currency(price)}"

            if !corporation.floated? && player.shares_by_corporation[corporation].size >= 3
              float_corporation(corporation)
            end
            company.close!
          end

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
            company = get_company(id)
            @game.ipo_rows[company.ipo_row_index].delete(company)
            @game.ipo_rows[index].prepend(company)
            company.ipo_row_index = index
            @log << "#{company.name} moves to top of IPO Row #{index + 1}"
          end

          def action_par_chartered(choice)
            parts = choice.split('@')
            raise GameError, "Incorrect choice format #{choice}" unless parts.size == 3
            price = parts[1].to_i
            id = parts[2]
            company = get_company(id)
            share = company.treasury
            corporation = share.corporation

            par_corporation(share, corporation, price, true)
            cleanup_company(company)
          end

          def action_par_unchartered(choice)
            # TODO: Need to swap president share
            parts = choice.split('@')
            raise GameError, "Incorrect choice format #{choice}" unless parts.size == 3
            price = parts[1].to_i
            id = parts[2]
            company = get_company(id)
            share = company.treasury
            corporation = share.corporation

            @game.convert_to_incremental!(corporation)
            corporation.tokens.pop # 3 -> 2
            raise GameError, 'Wrong number of tokens for Unchartered Company' if corporation.tokens.size != 2

            par_corporation(share, corporation, price, false)
            cleanup_company(company)
          end
          
          def par_corporation(share, corporation, price, chartered)
            shares_prices = chartered ? @game.par_prices : @game.repar_prices
            owner = chartered ? @game.bank : corporation 
            player = @game.solo_player
            share_price = shares_prices.find { |p| p.price == price }
            @game.stock_market.set_par(corporation, share_price)
            buy_shares(player, ShareBundle.new([share]), allow_president_change: true)
            @log << "#{corporation.name} pars at #{price}"
            if chartered
              @log << "#{player.name} buys president's share at #{price}"
              player.spend(price, @game.bank)
            else
              @log << "#{player.name} buys president's share from #{corporation.name} at #{price}"
              player.spend(price, corporation)
            end
          end

          def action_remove(choice)
            company = get_company_from_choice(choice)
            @log << "#{company.name} drops from IPO Row #{company.ipo_row_index + 1}"
            cleanup_company(company)
          end

          def get_company_from_choice(choice)
            id = choice.split('@').last
            get_company(id)
          end

          def get_company(id)
            company = @game.company_by_id(id)
            raise GameError, "Company with ID #{id} not found in IPO rows" unless company

            company
          end

          def cleanup_company(company)
            @game.ipo_rows[company.ipo_row_index].delete(company)
            company.close!
          end

          def float_corporation(corporation)
            corporation.floated = true
            # TODO: use correct cash
            cash = 100
            @game.bank.spend(cash, corporation)
            @log << "#{corporation.name} floats and receives #{cash}"
          end
        end
      end
    end
  end
end
