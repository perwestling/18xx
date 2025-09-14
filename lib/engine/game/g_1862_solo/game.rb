# frozen_string_literal: true

require_relative '../g_1862/game'
require_relative 'corporation'
require_relative 'meta'

module Engine
  module Game
    module G1862Solo
      class Game < G1862::Game
        include_meta(G1862Solo::Meta)

        attr_reader :ipo_rows

        # No cert limit
        CERT_LIMIT = {
          1 => 999,
        }.freeze

        STARTING_CASH = {
          1 => 600,
        }.freeze

        # No cert limit
        def show_game_cert_limit?
          false
        end

        def solo_player
          players.first
        end

        def setup_preround
          @original_corporations = @corporations.dup

          super

          @original_corporations.reject { |c| @corporations.include?(c) }.each do |c|
            hex = @hexes.find { |h| h.id == c.coordinates } # hex_by_id doesn't work here
            old_tile = hex.tile
            tile_string = ''
            hex.tile = Tile.from_code(old_tile.name, 'brown', tile_string)
          end

          # Build draw and draft decks for player hand and IPO rows
          @ipo_rows = [[], [], [], [], [], [], [], [], []]
          create_decks(@corporations)
        end

        def create_decks(corporations)
          @deck = []

          corporations.each do |corporation|
            corporation.ipo_shares.each do |share|
              company = convert_share_to_company(share)
              company.owner = bank
              @deck << company

              # Need to store them so that they are found by company_by_id
              @companies << company
            end
          end

          @deck.sort_by! { rand }
          deal_deck_to_ipo()
        end

        # create a placeholder 'company' for shares in IPO
        def convert_share_to_company(share)
          description = "Certificate for #{share.percent}\% of #{share.corporation.full_name}."
          G1862Solo::Company.new(
            sym: share.id,
            name: share.corporation.name,
            value: 1,
            desc: description,
            type: :share,
            color: share.corporation.color,
            text_color: share.corporation.text_color,
            # reference to share in treasury
            treasury: share,
            revenue: nil,
          )
        end

        def deal_deck_to_ipo
          all_rows_indexes.each do |row|
            deal_to_ipo_row(row)
          end
        end

        def cards_to_deal
          @deck.size >= 6 ? 6 : @deck.size # 6 shares per row if possible
        end

        def deal_to_ipo_row(row)
          @ipo_rows[row] = @deck.pop(cards_to_deal)
          @ipo_rows[row].each do |company|
            company.ipo_row_index = row
          end
        end

        def game_tiles
          TILES.dup.merge!({
                             'X' =>
                                 {
                                   'count' => 4,
                                   'color' => 'brown',
                                   'code' => '',
                                 },
                           })
        end

        # 1862 solo does not have any parliament rounds
        def next_round!
          @skip_round.clear
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                if @lner_triggered
                  @lner_triggered = false
                  form_lner
                end
                new_stock_round
              end
            else
              raise "round class #{@round.class} not handled"
            end
        end

        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        def stock_round
          G1862Solo::Round::Stock.new(self, [
            G1862::Step::BuyTokens,
            G1862::Step::ForcedSales,
            G1862Solo::Step::BuySellParShares,
          ])
        end

        def show_ipo_rows?
          true
        end

        def in_ipo?(company)
          @ipo_rows.flatten.include?(company)
        end

        def ipo_row_and_index(company)
          all_rows_indexes.each do |row|
            index = @ipo_rows[row].index(company)
            return [row, index] if index
          end
          nil
        end

        def ipo_remove(row, company)
          @ipo_rows[row].delete(company)
        end

        def buyable_bank_owned_companies
          []
        end

        def init_corporations(_stock_market)
          self.class::CORPORATIONS.map do |corporation|
            corporation[:float_percent] = 30
            corporation[:shares] = [10, 10, 10, 10, 10, 10, 10]
            corporation[:max_ownership_percent] = 70
            corporation[:min_price] = 1
            initiated_corp = G1862Solo::Corporation.new(
              **corporation.merge(corporation_opts),
            )
            initiated_corp.forced_share_percent = 10
            initiated_corp
          end
        end

        # So that value is not shown on company cards representing shares
        def company_value(_company)
          1
        end

        def company_header(_company)
          '10% SHARE'
        end

        def show_value_of_companies?(_owner)
          true
        end

        def company_revenue_str(_company)
          '0'
        end

        # Timeline information for INFO tab
        def timeline
          timeline = []

          all_rows_indexes.each do |i|
            ipo_row_i = ipo_timeline(i)
            timeline << "IPO ROW #{i + 1}: #{ipo_row_i.join(', ')}" unless ipo_row_i.empty?
          end

          timeline
        end

        def ipo_timeline(index)
          row = @ipo_rows[index]
          row.map do |company|
            company.name.to_s
          end
        end

        def all_rows_indexes
          (0..8)
        end
      end
    end
  end
end
