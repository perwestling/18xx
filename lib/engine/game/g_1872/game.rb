# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'step/draft_distribution'
require_relative 'step/buy_company'
require_relative '../../step/company_pending_par'

module Engine
  module Game
    module G1872
      class Game < Game::Base
        include_meta(G1872::Meta)

        register_colors(green: '#237333',
                        red: '#d81e3e',
                        blue: '#0189d1',
                        # lightBlue: '#a2dced',
                        yellow: '#FFF500',
                        orange: '#f48221',
                        brown: '#7b352a')

        TRACK_RESTRICTION = :permissive
        CURRENCY_FORMAT_STR = '¥%d'
        BANK_CASH = 6000
        CERT_LIMIT = { 2 => 24, 3 => 16, 4 => 12 }.freeze
        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 520 }.freeze
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[80 85 90 100 110 125 140 160 180 200 225 250 275 300 325 350 375],
          %w[75 80 85 90 100 110 125 140 160 180 200 225 250 275 300 325 350],
          %w[70 75 80 85 95p 105 115 130 145 160 180 200],
          %w[65 70 75 80p 85 95 105 115 130 145],
          %w[60 65 70p 75 80 85 95 105],
          %w[55 60 65 70 75 80],
          %w[50 55 60 65],
          %w[40 45],
        ].freeze

        TILES = {
          '3' => 3,
          '4' => 3,
          '5' => 3,
          '6' => 3,
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 3,
          '15' => 3,
          '23' => 2,
          '24' => 2,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 3,
          '58' => 4,
          '70' => 1,
          '87' => 1,
          '88' => 1,
          '201' => 2,
          '202' => 2,
          '204' => 2,
          '207' => 2,
          '208' => 2,
          '611' => 3,
          '619' => 3,
          '621' => 2,
          '622' => 2,
          '915' => 1,
          'X1' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5;label=OO',
          },
          'X2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },
          'X3' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:_0,b:5;path=a:0,b:_1;path=a:_1,b:4;label=OO',
          },
          'X4' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;path=a:4,b:_0;label=OO',
          },
          'X5' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' =>
              'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
              'path=a:4,b:_0;label=Y',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO',
          },
          'X7' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Y',
          },
        }.freeze

        LOCATION_NAMES = {
          'A9' => 'Chūgoku',
          'A15' => 'Shikoku',
          'B8' => 'Maizuru',
          'B14' => 'Kobe',
          'B16' => 'Ōsaka-wan',
          'C13' => 'Ōsaka',
          'C15' => 'Sakai',
          'D10' => 'Kyōto',
          'D12' => 'Nara',
          'E7' => 'Tsuruga',
          'F4' => 'Nihon-kai',
          'F6' => 'Kanazawa',
          'F12' => 'Nagoya',
          'F14' => 'Tsu',
          'G5' => 'Toyama',
          'G7' => 'Takayama',
          'G13' => 'Hamamatsu',
          'H12' => 'Shizuoka',
          'I5' => 'Matsumoto',
          'I9' => 'Saitama',
          'I11' => 'Yokohama',
          'J4' => 'Nagano',
          'J8' => 'Takasaki',
          'J10' => 'Tōkyō',
          'J12' => 'Tōkyō-wan',
          'K1' => 'Niigata',
          'K9' => 'Tsukuba',
          'K11' => 'Chiba',
          'L6' => 'Koriyama',
          'M3' => 'Aomori',
          'M5' => 'Sendai',
        }

        HEXES = {
          white: {
            %w[C11 D14 D16 E11 E13 G11 H10 K7] => '',
            %w[B10 B12 C9 D8 E15 F8 F10 G9 H4 H6 H8 I3 I7 J2 J6 K3 K5 L4] => 'upgrade=cost:40,terrain:mountain',
            %w[B8 D12 F14 I5 I9 J8 K9 K11 L6] => 'town=revenue:0',
            %w[G7] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            %w[B14 F6 G5 I11 M5] => 'city=revenue:0',
            %w[D10 F12] => 'city=revenue:0;label=Y',
          },
          red: {
            ['A9'] =>
              'offboard=revenue:yellow_20|brown_30|gray_60,groups:Chuugoku;path=a:4,b:_0;path=a:5,b:_0;border=edge:3;border=edge:0',
            ['A11'] =>
              'offboard=revenue:yellow_20|brown_30|gray_60,hide:1,groups:Chuugoku;path=a:4,b:_0;path=a:5,b:_0;border=edge:0',
            ['A15'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:4,b:_0',
            ['K1'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:0,b:_0;path=a:1,b:_0',
            ['M3'] =>
              'offboard=revenue:yellow_20|brown_30|gray_60;path=a:0,b:_0;path=a:1,b:_0',
          },
          gray: {
            ['A13'] => 'path=a:5,b:4',
            ['C15'] => 'town=revenue:0;path=a:3,b:_0;path=a:_0,b:5',
            ['E7'] => 'town=revenue:0;path=a:1,b:_0;path=a:_0,b:4',
            ['G13'] => 'town=revenue:20;path=a:2,b:_0;path=a:_0,b:4',
            ['H12'] => 'town=revenue:20;path=a:1,b:_0;path=a:_0,b:4',
          },
          yellow: {
            %w[C13 J10] =>
              'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=OO',
            ['J4'] =>
              'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;label=Y',
            ['L8'] =>
              'path=a:1,b:4',
            ['M7'] =>
              'path=a:1,b:3',
          },
          blue: {
            ['E9'] => '',
            ['B16'] => 'offboard=revenue:yellow_20|brown_30|gray_60;path=a:3,b:_0',
            ['F4'] =>
              'offboard=revenue:yellow_20|brown_30|gray_40;path=a:0,b:_0;path=a:5,b:_0',
            ['J12'] =>
              'offboard=revenue:yellow_20|brown_40|gray_80;path=a:2,b:_0;path=a:3,b:_0',
          }
        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 6,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 5,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 4,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 630, num: 2 },
          {
            name: 'D',
            distance: 999,
            price: 900,
            num: 20,
            available_on: '6',
            discount: { '4' => 200, '5' => 200, '6' => 200 },
          },
        ].freeze

        COMPANIES = [
          {
            name: 'Kyōto-tetsudō',
            value: 20,
            revenue: 5,
            desc: 'No special ability. Blocks hex D10 while owned by a player.',
            sym: 'KYOTO',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: ['D10'] }],
            color: nil,
          },
          {
            name: 'Osakayama Tunnel',
            value: 40,
            revenue: 10,
            desc: 'Reduces, for the owning corporation, the cost of laying all mountain tiles by $20.',
            sym: 'TUNNEL',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Station Subsidy',
            value: 60,
            revenue: 10,
            desc: 'Provides an additional station marker to corporation that buys this private from a player, awarded at time of purchase, then closes.',
            sym: 'STATION',
            abilities: [
              {
                type: 'additional_token',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Sleeper Train',
            value: 80,
            revenue: 10,
            desc: 'Adds $10 per city (not town, port, or connection) visited by any one train of the owning corporation. Never closes once purchased by a corporation. Pays no other revenue to corporation.',
            sym: 'SLEEP',
            abilities: [{ type: 'close', on_phase: 'never', owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: 'Tetsudō-shō',
            value: 100,
            revenue: 0,
            desc: 'Purchasing player immediately takes a 10% share of the JGR. This does not close the private company. This private company has no other special ability.',
            sym: 'JGRSTOCK',
            abilities: [{ type: 'shares', shares: 'JGR_1' }],
            color: nil,
          },
          {
            name: 'Inoue Masaru',
            value: 200,
            revenue: 20,
            desc: 'This private closes when the associated corporation buys its first train. It cannot be bought by a corporation.',
            sym: 'INOUESAN',
            abilities: [{ type: 'shares', shares: 'random_president' },
                        { type: 'no_buy' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'SRC',
            name: "San'yō-tetsudō",
            logo: '1872/SRC',
            simple_logo: '1872/SRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'B14',
            color: '#ef8f2f',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'KRC',
            name: 'Kansai-tetsudō',
            logo: '1872/KRC',
            simple_logo: '1872/KRC.alt',
            tokens: [0, 40, 60],
            coordinates: 'C13',
            city: 1,
            color: '#2f7f2f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'ARC',
            name: 'Aichi-tetsudō',
            logo: '1872/ARC',
            simple_logo: '1872/ARC.alt',
            tokens: [0, 40, 60],
            coordinates: 'F12',
            color: '#2f2f9f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'JGR',
            name: 'Tetsudō-shō',
            logo: '1872/JGR',
            simple_logo: '1872/JGR.alt',
            tokens: [0, 40],
            coordinates: 'I11',
            color: '#ef2f2f',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'NRC',
            name: 'Nippon-tetsudō',
            logo: '1872/NRC',
            simple_logo: '1872/NRC.alt',
            tokens: [0, 40],
            coordinates: 'J10',
            city: 1,
            color: 'black',
            text_color: 'white',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SR',
            name: 'Shinano-tetsudō',
            logo: '1872/SR',
            simple_logo: '1872/SR.alt',
            tokens: [0, 40, 60, 80],
            coordinates: 'J4',
            color: '#efef4f',
            text_color: 'black',
            reservation_color: nil,
          },
        ].freeze

        LAYOUT = :flat

        def setup
          @reverse = true
          @d_train_exported
          inoue.add_ability(Ability::Close.new(
            type: :close,
            when: 'bought_train',
            corporation: abilities(inoue, :shares).shares.first.corporation.name,
          ))
        end

        def init_round
          Engine::Round::Draft.new(self,
                           [ Engine::Step::CompanyPendingPar, G1872::Step::DraftDistribution ],
                           snake_order: true)
        end

        def init_round_finished
          @companies.reject(&:owned_by_player?).sort_by(&:name).each do |company|
            company.close!
            @log << "#{company.name} is removed"
          end
          @draft_finished = true
        end

        SELL_BUY_ORDER = :sell_buy

        def sp_reorder_players
          current_order = @players.dup
          if @reverse
            @reverse = false
            @players.reverse!
          else
            @players.sort_by! { |p| [p.cash, current_order.index(p)] }
          end
          @log << "Priority order: #{@players.reject(&:bankrupt).map(&:name).join(', ')}"
        end

        def priority_deal_player
          # Don't move around priority deal marker; only changes when players are reordered at beginning of stock round
          players.first
        end

        def new_stock_round
          @log << "-- #{round_description('Stock')} --"
          sp_reorder_players
          stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            G1872::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [G1872::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def best_sleeper_route(routes)
          best = nil
          routes.routes.each do |r|
            if best.nil? || sleeper_bonus(r) > sleeper_bonus(best)
              best = r
            end
          end
          best
        end

        def sleeper_bonus(route)
          return 0 unless route # Autorouter gets unhappy when empty routes blow up
          stops = route.visited_stops.select { |s| s.is_a? Engine::Part::City }.length * 10
        end

        def revenue_for(route, stops)
          revenue = super
          if route.train.owner.companies.include?(sleeper_train) && route == best_sleeper_route(route)
            revenue += sleeper_bonus(best_sleeper_route(route))
          end
          revenue
        end

        def revenue_str(route)
          stops = route.stops
          stop_hexes = stops.map(&:hex)
          str = route.hexes.map do |h|
            stop_hexes.include?(h) ? h&.name : "(#{h&.name})"
          end.join('-')

          if route.train.owner.companies.include?(sleeper_train)
            str += ' + Sleeper Train' if route == best_sleeper_route(route)
          end

          str
        end

        def timeline
          @timeline = [
            'At the end of each set of ORs the next available train will be exported (removed, triggering phase change as if purchased, until phase D triggered)',
          ]
        end

        def inoue
          @sleeper_train ||= company_by_id('INOUESAN')
        end

        def sleeper_train
          @sleeper_train ||= company_by_id('SLEEP')
        end

        def or_set_finished
          return if @d_train_exported
          if depot.upcoming.first.name == 'D'
            @d_train_exported = true
          end
          depot.export!
        end
      end
    end
  end
end
