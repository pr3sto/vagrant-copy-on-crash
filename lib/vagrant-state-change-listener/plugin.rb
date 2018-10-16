begin
    require 'vagrant'
rescue LoadError
    raise 'This plugin must run within Vagrant.'
end

module VagrantPlugins
    module StateChangeListener
        class Plugin < Vagrant.plugin('2')
            name 'vagrant-state-change-listener'

            description <<-DESC
            This plugin is listening vm state changes and executes actions on changes
            DESC

            command 'listen-state-changes' do
                require_relative "command"
                Command::Listen
            end
        end
    end
end
