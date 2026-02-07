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

        def option_amira
          @optional_rules&.include?(:amira)
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
          entities.reject { |item| item == @amira }
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
            trains_3[:num] = 4
            trains_3p[:num] = option_amira ? 3 : 4
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
          super

          return unless option_amira

          # When playing with Amira, randomly select a corporation for Amira to be president of and give them 30% of that corporation.
          # This corporation will build and token as a bot, using special rules. A player cannot become president of this corporation.

          @amira = Amira.new

          first_amira = nil
          until first_amira && first_amira.id != 'TR'
            first_amira = @corporations[ rand & @corporations.size ]
          end

          @log << "Amira gets 30% of #{first_amira.id} as their first company"
          first_amira.presidents_share.percent = 30
          first_amira_share = first_amira.shares.first
          share_to_remove = first_amira.shares.pop(1)
          first_amira.delete_share!(share_to_remove.first)
          @share_pool.buy_shares(@amira, first_amira.presidents_share, exchange: :free, exchange_price: 0)
          first_amira.building_permits = 'ABCD'
          par_70 = @stock_market.par_prices.find { |s| s.price == 70 }
          puts "Amira pars #{first_amira.name} at #{par_70.price} in slot 1: #{first_amira.class} #{par_70.class} #{1.class}"
          @stock_market.set_par(first_amira, par_70)
          set_par(first_amira, par_70, 2)
          after_par(first_amira)

          @players << @amira
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
            G1880::Step::Track,
            G1880::Step::Token,
            G1880::Step::Route,
            G1880::Step::Dividend,
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
      end
    end
  end
end
