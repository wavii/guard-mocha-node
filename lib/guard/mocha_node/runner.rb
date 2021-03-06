require 'open3'
require 'guard/ui'

module Guard
  class MochaNode
    module Runner
      def self.run(paths = [], options = {})
        return false if paths.empty?

        @paths   = paths
        @options = options

        print_message
        execute_mocha_node_command
      end

      private

      def self.print_message
        message = @options[:message]
	is_all_specs = @paths.sort == @options[:paths_for_all_specs].sort
        message ||= is_all_specs ? "Running all specs" : "Running: #{@paths.join(' ')}"
        ::Guard::UI.info(message, :reset => true)
      end

      def self.execute_mocha_node_command
        ::Open3.popen3(*mocha_node_command)
      end

      def self.mocha_node_command
        argvs = [ @options[:mocha_bin] ]
        argvs += command_line_options
        argvs += @paths
        argvs.map(&:to_s)
      end

      def self.command_line_options
        options = []
	compilers = []

        if @options[:coffeescript]
          compilers << "coffee:coffee-script"
        end

	if @options[:livescript]
          compilers << "ls:LiveScript"
        end

	if not compilers.empty?
	  options << "--compilers"
	  options << compilers.join(",")
	end

        if @options[:recursive]
          options << "--recursive"
        end

	if @options[:require]
	  r = @options[:require]
	  r = [r] if not r.instance_of? Array

	  r.each { |e|
	    options << "-r"
	    options << e
	  }
	end

        if @options[:color]
          options << "-c"
        else
          options << "-C"
        end

	# puts "---- printing the options"
	# puts options
        options + Array(@options[:extra_cli_opts])
      end
    end
  end
end
