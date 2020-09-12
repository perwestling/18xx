# frozen_string_literal: true

require 'lib/publisher'

module View
  class Welcome < Snabberb::Component
    needs :app_route, default: nil, store: true
    needs :show_intro, default: true

    def render
      children = [render_notification]
      children << render_introduction if @show_intro
      children << render_buttons

      h('div#welcome.half', children)
    end

    def render_notification
      message = <<~MESSAGE
        <h1>THIS IS AN 18SJ TEST SITE - NO SUPPORT</h1>
        <p>Intention is to try out pre-alpha versions of 18xx for 18xx.games.</p>
        <p>Currently only available games are:</p>
        <ul>
         <li><b>1824</b> -- not yet playable pre-alpha test version</li>
         <li><b>1893</b> -- playable pre-alpha test version</li>
        </ul>
        This is a test site, just used to try out features and/or games before considering to push them to the "real" site.
        Games created here has no guarantee, and might be removed if the bug out.
        New version might be deployed at unspecified times.
        <p>
        Release notes:
         <ul>
           <li>2021-05-23 17:00 CET:
             <ul>
               <li>New version of 1893 Cologne for pre-alpha play test</li>
             </ul>
           </li>
         </ul>
        </p>
        <p>For the "real thing", go to <a href="http://18xx.games">18xx.games</a></p>
      MESSAGE

      props = {
        style: {
          background: 'rgb(240, 229, 140)',
          color: 'black',
          marginBottom: '1rem',
        },
        props: {
          innerHTML: message,
        },
      }

      h('div#notification.padded', props)
    end

    def render_introduction
      message = <<~MESSAGE
        <p>18xx.games is a website where you can play async or real-time 18xx games (based on the system originally devised by the brilliant Francis Tresham)!</p>

        <p>You can play locally with hot seat mode without an account. If you want to play multiplayer, you'll need to create an account.</p>

        <p>If you look at other people's games, you can make moves to play around but it won't affect them and changes won't be saved.
        You can clone games in the tools tab and then play around locally.</p>

        <p>In multiplayer games, you'll also be able to make moves for other players, this is so people can say 'pass me this SR' and you don't
        need to wait. To use this feature in a game, enable "Master Mode" in the Tools tab. Please use it politely!</p>
      MESSAGE

      props = {
        style: {
          marginBottom: '1rem',
        },
        props: {
          innerHTML: message,
        },
      }

      h('div#introduction', props)
    end

    def render_buttons
      props = {
        style: {
          margin: '1rem 0',
        },
      }

      create_props = {
        on: {
          click: -> { store(:app_route, '/new_game') },
        },
      }

      tutorial_props = {
        on: {
          click: -> { store(:app_route, '/tutorial?action=1') },
        },
      }

      h('div#buttons', props, [
        h(:button, create_props, 'CREATE A NEW GAME'),
        h(:button, tutorial_props, 'TUTORIAL'),
      ])
    end
  end
end
