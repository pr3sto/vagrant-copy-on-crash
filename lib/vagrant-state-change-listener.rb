require 'pathname'
require 'vagrant-state-change-listener/plugin'

module VagrantPlugins
    module StateChangeListener
        lib_path = Pathname.new(File.expand_path('../vagrant-state-change-listener', __FILE__))

        # Returns the path to the source of this plugins
        def self.source_root
            @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
        end

        I18n.load_path << File.expand_path('locales/en.yml', source_root)
        I18n.reload!
    end
end
