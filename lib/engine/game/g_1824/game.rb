# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'corporation'
require_relative 'depot'
require_relative 'entities'
require_relative 'map'
require_relative 'minor'

module Engine
  module Game
    module G1824
      class Game < Game::Base
        include_meta(G1824::Meta)
        include G1824::Entities
        include G1824::Map

        attr_accessor :two_train_bought, :forced_mountain_railway_exchange, :coal_railways_to_draft

        register_colors(
          gray70: '#B3B3B3',
          gray50: '#7F7F7F'
        )

        CURRENCY_FORMAT_STR = '%dG'

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 14, 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 680, 3 => 820, 4 => 680, 5 => 560, 6 => 460 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[100
             110
             120
             130
             140
             155
             170
             190
             210
             235
             260
             290
             320
             350],
          %w[90
             100
             110
             120
             130
             145
             160
             180
             200
             225
             250
             280
             310
             340],
          %w[80
             90
             100p
             110
             120
             135
             150
             170
             190
             215
             240
             270
             300
             330],
          %w[70 80 90p 100 110 125 140 160 180 200 220],
          %w[60 70 80p 90 100 115 130 150 170],
          %w[50 60 70p 80 90 105 120],
          %w[40 50x 60p 70 80],
        ].freeze

        MARKET_TEXT = {
          par: 'Par values',
          par_1: 'Par value for Construction Railway (2 player)',
        }.freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :red,
          par_1: :orange
        ).freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 4 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains
                       may_exchange_coal_railways
                       may_exchange_mountain_railways],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { PreStaatsbahn: 2, Coal: 2, Regional: 3 },
            tiles: %i[yellow green],
            status: %w[can_buy_trains may_exchange_coal_railways],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { PreStaatsbahn: 2, Regional: 3, Staatsbahn: 4 },
            tiles: %i[yellow green brown],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown gray],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10',
            train_limit: { Regional: 2, Staatsbahn: 3 },
            tiles: %i[yellow green brown gray],
            status: ['can_buy_trains'],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, num: 9, price: 80, rusts_on: '4' },
                  {
                    name: '1g',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 6,
                    price: 120,
                    available_on: '2',
                    rusts_on: '3g',
                  },
                  {
                    name: '3',
                    distance: 3,
                    num: 7,
                    price: 180,
                    rusts_on: '6',
                    discount: { '2' => 40 },
                  },
                  {
                    name: '2g',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 5,
                    price: 240,
                    available_on: '3',
                    rusts_on: '4g',
                    discount: { '1g' => 60 },
                  },
                  {
                    name: '4',
                    distance: 4,
                    num: 4,
                    price: 300,
                    rusts_on: '8',
                    events: [{ 'type' => 'close_mountain_railways' }, { 'type' => 'sd_formation' }],
                    discount: { '3' => 90 },
                  },
                  {
                    name: '3g',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 4,
                    price: 360,
                    available_on: '4',
                    rusts_on: '5g',
                    discount: { '2g' => 120 },
                  },
                  {
                    name: '5',
                    distance: 5,
                    num: 3,
                    price: 450,
                    rusts_on: '10',
                    events: [{ 'type' => 'close_coal_railways' }],
                    discount: { '4' => 140 },
                  },
                  {
                    name: '6',
                    distance: 6,
                    num: 3,
                    price: 630,
                    events: [],
                    discount: { '5' => 200 },
                  },
                  {
                    name: '4g',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 3,
                    price: 600,
                    available_on: '6',
                    discount: { '3g' => 180 },
                  },
                  { name: '8', distance: 8, num: 3, price: 800, discount: { '6' => 300 } },
                  {
                    name: '5g',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    num: 2,
                    price: 800,
                    available_on: '8',
                    discount: { '4g' => 300 },
                  },
                  { name: '10', distance: 10, num: 20, price: 950, discount: { '8' => 400 } }].freeze

        TRAIN_NUMS_2_PLAYERS_CISLETHANIA = { '2' => 6,
                                             '1g' => 3,
                                             '3' => 5,
                                             '2g' => 2,
                                             '4' => 4,
                                             '3g' => 2,
                                             '5' => 2,
                                             '6' => 2,
                                             '4g' => 1,
                                             '8' => 1,
                                             '5g' => 2,
                                             '10' => 20 }.freeze
        TRAIN_NUMS_3_PLAYERS_CISLETHANIA = { '2' => 8,
                                             '1g' => 5,
                                             '3' => 6,
                                             '2g' => 4,
                                             '4' => 4,
                                             '3g' => 3,
                                             '5' => 3,
                                             '6' => 3,
                                             '4g' => 1,
                                             '8' => 2,
                                             '5g' => 2,
                                             '10' => 20 }.freeze
  
        GAME_END_CHECK = { bank: :full_or }.freeze

        # Move down one step for a whole block, not per share
        SELL_MOVEMENT = :down_block

        # Cannot sell until operated
        SELL_AFTER = :operate

        # Sell zero or more, then Buy zero or one
        SELL_BUY_ORDER = :sell_buy

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'close_mountain_railways' => ['Mountain railways closed', 'Any still open Montain railways are exchanged'],
          'sd_formation' => ['SD formation', 'The Suedbahn is founded at the end of the OR'],
          'close_coal_railways' => ['Coal railways closed', 'Any still open Coal railways are exchanged'],
          'ug_formation' => ['UG formation', 'The Ungarische Staatsbahn is founded at the end of the OR'],
          'kk_formation' => ['k&k formation', 'k&k Staatsbahn is founded at the end of the OR'],
          'close_construction_railways' => ['Construction railways close', 'The two construction railways close.'],
        ).freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_trains' => ['Can Buy trains', 'Can buy trains from other corporations'],
          'may_exchange_coal_railways' => ['Coal Railway exchange', 'May exchange Coal Railways during SR'],
          'may_exchange_mountain_railways' => ['Mountain Railway exchange', 'May exchange Mountain Railways during SR']
        ).freeze

        CERT_LIMIT_CISLEITHANIA = { 2 => 14, 3 => 16 }.freeze

        BANK_CASH_CISLEITHANIA = { 2 => 4000, 3 => 9000 }.freeze

        CASH_CISLEITHANIA = { 2 => 830, 3 => 680 }.freeze

        MOUNTAIN_RAILWAY_NAMES = {
          1 => 'Semmeringbahn',
          2 => 'Kastbahn',
          3 => 'Brennerbahn',
          4 => 'Arlbergbahn',
          5 => 'Karawankenbahn',
          6 => 'Wocheinerbahn',
        }.freeze

        MINE_HEX_NAMES = %w[C6 A12 A22 H25].freeze
        MINE_HEX_NAMES_CISLEITHANIA = %w[C6 A12 A22 H25].freeze

        def init_optional_rules(optional_rules)
          opt_rules = super

          # 2 player variant always use the Cisleithania map
          opt_rules << :cisleithania if two_player? && !opt_rules.include?(:cisleithania)

          # Good Time variant is not applicable if Cisleithania is used
          opt_rules -= [:goods_time] if opt_rules.include?(:cisleithania)

          opt_rules
        end

        def init_share_pool
          G1824::SharePool.new(self)
        end

        def init_bank
          return super unless option_cisleithania

          Engine::Bank.new(BANK_CASH_CISLEITHANIA[@players.size], log: @log)
        end

        def init_starting_cash(players, bank)
          return super unless option_cisleithania

          players.each do |player|
            bank.spend(CASH_CISLEITHANIA[@players.size], player)
          end
        end

        def init_train_handler
          trains = self.class::TRAINS.flat_map do |train|
            Array.new((num_trains(train))) do |index|
              Train.new(**train, index: index)
            end
          end

          depot = G1824::Depot.new(trains, self)

          # Need to add events that are depending on player count

          if two_player?
            # First 4 or 5 train wwill close all construction railways.
            # It depends if which pre-staatbahn used.

            train = depot.upcoming.find { |t| t.name == '4' }
            train.events << { 'type' => 'close_construction_railways' }

            train = depot.upcoming.find { |t| t.name == '5' }
            train.events << { 'type' => 'kk_formation' }

          else

            train = depot.upcoming.find { |t| t.name == '5' }
            train.events << { 'type' => 'ug_formation' }

            train = depot.upcoming.find { |t| t.name == '6' }
            train.events << { 'type' => 'kk_formation' }

          end

          depot
        end

        def num_trains(train)
          return train[:num] unless option_cisleithania

          train_nums = two_player? ? TRAIN_NUMS_2_PLAYERS_CISLETHANIA : TRAIN_NUMS_3_PLAYERS_CISLETHANIA

          train_nums[train[:name]]
        end

        def init_corporations(stock_market)
          corporations = CORPORATIONS.dup

          corporations.map! do |c|
            if c['sym'] == @bond_railway_id
              # The Regional that is connected to construction railway are
              # tranformed in a Bond certificate (with a 20% bond, 8 10% bonds)
              c['type'] = 'Bond Railway'
              c['max_ownership_percent'] = 100
              c['always_market_price'] = true
              c['float_percent'] = 0
              c['tokens'] = [0, 0, 0]
              min_price = 50
            else
              min_price = stock_market.par_prices.map(&:price).min
            end

            G1824::Corporation.new(
              min_price: min_price,
              capitalization: self.class::CAPITALIZATION,
              **c.merge(corporation_opts),
            )
          end

          if option_cisleithania
            # Some corporations need to be removed, but they need to exists (for implementation reasons)
            # So set them as closed and removed so that they do not appear
            # Affected: Regional Railway BH and SB, and possibly UG
            corporations.each do |c|
              if %w[SB BH].include?(c.name) || (two_player? && c.name == 'UG')
                c.close!
                c.removed = true
              end
            end
            selection = corporations.reject { |c| c.removed }
            @log << "Available Corporations: #{selection.map(&:name).sort.join(', ')}"
            corporations = selection
          end

          corporations
        end

        def init_minors
          minors = MINORS.dup

          if option_cisleithania
            if two_player?
              # Remove Pre-Staatsbahn U1 and U2, and minor SPB
              minors.reject! { |m| %w[U1 U2 SPB].include?(m[:sym]) }
            else
              # Remove Pre-Staatsbahn U2, minor SPB, and move home location for U1
              minors.reject! { |m| %w[U2 SPB].include?(m[:sym]) }
              minors.map! do |m|
                next m unless m['sym'] == 'U1'

                m['coordinates'] = 'G12'
                m['city'] = 0
                m
              end
            end
          end

          minors.map { |minor| G1824::Minor.new(**minor) }
        end

        def show_available(type, source)
          selection = source.select { |s| s[:type] == type }
          @log << "Available #{type}s: #{selection.map { |s| s[:sym] }.sort.join(', ')}"
        end

        def init_companies(players)
          companies = COMPANIES.dup

          mountain_railway_count =
            case players.size
            when 2
              2
            when 3
              option_cisleithania ? 3 : 4
            when 4, 5
              6
            when 6
              4
            end
          mountain_railway_count.times { |index| companies << mountain_railway_definition(index) }

          if option_cisleithania
            # Remove Coal minor C4 (SPB), Pre-Staatsbahn U2 and possibly U1
            companies.reject! { |c| %w[U2 SPB].include?(c[:sym]) || (two_player? && c['sym'] == 'U1') }
            show_available('Mountain Railway', companies)
            show_available('PreStaatsbahn', companies)
            show_available('Coal Railway', companies)

            if two_player?
              pre_staat_candidates = %w[K2 S2 S3]
              pre_staat_selected = pre_staat_candidates[rand % pre_staat_candidates.size]
              coal_railway_candidates = %w[EOD EPP MLB]
              coal_railway_selected = coal_railway_candidates[rand % coal_railway_candidates.size]
              @bond_railway_id =
                case coal_railway_selected
                when 'EOD'
                  'MS'
                when 'EPP'
                  'BK'
                when 'MLB'
                  'CL'
                end
              selected_stack_1 = [pre_staat_selected, coal_railway_selected]
              companies.each do |c|
                sym = c[:sym]
                if selected_stack_1.include?(sym)
                  c[:stack] = 1
                elsif %w[S1 K1].include?(sym)
                  c[:stack] = 2
                elsif c[:type] == 'PreStaatsbahn'
                  c[:stack] = 3
                elsif c[:type] == 'Coal Railway'
                  c[:stack] = 4
                end
              end
            end
          end

          companies.map { |company| G1824::Company.new(**company) }
        end

        def init_tiles
          tiles = TILES.dup

          if option_goods_time
            # Goods Time increase count for some town related tiles
            tiles['3'] += 3
            tiles['4'] += 3
            tiles['56'] += 1
            tiles['58'] += 3
            tiles['87'] += 2
            tiles['630'] += 1
            tiles['631'] += 1

            # New tile for Goods Time variant
            tiles['204'] = 3
          end

          tiles.flat_map do |name, val|
            init_tile(name, val)
          end
        end

        def option_cisleithania
          @optional_rules&.include?(:cisleithania)
        end

        def option_goods_time
          @optional_rules&.include?(:goods_time)
        end

        def game_cert_limit
          return super unless option_cisleithania

          CERT_LIMIT
        end

        def num_certs(entity)
          puts "Num certs for #{entity}"
          result = super + @minors.count { |m| !m.closed? && m.owner == entity }
          puts "Got #{result}"
          result
        end

        # President share of the Bond railway (used in 2 players) is buyable/sellablecorporation
        def bundles_for_corporation(player, corporation)
          return super unless bond_railway?(corporation)

          # Handle bundles with half shares and non-half shares separately.
          president_shares, regular_shares = player.shares_of(corporation).partition { |s| s.percent > 10 }

          # # Need only one bundle with half shares. Player will have to sell twice if s/he want to sell both.
          # # This is to simplify other implementation - only handle sell bundles with one half share.
          # half_shares = [half_shares.first] if half_shares.any?

          regular_bundles = super(player, corporation, shares: regular_shares)
          puts "regular bundles: #{regular_bundles}"
          president_bundles = super(player, corporation, shares: president_shares)
          puts "president bundles: #{president_bundles}"
          regular_bundles.concat(president_bundles)
        end

        def can_buy_presidents_share_directly_from_market?(corporation)
          return super unless bond_railway?(corporation)

          true
        end

        def location_name(coord)
          return super unless option_cisleithania

          unless @location_names
            @location_names = LOCATION_NAMES.dup
            @location_names['F25'] = 'Kronstadt'
            @location_names['G12'] = 'Budapest'
            @location_names['I10'] = 'Bosnien'
          end
          @location_names[coord]
        end

        def optional_hexes
          option_cisleithania ? cisleithania_map : base_map
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G1824::Step::ForcedMountainRailwayExchange,
            G1824::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1824::Step::Dividend,
            G1824::Step::BuyTrain,
          ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when G1824::Round::DraftStacks2p
              draft_coal_railways_round
            when G1824::Round::DraftCoalRailways2p
              draft_mountain_railways_round
            when G1824::Round::DraftMountainRailways2p
              @turn = 1
              initial_stock_round
            else
              super
            end

          @round
        end

        def init_round
          two_player? ? initial_draft_round : initial_stock_round
        end

        def initial_draft_round
          @log << '-- Draft Stacks Round --'
          draft_step = G1824::Step::DraftStacks2p
          G1824::Round::DraftStacks2p.new(self, [draft_step], snake_order: true)
        end

        def draft_coal_railways_round
          @log << '-- Draft Coal Railways Round --'
          draft_step = G1824::Step::DraftCoalRailways2p
          G1824::Round::DraftCoalRailways2p.new(self, [draft_step])
        end

        def draft_mountain_railways_round
          @log << '-- Draft Mountain Railways Round --'
          draft_step = G1824::Step::DraftMountainRailways2p
          G1824::Round::DraftMountainRailways2p.new(self, [draft_step], snake_order: true)
        end

        def initial_stock_round
          @log << '-- First Stock Round --'
          @log << 'Player order is reversed during the first turn' unless two_player?
          G1824::Round::FirstStock.new(self, [
            G1824::Step::BuySellParSharesFirstSr,
            ])
        end

        def buy_coal_railway_round
          G1824::Round::BuyCoalRailway2p.new(self, [G1824::Step::DraftCoalRailways2p])
        end

        def buy_mountain_railway_round
          G1824::Round::BuyMountainRailway2p.new(self, [G1824::Step::DraftMountainRailways2p])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1824::Step::BuySellParExchangeShares,
          ])
        end

        def round_description(name, _round_num = nil)
          return "Draft Coal Railways Round" if name == "DraftCoalRailways2p"
          return "Draft Mountain Railways Round" if name == "DraftMountainRailways2p"
          return "Draft Stacks Round" if name == "DraftStacks2p"
          return "First Stock Round" if name == "FirstStock"

          super
        end

        def or_set_finished
          depot.export!
        end

        def coal_c1
          @c1 ||= minor_by_id('EPP')
        end

        def coal_c2
          @c2 ||= minor_by_id('EOD')
        end

        def coal_c3
          @c3 ||= minor_by_id('MLB')
        end

        def coal_c4
          @c4 ||= minor_by_id('SPB')
        end

        def regional_bk
          @bk ||= corporation_by_id('BK')
        end

        def regional_ms
          @ms ||= corporation_by_id('MS')
        end

        def regional_cl
          @cl ||= corporation_by_id('CL')
        end

        def regional_sb
          @sb ||= corporation_by_id('SB')
        end

        def state_sd
          @sd ||= corporation_by_id('SD')
        end

        def state_ug
          @ug ||= corporation_by_id('UG')
        end

        def state_kk
          @kk ||= corporation_by_id('KK')
        end

        def pre_state_k2
          @k2 ||= company_by_id('K2')
        end

        def bond_railway
          @bond_railway ||= corporation_by_id(@bond_railway_id)
        end

        def setup
          puts "SETUP"
          @two_train_bought = false
          @forced_mountain_railway_exchange = []
          @coal_railways_to_draft = []

          kk_corporation_company = two_player? && @companies.any? { |c| c == pre_state_k2 && c.stack == 1 }

          @companies.each do |c|
            c.owner = @bank
            @bank.companies << c

            # For 2 player, the two minors in stack 1 are construction railways
            make_connected_minor_construction_railway(c, kk_corporation_company) if c.stack == 1
          end

          @minors.each do |minor|
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[minor.city].place_token(minor, minor.next_token)
          end

          # Reserve the presidency share to have it as exchange for associated coal railway
          @corporations.each do |c|
            next if two_player? && bond_railway?(c)
            next if !regional?(c) && !staatsbahn?(c)
            next if c.id == 'BH'

            c.shares.find(&:president).buyable = false
            c.floatable = false
          end

          if two_player?
            bond_railway.shares.each do |s|
              @share_pool.transfer_shares(s.to_bundle, @share_pool, price: 0, allow_president_change: false)
            end
            bond_price = @stock_market.par_prices.find { |p| p.price == 50 }
            @stock_market.set_par(bond_railway, bond_price)
            bond_railway.ipoed = true
            bond_railway.owner = @share_pool
            after_par(bond_railway) # Not clear this is needed
  
            @log << "Bond railway #{bond_railway.id} is floated, and has 9 certificates in the market, one 20%."
          end
        end

        def timeline
          @timeline ||= ['At the end of each OR set, the cheapest train in bank is exported.'].freeze
        end

        def status_str(entity)
          if construction_railway?(entity)
            'Construction Railway'
          elsif bond_railway?(entity)
            'Bond Railway'
          elsif coal_railway?(entity)
            'Coal Railway - may only own g trains'
          elsif pre_staatsbahn?(entity)
            'Pre-Staatsbahn'
          elsif staatsbahn?(entity)
            'Staatsbahn'
          elsif regional?(entity)
            str = 'Regional Railway'
            puts "Get associated coal railway for entity #{entity}"
            if (regional = associated_coal_railway(entity)) && !regional.closed?
              str += " - Presidency reserved (#{regional.name}), no float until exchanged"
            end
            str
          end
        end

        def can_par?(corporation, parrer)
          super && buyable?(corporation) && !reserved_regional(corporation)
        end

        def g_train?(train)
          train.name.end_with?('g')
        end

        def mountain_railway?(entity)
          entity.company? && entity.sym.start_with?('B')
        end

        def mountain_railway_exchangable?
          @phase.status.include?('may_exchange_mountain_railways')
        end

        def coal_railway?(entity)
          return entity.type == :Coal if entity.minor?

          entity.company? && associated_regional_railway(entity)
        end

        def coal_railway_exchangable?
          @phase.status.include?('may_exchange_coal_railways')
        end

        def construction_railway?(entity)
          two_player? && abilities(entity, :tile_discount) { |_| return true }

          false
        end

        def bond_railway?(entity)
          two_player? && entity == bond_railway
        end

        def pre_staatsbahn?(entity)
          entity.minor? && entity.type == :PreStaatsbahn
        end

        def regional?(entity)
          entity.corporation? && entity.type == :Regional
        end

        def staatsbahn?(entity)
          entity.corporation? && entity.type == :Staatsbahn
        end

        def reserved_regional(entity)
          return false unless regional?(entity)

          president_share = entity.shares.find(&:president)
          president_share && !president_share.buyable
        end

        def buyable?(entity)
          return true unless entity.corporation?
          return true if bond_railway?(entity.corporation)

          entity.all_abilities.none? { |a| a.type == :no_buy }
        end

        def corporation_available?(entity)
          buyable?(entity)
        end

        def exchange_corporations(exchange_ability)
          puts "EXCHANGE CORPORATIONS!!: #{exchange_ability.corporations}"
          candidates = exchange_ability.corporations.map { |c| corporation_by_id(c) }.compact
          puts "Candidates: #{candidates.map(&:name)}}"
          candidates.reject(&:closed?)
        end
  
        def entity_can_use_company?(_entity, _company)
          # Return false here so that Exchange abilities does not appear in GUI
          false
        end

        def sorted_corporations
          sorted_corporations = super
          return sorted_corporations unless @turn == 1

          # Remove unbuyable stuff in SR 1 to reduce information
          sorted_corporations.select { |c| buyable?(c) }
        end

        def associated_regional_railway(coal_railway)
          key = coal_railway.minor? ? coal_railway.name : coal_railway.id
          case key
          when 'EPP'
            regional_bk
          when 'EOD'
            regional_ms
          when 'MLB'
            regional_cl
          when 'SPB'
            regional_sb
          end
        end

        def associated_coal_railway(regional_railway)
          case regional_railway.name
          when 'BK'
            coal_c1
          when 'MS'
            coal_c2
          when 'CL'
            coal_c3
          when 'SB'
            coal_c4
          end
        end

        def associated_state_railway(prestate_railway)
          case prestate_railway.id
          when 'S1', 'S2', 'S3'
            state_sd
          when 'U1', 'U2'
            state_ug
          when 'K1', 'K2'
            state_kk
          end
        end

        def revenue_for(route, stops)
          # Ensure only g-trains visit mines, and that g-trains visit exactly one mine
          mine_visits = route.hexes.count { |h| mine_hex?(h) }

          raise GameError, 'Exactly one mine need to be visited' if g_train?(route.train) && mine_visits != 1
          raise GameError, 'Only g-trains may visit mines' if !g_train?(route.train) && mine_visits.positive?

          super
        end

        def mine_revenue(routes)
          routes.sum { |r| r.stops.sum { |stop| mine_hex?(stop.hex) ? stop.route_revenue(r.phase, r.train) : 0 } }
        end

        def float_str(entity)
          return 'Bond Railway' if bond_railway?(entity)
          return super if !entity.corporation || entity.floatable

          case entity.id
          when 'BK', 'MS', 'CL', 'SB'
            needed = entity.percent_to_float
            needed.positive? ? "#{entity.percent_to_float}% to float" : 'Exchange to float'
          when 'UG'
            'U1 exchange floats'
          when 'KK'
            'K1 exchange floats'
          when 'SD'
            'S1 exchange floats'
          else
            'Not floatable'
          end
        end

        def all_corporations
          @corporations.reject(&:removed)
        end

        def event_close_mountain_railways!
          @log << '-- Any remaining Mountain Railways are either exchanged or discarded'
          puts "Close MR"
          # If this list contains any companies it will trigger an interrupt exchange/pass step
          @forced_mountain_railway_exchange = @companies.select { |c| mountain_railway?(c) && !c.closed? }
        end

        def event_close_coal_railways!
          @log << '-- Exchange any remaining Coal Railway'
          puts "Close CR"
          @companies.select { |c| coal_railway?(c) }.reject(&:closed?).each do |coal_railway_company|
            exchange_coal_railway(coal_railway_company)
          end
        end

        def event_sd_formation!
          @log << 'SD formation not yet implemented'
        end

        def event_ug_formation!
          @log << 'UG formation not yet implemented'
        end

        def event_kk_formation!
          @log << 'KK formation not yet implemented'
        end

        def exchange_coal_railway(company)
          player = company.owner
          minor = minor_by_id(company.id)
          regional = associated_regional_railway(company)

          @log << "#{player.name} receives presidency of #{regional.name} in exchange for #{minor.name}"
          company.close!

          # Transfer Coal Railway cash and trains to Regional. Remove CR token.
          if minor.cash.positive?
            @log << "#{regional.name} receives the #{minor.name} treasury of #{format_currency(minor.cash)}"
            minor.spend(minor.cash, regional)
          end
          unless minor.trains.empty?
            transferred = transfer(:trains, minor, regional)
            @log << "#{regional.name} receives the trains: #{transferred.map(&:name).join(', ')}"
          end
          minor.tokens.first.remove!
          minor.close!

          # Handle Regional presidency, possibly transfering to another player in case they own more in the regional
          presidency_share = regional.shares.find(&:president)
          presidency_share.buyable = true
          regional.floatable = true
          @share_pool.transfer_shares(
            presidency_share.to_bundle,
            player,
            allow_president_change: false,
            price: 0
          )

          # Give presidency to majority owner (with minor owner priority if that player is one of them)
          max_shares = @share_pool.presidency_check_shares(regional).values.max
          majority_share_holders = @share_pool.presidency_check_shares(regional).select { |_, p| p == max_shares }.keys
          if !majority_share_holders.find { |owner| owner == player }
            # FIXME: Handle the case where multiple share the presidency criteria
            new_president = majority_share_holders.first
            @share_pool.change_president(presidency_share, player, new_president, player)
            regional.owner = new_president
            @log << "#{new_president.name} becomes president of #{regional.name} as majority owner"
          else
            regional.owner = player
          end

          float_corporation(regional) if regional.floated?
          regional
        end

        def float_corporation(corporation)
          @log << "#{corporation.name} floats"

          return if corporation.capitalization == :incremental

          floating_capital = case corporation.name
                             when 'BK', 'MS', 'CL', 'SB'
                               corporation.par_price.price * 8
                             else
                               corporation.par_price.price * corporation.total_shares
                             end

          @bank.spend(floating_capital, corporation)
          @log << "#{corporation.name} receives floating capital of #{format_currency(floating_capital)}"
        end

        def connected_minor(company)
          minor_by_id(company.id)
        end

        private

        def mine_hex?(hex)
          option_cisleithania ? MINE_HEX_NAMES_CISLEITHANIA.include?(hex.name) : MINE_HEX_NAMES.include?(hex.name)
        end

        MOUNTAIN_RAILWAY_DEFINITION = {
          sym: 'B%1$d',
          name: 'B%1$d %2$s',
          type: 'Mountain Railway',
          value: 120,
          revenue: 25,
          desc: 'Moutain railway (B%1$d). Cannot be sold but can be exchanged for a 10 percent share in a '\
                'regional railway during phase 3 SR, or when first 4 train is bought. '\
                'If no regional railway shares are available from IPO this private is lost without compensation.',
          abilities: [
            {
              type: 'no_buy',
              owner_type: 'player',
            },
            {
              type: 'exchange',
              corporations: %w[BK MS CL SB BH],
              owner_type: 'player',
              from: %w[ipo market],
            },
          ],
        }.freeze

        def mountain_railway_definition(index)
          real_index = index + 1
          definition = MOUNTAIN_RAILWAY_DEFINITION.dup
          definition[:sym] = format(definition[:sym], real_index)
          definition[:name] = format(definition[:name], real_index, MOUNTAIN_RAILWAY_NAMES[real_index])
          definition[:desc] = format(definition[:desc], real_index)
          definition
        end

        def make_connected_minor_construction_railway(company, kk_is_corporation_company)
          close_train = kk_is_corporation_company ? '5' : '4'
          company.value = 120
          company.desc =
            'This is a Construction Railway. It does not use any trains and do not have any treasury. '\
            'During its OR turn the owner may lay or upgrade track according to the normal rules but '\
            'any terrain costs are ignored. The Construction Corporation cannot be sold, does not pay '\
            "any revenue, and when the first #{ close_train } train is bought "\
            'it is closed without any compensationis. It pays no revenue.'

          minor = connected_minor(company)

          # Remove previous abilities
          minor.all_abilities.dup.each { |ab| minor.remove_ability(ab) }

          # Add free tile laying ability to minor
          ability = Engine::Ability::TileDiscount.new(
            type: 'tile_discount',
            discount: 40,
            description: 'Construction railway',
            desc_detail: 'No treasury. Lay tiles without terrain cost.')
          minor.add_ability(ability)

          # Do not buy trains
          ability = Engine::Ability::Base.new(
            type: 'no_train_buy',
            description: 'Trainless',
            desc_detail: 'Does not need, buy or use trains.')
          minor.add_ability(ability)

          # No buy-ins
          ability = Engine::Ability::Base.new(
            type: 'no_buy',
            description: "First #{close_train}-train bought: Closed",
            desc_detail: 'No compensation.')
          minor.add_ability(ability)
        end
      end
    end
  end
end
