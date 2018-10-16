require "vagrant/util/busy"

module VagrantPlugins
    module StateChangeListener
        module Command
            class Listen < Vagrant.plugin("2", :command)
                def self.synopsis
                    "listens vm state changes and executes actions on changes"
                end

                def execute
                    options = {}

                    opts = OptionParser.new do |o|
                        o.banner = 'Usage: vagrant listen-state-changes <vm name> <actions> [options]'
                        o.separator ''
                        o.separator '<vm name> - name of virtual machine'
                        o.separator '<actions> - shell commands'
                        o.separator ''
                        o.separator 'Options:'
                        o.on('-f', '--first-state FSTATE', "If vm changes it's state from FSTATE, plugin executes <actions>") do |s|
                            options[:first_state] = s
                        end
                        o.on('-s', '--second-state SSTATE', "If vm changes it's state to SSTATE, plugin executes <actions>") do |s|
                            options[:second_state] = s
                        end
                        o.on('-l', '--latency SECONDS', Integer, 'Delay (in seconds) between checking for changes. Default: 1 sec') do |l|
                            options[:latency] = l
                        end
                        o.on('-a', '--auto-stop', Integer, 'Stop listening after first state change (after executing <actions>)') do |l|
                            options[:auto_stop] = true
                        end
                        o.separator ''
                    end
                    opts.parse!

                    # ARGV shoul be [command, vm name, actions] 
                    if ARGV.length != 3
                        puts opts
                        exit
                    end

                    if (!options[:first_state].nil? && !options[:second_state].nil? && options[:first_state] == options[:second_state])
                        puts opts
                        @env.ui.error(I18n.t('vagrant-state-change-listener.command.error.states-should-be-different'))
                        exit
                    end

                    first_state = options[:first_state]
                    second_state = options[:second_state]
                    latency = options[:latency].nil? ? 1 : options[:latency]
                    auto_stop = !options[:auto_stop].nil?
                    machine_name = ARGV[1]
                    actions = ARGV[2]
                    machine = nil

                    with_target_vms(machine_name) do |m|
                        machine = m
                    end
                    if machine.state.id == :not_created
                        @env.ui.error(I18n.t('vagrant-state-change-listener.command.error.vm-not-created',
                            vm_name: machine_name
                        ))
                        exit
                    end

                    # The callback that lets us know when we have been interrupted
                    queue = Queue.new
                    interrupt_callback = lambda do
                        # This needs to execute in another thread because Thread
                        # synchronization can't happen in a trap context
                        Thread.new { queue << true }
                    end
                    
                    # Run the code in a busy block so that we can cleanly
                    # exit once we receive an interrupt
                    Vagrant::Util::Busy.busy(interrupt_callback) do
                        Thread.new do
                            prev_state = nil
                            loop do
                                curr_state = machine.state.short_description

                                if (!prev_state.nil? && prev_state != curr_state &&    # state changed
                                    (first_state.nil? || prev_state == first_state) && # see if prev state match option FSTATE
                                    (second_state.nil? || second_state == curr_state)  # see if curr state match option SSTATE
                                )
                                    @env.ui.info(I18n.t('vagrant-state-change-listener.command.info.state-changed',
                                        f_state: prev_state,
                                        s_state: curr_state
                                    ))
                                    @env.ui.info(I18n.t('vagrant-state-change-listener.command.info.executing-actions',
                                        actions: actions
                                    ))

                                    status = system(actions)
                                    
                                    @env.ui.info(I18n.t('vagrant-state-change-listener.command.info.executed-actions-status',
                                        status: status
                                    ))
                                    
                                    if (auto_stop)
                                        @env.ui.info(I18n.t('vagrant-state-change-listener.command.info.auto-stop'))
                                        interrupt_callback.call()
                                        break
                                    end

                                    @env.ui.info("")
                                end

                                prev_state = curr_state
                                sleep latency
                            end
                        end
                        # This will block main thread untill callback is called
                        queue.pop
                    end

                end # def execute
            end
        end
    end
end
