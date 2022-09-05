# frozen_string_literal: true

module Engine
  module Game
    module G1824
      module Entities
        COMPANIES = [
          {
            sym: 'EPP',
            name: 'C1 Eisenbahn Pilsen - Priesen',
            type: 'Coal Railway',
            value: 200,
            interval: [120, 140, 160, 180, 200],
            revenue: 0,
            desc: "Buyer take control of minor Coal Railway EPP (C1), which can be exchanged for the Director's "\
                  'certificate of Regional Railway BK during SRs in phase 3 or 4, or automatically when phase 5 starts. '\
                  'BK floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'EOD',
            name: 'C2 Eisenbahn Oderberg - Dombran',
            type: 'Coal Railway',
            value: 200,
            interval: [120, 140, 160, 180, 200],
            revenue: 0,
            desc: "Buyer take control of minor Coal Railway EOD (C2), which can be exchanged for the Director's "\
                  'certificate of Regional Railway MS during SRs in phase 3 or 4, or automatically when phase 5 starts. '\
                  'MS floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'MLB',
            name: 'C3 Mosty - Lemberg Bahn',
            type: 'Coal Railway',
            value: 200,
            interval: [120, 140, 160, 180, 200],
            revenue: 0,
            desc: "Buyer take control of minor Coal Railway MLB (C3), which can be exchanged for the Director's "\
                  'certificate of Regional Railway CL during SRs in phase 3 or 4, or automatically when phase 5 starts. '\
                  'CL floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'SPB',
            name: 'C4 Simeria-Petrosani Bahn',
            type: 'Coal Railway',
            value: 200,
            interval: [120, 140, 160, 180, 200],
            revenue: 0,
            desc: "Buyer take control of minor Coal Railway SPB (C4), which can be exchanged for the Director's "\
                  'certificate of Regional Railway SB during SRs in phase 3 or 4, or automatically when phase 5 starts. '\
                  'SB floats after exchange as soon as 50% or more are owned by players. This private cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'S1',
            name: 'S1 Wien-Gloggnitzer Eisenbahngesellschaft',
            type: 'PreStaatsbahn',
            value: 240,
            revenue: 0,
            desc: "Buyer take control of pre-staatsbahn S1, which will be exchanged for the Director's certificate "\
                  'of SD when the first 4 train is sold. Pre-Staatsbahnen starts in Wien (E12). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'S2',
            name: 'S2 Kärntner Bahn',
            type: 'PreStaatsbahn',
            value: 120,
            revenue: 0,
            desc: 'Buyer take control of pre-staatsbahn S2, which will be exchanged for a 10% share of SD when the '\
                  'first 4 train is sold. Pre-Staatsbahnen starts in Graz (G10). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'S3',
            name: 'S3 Nordtiroler Staatsbahn',
            type: 'PreStaatsbahn',
            value: 120,
            revenue: 0,
            desc: 'Buyer take control of pre-staatsbahn S3, which will be exchanged for a 10% share of SD when the '\
                  'first 4 train is sold. Pre-Staatsbahnen starts in Innsbruck (G4). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'U1',
            name: 'U1 Eisenbahn Pest - Waitzen',
            type: 'PreStaatsbahn',
            value: 240,
            revenue: 0,
            desc: "Buyer take control of pre-staatsbahn U1, which will be exchanged for the Director's certificate "\
                  'of UG when the first 5 train is sold. Pre-Staatsbahnen starts in Pest (F17) in base 1824 and in '\
                  'Budapest (G12) for 3 players on the Cislethania map. Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'U2',
            name: 'U2 Mohacs-Fünfkirchner Bahn',
            type: 'PreStaatsbahn',
            value: 120,
            revenue: 0,
            desc: 'Buyer take control of pre-staatsbahn U2, which will be exchanged for a 10% share of UG when the '\
                  'first 5 train is sold. Pre-Staatsbahnen starts in Fünfkirchen (H15). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'K1',
            name: 'K1 Kaiserin Elisabeth-Bahn',
            type: 'PreStaatsbahn',
            value: 240,
            revenue: 0,
            desc: "Buyer take control of pre-staatsbahn K1, which will be exchanged for the Director's certificate "\
                  'of KK when the first 6 train is sold. Pre-Staatsbahnen starts in Wien (E12). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
          {
            sym: 'K2',
            name: 'K2 Kaiser Franz Joseph-Bahn',
            type: 'PreStaatsbahn',
            value: 120,
            revenue: 0,
            desc: 'Buyer take control of pre-staatsbahn K2, which will be exchanged for a 10% share of KK when the '\
                  'first 6 train is sold. Pre-Staatsbahnen starts in Wien (E12). Cannot be sold.',
            abilities: [{ type: 'no_buy', owner_type: 'player' }],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 50,
            name: 'Böhmische Kommerzbahn',
            sym: 'BK',
            type: 'Regional',
            tokens: [0, 40, 60, 80],
            logo: '1824/BK',
            simple_logo: '1824/BK.alt',
            color: :blue,
            coordinates: 'B9',
            reservation_color: nil,
          },
          {
            name: 'Mährisch-Schlesische Eisenbahn',
            sym: 'MS',
            type: 'Regional',
            float_percent: 50,
            tokens: [0, 40, 60, 80],
            logo: '1824/MS',
            simple_logo: '1824/MS.alt',
            color: :yellow,
            text_color: 'black',
            coordinates: 'C12',
            reservation_color: nil,
          },
          {
            name: 'Carl Ludwigs-Bahn',
            sym: 'CL',
            type: 'Regional',
            float_percent: 50,
            tokens: [0, 40, 60, 80],
            color: '#B3B3B3',
            logo: '1824/CL',
            simple_logo: '1824/CL.alt',
            coordinates: 'B23',
            reservation_color: nil,
          },
          {
            name: 'Siebenbürgische Bahn',
            sym: 'SB',
            type: 'Regional',
            float_percent: 50,
            tokens: [0, 40, 60, 80],
            logo: '1824/SB',
            simple_logo: '1824/SB.alt',
            color: :green,
            text_color: 'black',
            coordinates: 'G26',
            reservation_color: nil,
          },
          {
            name: 'Bosnisch-Herzegowinische Landesbahn',
            sym: 'BH',
            type: 'Regional',
            float_percent: 50,
            tokens: [0, 40, 100],
            logo: '1824/BH',
            simple_logo: '1824/BH.alt',
            color: :red,
            coordinates: 'J13',
            reservation_color: nil,
          },
          {
            name: 'Südbahn',
            sym: 'SD',
            type: 'Staatsbahn',
            float_percent: 10,
            tokens: [100, 100],
            abilities: [
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 4',
              },
            ],
            logo: '1824/SD',
            simple_logo: '1824/SD.alt',
            color: :orange,
            text_color: 'black',
            reservation_color: nil,
          },
          {
            name: 'Ungarische Staatsbahn',
            sym: 'UG',
            type: 'Staatsbahn',
            float_percent: 10,
            tokens: [100, 100, 100],
            abilities: [
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 5',
              },
            ],
            logo: '1824/UG',
            simple_logo: '1824/UG.alt',
            color: :purple,
            reservation_color: nil,
          },
          {
            name: 'k&k Staatsbahn',
            sym: 'KK',
            type: 'Staatsbahn',
            float_percent: 10,
            tokens: [40, 100, 100, 100],
            abilities: [
              {
                type: 'no_buy',
                description: 'Unavailable in SR before phase 6',
              },
            ],
            logo: '1824/KK',
            simple_logo: '1824/KK.alt',
            color: :brown,
            reservation_color: nil,
          },
        ].freeze

        MINORS = [
          {
            sym: 'EPP',
            name: 'C1 Eisenbahn Pilsen - Priesen',
            type: 'Coal',
            tokens: [0],
            logo: '1824/C1',
            coordinates: 'C6',
            city: 0,
            color: '#7F7F7F',
            abilities: [
              {
                type: 'no_buy',
                description: 'Exchangable to 20% BK cert',
                desc_detail: "During an SR (phase 3/4) this might be exchanged for the Director's share in the BK "\
                             'regional railway. This exchange is in place of a normal share stock round action. '\
                             'When exchange takes place all assets are transfered to BK. EPP home station is removed. '\
                             'If exchange has not taken place before the 1st 5 train is bought, the exchange takes '\
                             'place directly, and BK can (if floated) operate in the next OR.',
              },
            ],
          },
          {
            sym: 'EOD',
            name: 'C2 Eisenbahn Oderberg - Dombran',
            type: 'Coal',
            tokens: [0],
            logo: '1824/C2',
            coordinates: 'A12',
            city: 0,
            color: '#7F7F7F',
            abilities: [
              {
                type: 'no_buy',
                description: 'Exchangable to 20% MS cert',
                desc_detail: "During an SR (phase 3/4) this might be exchanged for the Director's share in the MS "\
                             'regional railway. This exchange is in place of a normal share stock round action. '\
                             'When exchange takes place all assets are transfered to MS. EOD home station is removed.'\
                             ' If exchange has not taken place before the 1st 5 train is bought, the exchange takes '\
                             'place directly, and MS can (if floated) operate in the next OR.',
              },
            ],
          },
          {
            sym: 'MLB',
            name: 'C3 Mosty - Lemberg Bahn',
            type: 'Coal',
            tokens: [0],
            logo: '1824/C3',
            coordinates: 'A22',
            city: 0,
            color: '#7F7F7F',
            abilities: [
              {
                type: 'no_buy',
                description: 'Exchangable to 20% MS cert',
                desc_detail: "During an SR (phase 3/4) this might be exchanged for the Director's share in the CL "\
                             'regional railway. This exchange is in place of a normal share stock round action. '\
                             'When exchange takes place all assets are transfered to CL. MLB home station is removed.'\
                             ' If exchange has not taken place before the 1st 5 train is bought, the exchange takes '\
                             'place directly, and CL can (if floated) operate in the next OR.',
              },
            ],
          },
          {
            sym: 'SPB',
            name: 'C4 Simeria-Petrosani Bahn',
            type: 'Coal',
            tokens: [0],
            logo: '1824/C4',
            coordinates: 'H25',
            city: 0,
            color: '#7F7F7F',
            abilities: [
              {
                type: 'no_buy',
                description: 'Exchangable to 20% SB cert',
                desc_detail: "During an SR (phase 3/4) this might be exchanged for the Director's share in the SB "\
                              'regional railway. This exchange is in place of a normal share stock round action. '\
                              'When exchange takes place all assets are transfered to SB. SPB home station is removed.'\
                              ' If exchange has not taken place before the 1st 5 train is bought, the exchange takes '\
                              'place directly, and SB can (if floated) operate in the next OR.',
              },
            ],
          },
          {
            sym: 'S1',
            name: 'S1 Wien-Gloggnitzer Eisenbahngesellschaft',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/S1',
            coordinates: 'E12',
            city: 0,
            color: :orange,
            abilities: [
              {
                type: 'no_buy',
                description: '4-train sold: Becomes 20% SD cert',
                desc_detail: 'When the 1st 4-train is sold, at the end of the current SR, SD starts and this '\
                              "cert is exchanged for the Director's cert in SD. All assets of S1 is moved to "\
                              'SD and the S1 home station is replaced with an SD station. Besides the assets of '\
                              'the pre-staatsbahns, SD also receives 120G per IPO share that was not reserved. '\
                              'SD will operate in the next OR.',
              },
            ],
          },
          {
            sym: 'S2',
            name: 'S2 Kärntner Bahn',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/S2',
            coordinates: 'G10',
            city: 0,
            color: :orange,
            abilities: [
              {
                type: 'no_buy',
                description: '4-train sold: Becomes 10% SD cert',
                desc_detail: 'When the 1st 4-train is sold, at the end of the current SR, SD starts and this '\
                              'cert is exchanged for a 10% share in SD. All assets of S2 is moved to '\
                              'SD and the S2 home station is replaced with an SD station. Besides the assets of '\
                              'the pre-staatsbahns, SD also receives 120G per IPO share that was not reserved. '\
                              'SD will operate in the next OR.',
              },
            ],
          },
          {
            sym: 'S3',
            name: 'S3 Nordtiroler Staatsbahn',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/S3',
            coordinates: 'G4',
            city: 0,
            color: :orange,
            abilities: [
              {
                type: 'no_buy',
                description: '4-train sold: Becomes 10% SD cert',
                desc_detail: 'When the 1st 4-train is sold, at the end of the current SR, SD starts and this '\
                              'cert is exchanged for a 10% share in SD. All assets of S3 is moved to '\
                              'SD and the S3 home station is replaced with an SD station. Besides the assets of '\
                              'the pre-staatsbahns, SD also receives 120G per IPO share that was not reserved. '\
                              'SD will operate in the next OR.',
              },
            ],
          },
          {
            sym: 'U1',
            name: 'U1 Eisenbahn Pest - Waitzen',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/U1',
            coordinates: 'F17',
            city: 1,
            color: :purple,
            abilities: [
              {
                type: 'no_buy',
                description: "5-train sold: Becomes 20% UG cert",
                desc_detail: 'When the 1st 5-train is sold, at the end of the current SR, UG starts and this '\
                              "cert is exchanged for the Director's cert in UG. All assets of U1 is moved to "\
                              'UG and the U1 home station is replaced with an UG station. Besides the assets of '\
                              'the pre-staatsbahns, UG also receives 120G per IPO share that was not reserved. '\
                              'UG will operate in the next OR.',
              },
            ],
          },
          {
            sym: 'U2',
            name: 'U2 Mohacs-Fünfkirchner Bahn',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/U2',
            coordinates: 'H15',
            city: 0,
            color: :purple,
            abilities: [
              {
                type: 'no_buy',
                description: "5-train sold: Becomes 10% UG cert",
                desc_detail: 'When the 1st 5-train is sold, at the end of the current SR, UG starts and this '\
                              'cert is exchanged for a 10% share in UG. All assets of U2 is moved to '\
                              'UG and the U2 home station is replaced with an UG station. Besides the assets of '\
                              'the pre-staatsbahns, UG also receives 120G per IPO share that was not reserved. '\
                              'UG will operate in the next OR.',
              },
            ],
          },
          {
            sym: 'K1',
            name: 'K1 Kaiserin Elisabeth-Bahn',
            type: 'PreStaatsbahn',
            tokens: [0],
            coordinates: 'E12',
            city: 1,
            color: :brown,
            logo: '1824/K1',
            abilities: [
              {
                type: 'no_buy',
                description: "6-train sold: Becomes 20% KK cert",
                desc_detail: 'When the 1st 6-train is sold, at the end of the current SR, KK starts and this '\
                              "cert is exchanged for the Director's cert in KK. All assets of K1 is moved to "\
                              'KK and the K1 home station is replaced with an KK station. Besides the assets of '\
                              'the pre-staatsbahns, KK also receives 120G per IPO share that was not reserved. '\
                              'KK will operate in the next OR.',
              },
            ],
          },
          {
            sym: 'K2',
            name: 'K2 Kaiser Franz Joseph-Bahn',
            type: 'PreStaatsbahn',
            tokens: [0],
            logo: '1824/K2',
            coordinates: 'E12',
            city: 2,
            color: :brown,
            abilities: [
              {
                type: 'no_buy',
                description: "6-train sold: Becomes 10% KK cert",
                desc_detail: 'When the 1st 6-train is sold, at the end of the current SR, KK starts and this '\
                              'cert is exchanged for 10% share in KK. All assets of K2 is moved to '\
                              'KK and the K2 home station is replaced with an KK station. Besides the assets of '\
                              'the pre-staatsbahns, KK also receives 120G per IPO share that was not reserved. '\
                              'KK will operate in the next OR.',
              },
            ],
          },
        ].freeze
      end
    end
  end
end
