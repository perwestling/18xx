# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1880_romania/game'
require_relative 'map'
require_relative '../g_1880_romania/entities'

module Engine
  module Game
    module G1880RomaniaRegatul
      class Game < G1880Romania::Game
        include_meta(G1880RomaniaRegatul::Meta)
        include Map

        attr_reader :vaclav

        CERT_LIMIT = { 2 => 22, 3 => 18 }.freeze

        STARTING_CASH = { 2 => 700, 3 => 500 }.freeze

        GAME_END_REASONS_TEXT = {
          final_train: '6E train sold or exported',
        }.freeze

        GAME_END_REASONS_TIMING_TEXT = {
          one_more_full_or_set: '3 ORs ending with the Corporation that triggered game end',
        }.freeze

        GAME_END_DESCRIPTION_REASON_MAP_TEXT = {
          final_train: '6E train was sold or exported',
        }.freeze

        EVENTS_TEXT = G1880Romania::Game::EVENTS_TEXT.merge(
          'select_amira_corporation' => ['Amira select corporation', 'Amira selects one unlauched corporation to float, at end of Stock Round']
        ).freeze

        def option_amira
          @optional_rules&.include?(:amira)
        end

        def init_share_pool
          return super unless option_amira

          G1880RomaniaRegatul::SharePool.new(self)
        end

        class Amira < Player
          def initialize
            super(-1, 'Amira')
          end

          # allowed to go negative when spending on track lays
          def check_cash(*args, **kwargs); end
        end

        def player_of_index(index)
          players_without_amira[index]
        end

        def players_without_amira
          exclude_amira(@players)
        end

        def exclude_amira(entities)
          return entities unless option_amira

          entities.reject { |item| item == @amira }
        end

        def reorder_players(order = nil, log_player_order: false, silent: false)
          return super unless option_amira

          # Amira does not act during SR so should not have priority deal

          super(order, log_player_order: false, silent: true)
          if @players.first == @amira
            @players.rotate!
          end

          @log << "#{@players.first.name} has priority deal"
        end

        def optional_hexes
          map_optional_hexes(option_amira)
        end

        def game_companies
          companies = COMPANIES.map(&:dup)
          kept_companies = %w[P1 P4 P5 P6 P7]
          kept_companies << 'P8' if option_amira
          companies.select { |c| kept_companies.include?(c[:sym]) }
        end

        def game_minors
          minors = MINORS.map(&:dup)

          kept_minors = %w[1 2 3 6]
          coordinates = {
            '1' => 'I7',
            '2' => 'V2',
            '3' => 'Z10',
            '6' => 'N8',
          }.freeze
          minors
          .select { |m| kept_minors.include?(m[:sym]) }
          .each { |m| m[:coordinates] = coordinates[m[:sym]] }
        end

        def game_corporations
          corporations = CORPORATIONS.map(&:dup)
          kept_corporations = %w[LCR MR Bess VRL CFR GWR LWR DR]
          kept_corporations << 'TR' if option_amira
          coordinates = {
            'LCR' => 'Q1',
            'MR' => 'U3',
            'Bess' => 'X4',
            'VRL' => 'P8',
            'CFR' => 'Q9',
            'GWR' => 'Q9',
            'LWR' => 'J10',
            'DR' => 'X10',
            'TR' => 'L6',
          }.freeze
          corporations
          .select { |c| kept_corporations.include?(c[:sym]) }
          .each { |m| m[:coordinates] = coordinates[m[:sym]] }
        end

        def game_trains
          unless @game_trains
            @game_trains = super.map(&:dup)
            trains_2, trains_2p, trains_3, trains_3p, trains_4, trains_4p, trains_6, trains_6e, trains_8, trains_8e = @game_trains
            trains_2[:num] = 8
            trains_2p[:num] = 4
            trains_2p[:events] = [{ 'type' => 'select_amira_corporation' }] if option_amira
            trains_3[:num] = 4
            trains_3p[:num] = option_amira ? 3 : 4
            trains_3p[:events] = [{ 'type' => 'communist_takeover' }]
            trains_3p[:events] << { 'type' => 'select_amira_corporation' } if option_amira
            trains_4[:num] = option_amira ? 3 : 4
            trains_4p[:num] = option_amira ? 3 : 4
            trains_6[:num] = 2
            trains_6e[:num] = 1
            trains_6e[:events] = [{ 'type' => 'signal_end_game', 'when' => 1 }]
            trains_8[:num] = 'unlimited'
            trains_8e[:num] = 0
          end
          @game_trains
        end

        def par_chart
          @par_chart ||=
            share_prices.sort_by { |sp| -sp.price }.to_h { |sp| [sp, [nil, nil, nil]] }
        end

        def setup
          @amira_corporations = []
          @amira_selection_at_end_of_stock_round = false

          super

          return unless option_amira

          # When playing with Amira, randomly select a corporation for Amira to be president of and give them 30% of that corporation.
          # This corporation will build and token as a bot, using special rules. A player cannot become president of this corporation.

          @amira = Amira.new

          @amira_always_president_ability =
            Engine::Ability::Description.new(type: 'description', description: 'Amira always president')
          @free_tile_lay_ability =
            Engine::Ability::Description.new(type: 'description',
                                             description: 'Free tile lay / token before phase D',
                                             desc_detail: 'Can lay one yellow tile or one upgrade before gray phase. '\
                                                          'Token placement is free.')
          @borrow_trains_ability =
            Engine::Ability::Description.new(type: 'description',
                                             description: 'Borrows train like a Foreign Investor',
                                             desc_detail: 'Does not buy trains. '\
                                                          'Instead the corporation borrows the next train from the depot if needed.')
          @amira_control_ability_1 =
            Engine::Ability::Description.new(type: 'description',
                                             description: 'Priority dealer lay track',
                                             desc_detail: 'The player with the priority deal lays one track tile or upgrade. '\
                                                          'The other player chose if token should be placed, and also choses the best route.')
          @amira_control_ability_2 =
            Engine::Ability::Description.new(type: 'description',
                                             description: 'Player without priority deal lay track',
                                             desc_detail: 'The player chose if token should be placed, and also choses the best route. '\
                                                          'The player with the priority deal lays one track tile or upgrade. ')

          first_amira = nil
          until first_amira && first_amira.id != 'TR'
            first_amira = @corporations[ rand % @corporations.size ]
          end

          float_amira_corporation(first_amira, 70, 2)

          @players << @amira
        end

        def float_amira_corporation(amira_corporation, par_price_value, index)
          case @amira_corporations.size
          when 0
            order_description = 'first'
            order_ability = @amira_control_ability_1.dup
          when 1
            order_description = 'second'
            order_ability = @amira_control_ability_2.dup
          when 2
            order_description = 'third'
            order_ability = @amira_control_ability_1.dup
          end

          # Give AMirca 30% of the corporation
          @log << "Amira gets 30% of #{amira_corporation.id} as their #{order_description} company"
          amira_corporation.presidents_share.percent = 30
          amira_corporation_share = amira_corporation.shares.first
          share_to_remove = amira_corporation.shares.pop(1)
          amira_corporation.delete_share!(share_to_remove.first)
          @share_pool.buy_shares(@amira, amira_corporation.presidents_share, exchange: :free, exchange_price: 0)
          amira_corporation.add_ability(@amira_always_president_ability.dup)

          # Unreserve all shares
          amira_corporation.shares.each { |s| s.buyable = true }

          # Can build in all phases, all tookens are free, do not buy trains
          amira_corporation.building_permits = 'ABC'
          amira_corporation.add_ability(@free_tile_lay_ability.dup)
          amira_corporation.add_ability(order_ability)
          amira_corporation.tokens.each { |token| token.price = 0 }
          amira_corporation.add_ability(@borrow_trains_ability.dup)

          # Give par in the last free index of the specified par value
          par_price = @stock_market.par_prices.find { |s| s.price == par_price_value }
          @stock_market.set_par(amira_corporation, par_price)
          set_par(amira_corporation, par_price, index)
          after_par(amira_corporation)

          # Amirca corporation is now floated and ready to use
          amira_corporation.float!
          amira_corporation.fully_funded = true
          @log << "#{amira_corporation.id} floats at #{format_currency(par_price_value)}"
          @amira_corporations << amira_corporation
        end

        def new_auction_round
          G1880RomaniaRegatul::Round::Auction.new(self, [
            G1880::Step::CompanyPendingPar,
            G1880::Step::SelectionAuction,
          ])
        end

        def new_draft_round
          Engine::Round::Draft.new(self, [G1880RomaniaRegatul::Step::SimpleDraft], reverse_order: false)
        end

        def stock_round
          G1880RomaniaRegatul::Round::Stock.new(self, [
            Engine::Step::Exchange,
            G1880::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1880::Round::Operating.new(self, [
            Engine::Step::HomeToken,
            Engine::Step::Exchange,
            Engine::Step::DiscardTrain,
            G1880RomaniaRegatul::Step::Track,
            G1880RomaniaRegatul::Step::Token,
            G1880RomaniaRegatul::Step::Route,
            G1880RomaniaRegatul::Step::Dividend,
            G1880RomaniaRegatul::Step::BuyTrain,
            G1880::Step::CheckFIConnection,
          ], round_num: round_num)
        end

        def dummy_company
          @dummy ||= Company.new(
            name: 'Dummy Company',
            sym: 'DUMMY',
            value: 0,
          )
          @dummy.close!
          @dummy
        end

        def amira_corporation?(corporation)
          return false unless option_amira

          @amira_corporations.include?(corporation)
        end

        def event_select_amira_corporation!
          @log << "-- Event: #{EVENTS_TEXT['select_amira_corporation'][1]} --"
          @amira_selection_at_end_of_stock_round = true
        end

        def amira_selection_at_end_of_stock_round
          return unless @amira_selection_at_end_of_stock_round

          @amira_selection_at_end_of_stock_round = false
          candidates = @corporations.select { |c| c.player_share_holders.none? }
          if candidates.empty?
            @log << 'No unlaunched corporation excists, so Amira selection is skipped'
            return
          end

          amira_corporation = candidates[ rand % candidates.size ]
          sp, index = next_empty_slot_after_train_marker
          puts sp, index
          float_amira_corporation(amira_corporation, sp.price, index)
        end

        def acting_for_entity(entity)
          return super unless amira_corporation?(entity)
          return super unless current_entity == entity

          case @round.active_step
          when G1880RomaniaRegatul::Step::Track
            players_without_amira[0]
          when G1880RomaniaRegatul::Step::Token, G1880RomaniaRegatul::Step::Route
            players_without_amira[1]
          else
            super
          end
        end

        def route_trains(entity)
          amira_corporation?(entity) ? [@depot.min_depot_train] : super
        end

        def upgrades_to_correct_label?(from, to)
          if from.color == :white && from.cities.size == 2
            return from.label == to.label if to.label&.to_s == 'B'
          end

          super
        end

        # Modified compared to 1880 as no BCR, and potential Amira corporation has only one tile lay
        def tile_lays(entity)
          return [] unless can_build_track?(entity)

          tile_lays = [{ lay: true, upgrade: true }]
          return tile_lays if entity.minor? || !@phase.tiles.include?(:green) || amira_corporation?(entity)

          tile_lays << { lay: :not_if_upgraded, upgrade: false }
          tile_lays
        end

        # Not used in this variant
        def rocket
          dummy_company
        end

        # Not used in this variant
        def rocket_train; end
        def fix_rocket_ability; end
        def force_exchange_rocket; end

        # P0 and P5 not used in this variant. P1 is assumed to have the same effect as in base game.
        def p0; end

        # Not used in this variant
        def ferry_hexes
          []
        end

        # Not used in this variant
        def ferry_company
          dummy_company
        end

        # Not used in this variant
        def taiwan_company
          dummy_company
        end

        # Not used in this variant
        def taiwan_hex; end

        # Not used in this variant
        def trans_siberian_bonus?(_stops); end

        private

        def stock_price_and_slot(corporation)
          # The position for a coproration in the par chart
          par_chart.each do |sp, slots|
            index = slots.index { |entry| entry == corporation }
            return [sp, index] if index
          end
        end

        def empty_slots
          # All empty slots, ordered in descedning stock price, but ascending index
          empty = []
          par_chart.each do |sp, slots|
            slots.each_with_index do |entry, index|
              empty << [sp, index] if entry.nil?
            end
          end
          empty
        end

        def next_empty_slot_after_train_marker
          # Get the first empty slots that are after the current train marker.
          current = stock_price_and_slot(@train_marker)
          empty_slots.find do |sp, index|
            sp.price < current[0].price || (sp.price == current[0].price && index > current[1])
          end || empty_slots.first
        end
      end
    end
  end
end
