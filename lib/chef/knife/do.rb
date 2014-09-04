require 'chef'
require 'chef/knife'
require 'rake'

module Rake
  class << self
    def application
      @application ||= CustomApplication.new
    end
  end

  class CustomApplication < Application
    DEFAULT_RAKEFILES = ['config/tasks.rb'].freeze
    def initialize
      super
      @name = 'rake'
      @rakefiles = DEFAULT_RAKEFILES.dup
      @rakefile = nil
      @pending_imports = []
      @imported = []
      @loaders = {}
      @default_loader = Rake::DefaultLoader.new
      @original_dir = Dir.pwd
      @top_level_tasks = []
      add_loader('rb', Rake::DefaultLoader.new)
      add_loader('rf', Rake::DefaultLoader.new)
      add_loader('rake', Rake::DefaultLoader.new)
      @tty_output = STDOUT.tty?
      @terminal_columns = ENV['RAKE_COLUMNS'].to_i
    end

    # overriden original method to use 'knife do task' instead of 'rake'
    # in task list
    def display_tasks_and_comments
      displayable_tasks = tasks.select do |t|
        (options.show_all_tasks || t.comment) &&
          t.name =~ options.show_task_pattern
      end
      case options.show_tasks
      when :tasks
        width = displayable_tasks.map { |t| t.name_with_args.length }.max || 10
        if truncate_output?
          max_column = terminal_width - name.size - width - 7
        else
          max_column = nil
        end

        displayable_tasks.each do |t|
          printf("knife do task %-#{width}s  # %s\n",
                 t.name_with_args,
                 max_column ? truncate(t.comment, max_column) : t.comment)
        end
      else
        super
      end
    end
  end
end

module KnifeTasks
  include Rake

  Rake::TaskManager.record_task_metadata = true

  def load_rake_as_lib
    Dir.chdir(Chef::Config.find_chef_repo_path(__FILE__))
    return unless Rake.application.tasks.empty?
    @rake_app = Rake.application
    @rake_app.init
    @rake_app.load_rakefile
  end

  class Do < Chef::Knife
    include KnifeTasks
    banner 'knife do (options)'

    deps do
      #
    end

    # Options Rake magically captures from the command line. Defined here
    # based on `rake -h` so they're returned by `knife do task --help`.
    option :trace,
           short: '-t',
           long: '--trace=[OUT]',
           description: "Turn on invoke/execute tracing, enable full backtrace. OUT can be stderr (default) or stdout."

    option :version,
           short: '-V',
           long: '--version',
           description: 'Display knife do version.',
           proc: proc { p "knife-do, version #{KnifeTasks::VERSION}" }

    option :comments,
           short: '-C',
           long: '--comments',
           description: 'Display Rake version.'

    option :verbose,
           short: '-v',
           long: '--verbose',
           description: "Verbose"

    def run
      load_rake_as_lib
      @rake_app.options.show_tasks = :tasks
      @rake_app.options.show_task_pattern = //
      @rake_app.display_tasks_and_comments
    end
  end

  class DoTask < Chef::Knife
    include KnifeTasks
    banner 'knife do task (options)'

    deps do
      require 'rake'
    end

    # Options Rake magically captures from the command line. Defined here
    # based on `rake -h` so they're returned by `knife do task --help`.
    option :execute_continue,
           short: '-E CODE',
           long: '--execute-continue CODE',
           description: 'Execute some Ruby code, then continue with normal task processing.'

    option :execute_code,
           short: '-e CODE',
           long: '--execute-code CODE',
           description: 'Execute some Ruby code and exit.'

    option :version,
           short: '-V',
           long: '--version',
           description: 'Display Rake version.'

    option :dry_run,
           short: '-n',
           long: '--dry-run',
           description: 'Do a dry run without executing actions.'

    option :execute_print,
           short: '-p CODE',
           long: '--execute-print CODE',
           description: 'Execute some Ruby code, print the result, then exit.'

    option :silent,
           short: '-s',
           long: '--silent',
           description: "Like --quiet, but also suppresses the 'in directory' announcement."

    option :quiet,
           short: '-q',
           long: '--quiet',
           description: 'Do not log messages to standard output.'

    option :rakefile,
           short: '-f FILENAME',
           long: '--rakefile FILENAME',
           description: 'Use FILENAME as the rakefile to search for.'

    option :no_deprecation_warnings,
           short: '-X',
           long: '--no-deprecation-warnings',
           description: 'Disable the deprecation warnings.'

    option :system,
           short: '-g',
           long: '--system',
           description: "Using system wide (global) rakefiles (usually '~/.rake/*.rake')."

    option :no_system,
           short: '-G',
           long: '--no-system',
           long: '--nosystem',
           description: 'Use standard project Rakefile search paths, ignore system wide rakefiles.'

    option :trace,
           short: '-t',
           long: '--trace=[OUT]',
           description: "Turn on invoke/execute tracing, enable full backtrace. OUT can be stderr (default) or stdout."

    option :rules,
           long: '--rules',
           description: 'Trace the rules resolution.'

    option :libdir,
           short: '-I LIBDIR',
           long: '--libdir LIBDIR',
           description: 'Include LIBDIR in the search path for required modules.'

    option :require,
           short: '-r MODULE',
           long: '--require MODULE',
           description: 'Require MODULE before executing rakefile.'

    option :suppress_backtrace,
           long: '--suppress-backtrace PATTERN',
           description: 'Suppress backtrace lines matching regexp PATTERN. Ignored if --trace is on.'

    option :rakelib,
           short: '-R RAKELIBDIR',
           long: '--rakelibdir RAKELIBDIR',
           long: '--rakelib RAKELIBDIR',
           description: "Auto-import any .rake files in RAKELIBDIR. (default is 'rakelib')"

    option :verbose,
           short: '-v',
           long: '--verbose',
           description: "Verbose"

    def run
      load_rake_as_lib
      if ARGV.drop(2).empty?
        Rake::Task[:default].invoke
      else
        @rake_app.top_level_tasks.each do |task_name|
          @rake_app.invoke_task(task_name) unless %w(do task).include? task_name
        end
      end
    end
  end
end
