#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Customhook
      module RegisterHttpHandlers
        BeEF::API::Registrar.instance.register(BeEF::Extension::Customhook::RegisterHttpHandlers, BeEF::API::Server, 'mount_handler')
        BeEF::API::Registrar.instance.register(BeEF::Extension::Customhook::RegisterHttpHandlers, BeEF::API::Server, 'pre_http_start')

        def self.mount_handler(beef_server)
          configuration = BeEF::Core::Configuration.instance
          configuration.get('beef.extension.customhook.hooks').each do |h|
            beef_server.mount(configuration.get("beef.extension.customhook.hooks.#{h.first}.path"), BeEF::Extension::Customhook::Handler.new)
          end
        end

        def self.pre_http_start(_beef_server)
          configuration = BeEF::Core::Configuration.instance
          configuration.get('beef.extension.customhook.hooks').each do |h|
            print_success 'Successfully mounted a custom hook point'
            print_more "Mount Point: #{configuration.get("beef.extension.customhook.hooks.#{h.first}.path")}\nLoading iFrame: #{configuration.get("beef.extension.customhook.hooks.#{h.first}.target")}\n"
          end
        end
      end
    end
  end
end
