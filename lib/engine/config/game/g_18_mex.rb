# frozen_string_literal: true

# File original exported from 18xx-maker/export-rb
# https://github.com/18xx-maker/export-rb
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18MEX
        JSON = <<-'DATA'
{
   "filename":"18_mex",
   "modulename":"18MEX",
   "currencyFormatStr":"$%d",
   "bankCash":9000,
   "certLimit":{
      "3":19,
      "4":14,
      "5":11
   },
   "startingCash":{
      "3":625,
      "4":500,
      "5":450
   },
   "capitalization":"full",
   "layout":"flat",
   "mustSellInBlocks":false,
   "locationNames":{
      "A6":"Ciudad Juárez / El Paso",
      "B1":"Baja California",
      "B3":"Nogales / Tuscon",
      "D3":"Hermosillo",
      "E6":"Chihuahua",
      "D11":"San Antonio",
      "G10":"Nuevo Laredo",
      "I4":"Los Mochis",
      "I8":"Torreón",
      "I10":"Monterrey",
      "I12":"Matamoros",
      "J5":"Culiacán",
      "J7":"Durango",
      "K8":"Zacatecas",
      "K6":"Mazatlán",
      "L9":"San Luis Potosí",
      "M10":"Querétaro",
      "M12":"Tampico",
      "O8":"Guadalajara",
      "O10":"Mexico City",
      "P7":"Puerto Vallarta",
      "P11":"Puebla",
      "P13":"Veracruz",
      "Q14":"Mérida",
      "S10":"Acapulco",
      "S12":"Oaxaca",
      "U14":"Guatemala"
   },
   "tiles":{
      "3":3,
      "4":3,
      "5":2,
      "6":2,
      "7":5,
      "8":11,
      "9":11,
      "14":3,
      "15":3,
      "16":1,
      "17":1,
      "18":1,
      "19":1,
      "20":1,
      "23":4,
      "24":4,
      "25":3,
      "26":1,
      "27":1,
      "28":1,
      "29":1,
      "39":1,
      "40":2,
      "41":3,
      "42":3,
      "43":2,
      "44":1,
      "45":2,
      "46":2,
      "47":2,
      "57":4,
      "58":4,
      "63":7,
      "70":1,
      "141":2,
      "142":2,
      "143":2,
      "455":1,
      "470":{
         "count":1,
         "color":"yellow",
         "code":"town=revenue:20,loc:0;path=a:0,b:_0;path=a:3,b:_0;path=a:3,b:4;path=a:4,b:_0;label=CC"
      },
      "471":1,
      "472":1,
      "473":1,
      "474":1,
      "475":1,
      "476":1,
      "477":1,
      "478":1,
      "479MC":{
         "count":1,
         "color":"green",
         "code":"city=revenue:40,slots:2,loc:center;town=revenue:0,loc:2.5;path=a:3,b:_0;path=a:5,b:_0;label=MC"
      },
      "479P":{
         "count":1,
         "color":"green",
         "code":"town=revenue:10;path=a:2,b:_0;path=a:_0,b:5;upgrade=cost:40,terrain:mountain;label=P"
      },
      "480":1,
      "481":1,
      "482":1,
      "483":1,
      "484":1,
      "485MC":{
         "count":1,
         "color":"brown",
         "code":"city=revenue:60,slots:3,loc:center;town=revenue:10,loc:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:2,b:_1;path=a:5,b:_0,lanes:2;path=a:_1,b:_0;label=MC"
      },
      "485P":{
         "count":1,
         "color":"brown",
         "code":"town=revenue:10;path=a:2,b:_0,a_lane:2.1;path=a:5,b:_0;path=a:2,b:4,a_lane:2.0;label=P"
      },
      "486MC":{
         "count":1,
         "color":"brown",
         "code":"city=revenue:50,slots:4,loc:center;town=revenue:10,loc:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:2,b:_1;path=a:5,b:_0,lanes:2;path=a:_1,b:_0;label=MC"
      },
      "486P":{
         "count":1,
         "color":"brown",
         "code":"town=revenue:10;path=a:2,b:_0,a_lane:2.1;path=a:5,b:_0;path=a:2,b:4,a_lane:2.0;label=P"
      },
      "619":1
   },
   "market":[
      [
         "60",
         "65",
         "70",
         "75",
         "80p",
         "90p",
         "100",
         "110",
         "120",
         "130",
         "140",
         "150",
         "165",
         "180",
         "200e"
      ],
      [
         "55",
         "60",
         "65",
         "70p",
         "75p",
         "80",
         "90",
         "100",
         "110",
         "120",
         "130",
         "140",
         "150",
         "165",
         "180"
      ],
      [
         "50",
         "55",
         "60p",
         "65",
         "70",
         "75",
         "80",
         "90",
         "100",
         "110",
         "120",
         "130",
         "140",
         "150"
      ],
      [
         "45",
         "50",
         "55",
         "60",
         "65",
         "70",
         "75",
         "80",
         "90",
         "100",
         "110",
         "120"
      ],
      [
         "40y",
         "45",
         "50",
         "55",
         "60",
         "65",
         "70",
         "75",
         "80"
      ],
      [
         "30y",
         "40y",
         "45y",
         "50y",
         "55y"
      ],
      [
         "20y",
         "30y",
         "40y",
         "45y",
         "50y"
      ],
      [
         "10y"
      ]
   ],
   "companies":[
      {
         "sym":"MCAR",
         "name":"Mexico City-Acapulco Railroad",
         "value":20,
         "revenue":5,
         "desc":"No special abilities."
      },
      {
         "sym":"KCMO",
         "name":"Kansas City, Mexico, & Orient Railroad",
         "value":40,
         "revenue":10,
         "desc":"Owning company may place the non-upgradable Copper Canyan tile in E6 for $60 (instead of the normal $120) unless that hex is already built. The tile lay does not have to be connected to an existing station token of the owning corporation. The lay does not count toward the normal lay limit but must be done during tile lay.",
         "abilities": [
            {
              "type": "tile_lay",
              "discount": 60,
              "owner_type": "corporation",
              "tiles": [
                 "470"
              ],
              "hexes": [
                "F5"
              ],
              "count": 1,
              "when": "track"
            }
        ]
      },
      {
         "sym":"A",
         "name":"Interoceanic Railroad",
         "value":50,
         "revenue":0,
         "desc":"Minor company A. Begins in Tampico (M12). Once closed owner receives a 5% share in NdM.",
         "abilities": [
            {
              "type": "no_buy",
              "owner_type": "player"
            },
            {
               "type": "close",
               "when": "3½",
               "owner_type": "player"
            }
         ]
      },
      {
         "sym":"B",
         "name":"Sonora-Baja California Railway",
         "value":50,
         "revenue":0,
         "desc":"Minor company B. Begins in Mazatlán (K6). Once closed owner receives a 5% share in NdM.",
         "abilities": [
            {
              "type": "no_buy",
              "owner_type": "player"
            },
            {
               "type": "close",
               "when": "3½",
               "owner_type": "player"
            }
         ]
      },
      {
         "sym":"C",
         "name":"Southeastern Railway",
         "value":50,
         "revenue":0,
         "desc":"Minor company C. Begins in Oaxaca (S12). Once closed owner receives a 10% share in UdY.",
         "abilities": [
            {
              "type": "no_buy",
              "owner_type": "player"
            },
            {
               "type": "close",
               "when": "3½",
               "owner_type": "player"
            }
         ]
      },
      {
         "sym":"MIR",
         "name":"Mexican International Railroad",
         "value":100,
         "revenue":20,
         "desc":"Comes with a 10% share of the Chihuahua Pacific Railway (CHI).",
         "abilities":[
            {
               "type":"shares",
               "shares":"CHI_1"
            },
            {
               "type":"blocks_hexes",
               "owner_type":"player",
               "hexes":[
                  "K11",
                  "J12"
               ]
            }
         ]
      },
      {
         "sym":"MNR",
         "name":"Mexican National Railroad",
         "value":140,
         "revenue":20,
         "desc":"Comes with President's Certificate of NdM. Owner must immediately set NdM's par price. Closes when NdM buys a train. May not be sold to a company.",
         "abilities":[
            {
               "type":"shares",
               "shares":"NdM_0"
            },
            {
               "type":"close",
               "when":"train",
               "corporation":"NdM"
            },
            {
               "type":"no_buy"
            }
         ]
      }
   ],
   "minors":[
      {
         "sym":"A",
         "name":"Interoceanic Railroad",
         "logo":"18_mex/A",
         "tokens":[
            0
         ],
         "coordinates":"M12",
         "color":"green"
      },
      {
         "sym":"B",
         "name":"Sonora-Baja Railway",
         "logo":"18_mex/B",
         "tokens":[
            0
         ],
         "coordinates":"K6",
         "color":"green"
      },
      {
         "sym":"C",
         "name":"Southeastern Railway",
         "logo":"18_mex/C",
         "tokens":[
            0
         ],
         "coordinates":"S12",
         "color":"purple"
      }
   ],
   "corporations":[
      {
         "float_percent":50,
         "sym":"CHI",
         "name":"Chihuahua Pacific Railway",
         "logo":"18_mex/CHI",
         "tokens":[
            0,
            40,
            60,
            80
         ],
         "coordinates":"E6",
         "color":"red"
      },
      {
         "float_percent":50,
         "sym":"NdM",
         "name":"National Railways of Mexico",
         "logo":"18_mex/NdM",
         "shares":[20, 10, 10, 10, 10, 10, 10, 5, 5, 10],
         "tokens":[
            0,
            40,
            60,
            80,
            0,
            0
         ],
         "abilities": [
            {
               "type": "train_buy",
               "description": "Inter train buy/sell at face value",
               "face_value": true
            },
            {
               "type": "train_limit",
               "description": "+1 train limit",
               "increase": 1
            }
         ],
         "coordinates":"O10",
         "color":"green"
      },
      {
         "float_percent":50,
         "sym":"MC",
         "name":"Mexican Central Railway",
         "logo":"18_mex/MC",
         "tokens":[
            0,
            40
         ],
         "coordinates":"I8",
         "color":"black"
      },
      {
         "float_percent":50,
         "sym":"PAC",
         "name":"Pacific Railroad",
         "logo":"18_mex/PAC",
         "tokens":[
            0,
            40,
            60,
            80
         ],
         "coordinates":"B3",
         "color":"yellow",
         "text_color":"black"
      },
      {
         "float_percent":50,
         "sym":"TM",
         "name":"Texas-Mexican Railway",
         "logo":"18_mex/TM",
         "tokens":[
            0,
            40
         ],
         "coordinates":"I12",
         "color":"orange"
      },
      {
         "float_percent":50,
         "sym":"MEX",
         "name":"Mexican Railway",
         "logo":"18_mex/MEX",
         "tokens":[
            0,
            40,
            60
         ],
         "coordinates":"P13",
         "color":"gray",
         "text_color":"black"
      },
      {
         "float_percent":50,
         "sym":"SPM",
         "name":"Southern Pacific Railroad of Mexico",
         "logo":"18_mex/SPM",
         "tokens":[
            0,
            40,
            60
         ],
         "coordinates":"O8",
         "color":"blue"
      },
      {
         "float_percent":50,
         "sym":"UdY",
         "name":"United Railways of Yucatan",
         "logo":"18_mex/UdY",
         "tokens":[
            0,
            40
         ],
         "coordinates":"Q14",
         "color":"purple"
      }
   ],
   "trains":[
      {
         "name":"2",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":2,
               "visit":2
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":100,
         "num":9,
         "rusts_on":"4"
      },
      {
         "name":"3",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":3,
               "visit":3
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":180,
         "num":4,
         "rusts_on":"6"
      },
      {
         "name":"3'",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":3,
               "visit":3
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":180,
         "num":2,
         "rusts_on":"6",
         "events":[
            {"type": "minors_closed"}
          ]
      },
      {
         "name":"4",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":4,
               "visit":4
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":300,
         "num":3,
         "obsolete_on":"6'"
      },
      {
         "name":"5",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":5,
               "visit":5
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":450,
         "num":2,
         "events":[
           {"type": "close_companies"},
           {"type": "ndm_merger"}
         ]
      },
      {
         "name":"6",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":6,
               "visit":6
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":600,
         "num":1
      },
      {
         "name":"6'",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":6,
               "visit":6
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":600,
         "num":1
      },
      {
         "name":"4D",
         "distance":[
            {
               "nodes":[
                  "city",
                  "offboard"
               ],
               "pay":4,
               "visit":4
            },
            {
               "nodes":[
                  "town"
               ],
               "pay":99,
               "visit":99
            }
         ],
         "price":700,
         "num":7
      }
   ],
   "hexes":{
      "red":{
         "offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0":[
            "A6"
         ],
         "offboard=revenue:yellow_30|brown_50;path=a:5,b:_0":[
            "B1"
         ],
         "city=revenue:yellow_10|brown_50;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1":[
            "Q14"
         ],
         "offboard=revenue:yellow_30|brown_40;path=a:2,b:_0":[
            "U14"
         ]
      },
      "gray":{
         "city=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:1,b:_0":[
            "B3"
         ],
         "city=revenue:yellow_30|brown_60,slots:2;path=a:0,b:_0;path=a:1,b:_0":[
            "D11"
         ],
         "city=revenue:yellow_20|brown_40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0":[
            "I12"
         ],
         "path=a:3,b:4":[
            "U12"
         ]
      },
      "white":{
         "upgrade=cost:120,terrain:mountain":[
            "B5",
            "C4",
            "D7",
            "E4",
            "F7",
            "F9",
            "G8",
            "H5",
            "I6",
            "N9",
            "P9",
            "F5"
         ],
         "upgrade=cost:120,terrain:mountain;border=edge:4,type:impassable":[
            "Q10"
         ],
         "upgrade=cost:120,terrain:mountain;border=edge:3,type:impassable":[
            "R11"
         ],
         "upgrade=cost:60,terrain:mountain":[
            "C2",
            "L11",
            "Q8",
            "Q12"
         ],
         "upgrade=cost:60,terrain:mountain;border=edge:0,type:impassable;border=edge:1,type:impassable":[
            "N11"
         ],
         "upgrade=cost:60,terrain:mountain;border=edge:5,type:impassable":[
            "O12"
         ],
         "upgrade=cost:20,terrain:desert":[
            "E2",
            "C6",
            "D5",
            "E8",
            "E10",
            "F3",
            "G6",
            "H9",
            "J9",
            "J11"
         ],
         "city=revenue:0;upgrade=cost:60,terrain:mountain":[
            "D3",
            "M10"
         ],
         "upgrade=cost:20,terrain:water":[
            "D9",
            "H11",
            "N7",
            "T11",
            "T13"
         ],
         "":[
            "F11",
            "G4",
            "H7",
            "K10",
            "L7",
            "M8",
            "R9"
         ],
         "city=revenue:0;upgrade=cost:20,terrain:water":[
            "G10",
            "I4",
            "O8"
         ],
         "upgrade=cost:40,terrain:swamp":[
            "G12",
            "K12"
         ],
         "city=revenue:0":[
            "I8",
            "I10"
         ],
         "town=revenue:0":[
            "J5",
            "L9",
            "P7"
         ],
         "town=revenue:0;upgrade=cost:60,terrain:mountain":[
            "J7"
         ],
         "town=revenue:0;upgrade=cost:20,terrain:desert":[
            "K8"
         ],
         "city=revenue:20,loc:center;town=revenue:10,loc:1;path=a:_1,b:_0;upgrade=cost:20,terrain:water;label=M":[
            "K6"
         ],
         "city=revenue:20,loc:center;town=revenue:10,loc:4;path=a:_0,b:_1;upgrade=cost:40,terrain:swamp;label=T":[
            "M12"
         ],
         "city=revenue:0,loc:center;town=revenue:0,loc:5;upgrade=cost:40,terrain:swamp;label=V":[
            "P13"
         ],
         "town=revenue:0;upgrade=cost:120,terrain:mountain":[
            "S10"
         ],
         "city=revenue:20;path=a:4,b:_0;upgrade=cost:20,terrain:water":[
            "S12"
         ]
      },
      "yellow":{
         "city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0":[
            "E6"
         ],
         "city=revenue:20,loc:center;town=revenue:0,loc:2;path=a:3,b:_0;path=a:5,b:_0;label=MC":[
            "O10"
         ],
         "town=revenue:10;path=a:2,b:_0;path=a:_0,b:5;upgrade=cost:60,terrain:mountain;label=P":[
            "P11"
         ],
         "path=a:1,b:4;upgrade=cost:60,terrain:mountain":[
            "R13"
         ]
      }
   },
   "phases":[
      {
         "name":"2",
         "train_limit":3,
         "tiles":[
            "yellow"
         ],
         "status":[
            "limited_train_buy"
         ],
         "operating_rounds": 1
      },
      {
         "name":"3",
         "on":"3",
         "train_limit":3,
         "tiles":[
            "yellow",
            "green"
         ],
         "status":[
            "can_buy_companies",
            "limited_train_buy"
         ],
         "operating_rounds": 2
      },
      {
         "name":"3½",
         "on":"3'",
         "train_limit":3,
         "tiles":[
            "yellow",
            "green"
         ],
         "status":[
            "can_buy_companies",
            "limited_train_buy",
            "ndm_available"
         ],
         "operating_rounds": 2
      },
      {
         "name":"4",
         "on":"4",
         "train_limit":2,
         "tiles":[
            "yellow",
            "green"
         ],
         "status":[
            "can_buy_companies",
            "ndm_available"
         ],
         "operating_rounds": 2
      },
      {
         "name":"5",
         "on":"5",
         "train_limit":2,
         "tiles":[
            "yellow",
            "green",
            "brown"
         ],
         "status":[
            "ndm_available"
         ],
         "operating_rounds": 3
      },
      {
         "name":"6",
         "on":"6",
         "train_limit":2,
         "tiles":[
            "yellow",
            "green",
            "brown"
         ],
         "status":[
            "ndm_available"
         ],
         "operating_rounds": 3
      },
      {
         "name":"6½",
         "on":"6'",
         "train_limit":2,
         "tiles":[
            "yellow",
            "green",
            "brown"
         ],
         "status":[
            "ndm_available"
         ],
         "operating_rounds": 3
      },
      {
         "name":"4D",
         "on":"4D",
         "train_limit":2,
         "tiles":[
            "yellow",
            "green",
            "brown",
            "gray"
         ],
         "status":[
            "ndm_available"
         ],
         "operating_rounds": 3
      }
   ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation
