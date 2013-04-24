# -*- coding: utf-8 -*-

# Namespace for [Inventory](http://disu.se/software/inventory/).  The bulk of
# the library is in {Rake::Tasks::YARD}.
class Inventory; end

# Namespace for [Rake](http://rake.rubyforge.org/) integration of Inventory.
module Inventory::Rake
end

# Namespace for [Inventory Rake](http://disu.se/software/inventory-rake) tasks.
module Inventory::Rake::Tasks
end

# Defines a task that invokes [YARD](http://yardoc.org/) to process embedded
# documentation.
class Inventory::Rake::Tasks::YARD
  load File.expand_path('../inventory-rake-tasks-yard-1.0/version.rb', __FILE__)
  Version.load

  include Rake::DSL

  # Sets up a YARD task NAME, passing OPTIONS, on the files listed in INVENTORY
  # or FILES, with GLOBALS set, optionally yields the task object for further
  # customization, then {#define}s NAME.
  #
  # The default for OPTIONS is:
  #
  #     --no-private --protected --private --query \
  #       "(!object.docstring.blank?&&object.docstring.line)||object.root?" \
  #     --markup markdown --no-stats
  #
  # This’ll make YARD output documentation for all public, protected, and
  # private objects not markes as `@private` that have documentation that
  # hasn’t been automatically generated or is the top-level namespace using
  # Markdown as the markup format and not outputting any statistics at the end
  # of execution.
  #
  # @param [Hash] options
  # @option options [Symbol] :name (:html) The name of the task to define
  # @option options [Array<String, Array<String>>] :options (…) The options to
  #   pass to YARD; will be passed to `Shellwords.shelljoin`
  # @option options [Inventory] :inventory (Inventory::Rake::Tasks.inventory)
  #   The inventory to use for FILES default
  # @option options [Array<String>] :files (FileList[ENV['FILES']] or
  #   inventory.lib_files) The files to process
  # @option options [Hash] :globals ({}) The globals to pass to YARD
  # @yield [?]
  # @yieldparam [self] task
  def initialize(options = {})
    self.name = options.fetch(:name, :html)
    self.options = options.fetch(:options,
                                 ['--no-private',
                                  '--protected',
                                  '--private',
                                  ['--query', %w{'(!object.docstring.blank?&&object.docstring.line)||object.root?'}],
                                  ['--markup', 'markdown'],
                                  '--no-stats'])
    self.inventory = options.fetch(:inventory, Inventory::Rake::Tasks.inventory)
    self.files = options.fetch(:files){ ENV.include?('FILES') ? FileList[ENV['FILES']] : inventory.lib_files }
    self.globals = options.fetch(:globals, {})
    yield self if block_given?
    define
  end

  # Defines the following tasks (html is actually whatever {#name} has been set
  # to):
  #
  # <dl>
  #   <dt>.yardopts (file)</dt>
  #   <dd>Create .yardopts file based on {#options}; depends on the file
  #   defining this task and Rakefile.</dd>
  #
  #   <dt>html</dt>
  #   <dd>Generate documentation in HTML format for all {#files}, passing
  #   {#globals} to YARD; depends on .yardopts file.</dd>
  # </dl>
  def define
    desc 'Create .yardopts file'
    file '.yardopts' => [__FILE__, 'Rakefile'] do |t|
      tmp = '%s.tmp' % t.name
      rm([t.name, tmp], :force => true)
      rake_output_message 'echo %s > %s' % [options.join(' '), tmp] if verbose
      File.open(tmp, 'wb') do |f|
        f.write options.join(' ')
      end
      chmod File.stat(tmp).mode & ~0222, tmp
      mv tmp, t.name
    end

    desc name == :html ?
      'Generate documentation in HTML format' :
      'Generate documentation for %s in HTML format' % name
    task name => '.yardopts' do
      require 'yard'
      yardoc = YARD::CLI::Yardoc.new
      yardoc.parse_arguments(*arguments)
      globals.each do |key, value|
        yardoc.options.globals.send '%s=' % key, value
      end
      rake_output_message 'yard doc %s' % Shellwords.shelljoin(arguments(yardopts(yardoc))) if verbose
      yardoc.run(nil)
    end
  end

  # @param [Symbol] value
  # @return [Symbol] The name to use for the task: VALUE
  attr_accessor :name

  # @param [Array<String, Array<String>>] value
  # @return [Array<String, Array<String>>] The options to pass to YARD: VALUE
  attr_accessor :options

  # @param [Inventory] value
  # @return [Inventory] The inventory to use: VALUE
  attr_accessor :inventory

  # @param [Array<String>] value
  # @return [Array<String>] The files to process: VALUE
  attr_accessor :files

  # @param [Hash] value
  # @return [Hash] The globals to pass to YARD: VALUE
  attr_accessor :globals

  private

  def read(type)
    File.open('.yardopts.%s' % type, 'rb', &:read)
  rescue Errno::ENOENT
    nil
  end

  def arguments(additional = [])
    additional.
      concat(Shellwords.split(read('html') || '')).
      concat(Shellwords.split(ENV['OPTIONS'] || '')).
      push('--').
      concat(files)
  end

  def yardopts(yardoc)
    yardoc.use_yardopts_file ?
      Shellwords.split(File.open(yardoc.options_file, 'rb', &:read)) :
      []
  rescue Errno::ENOENT
    []
  end
end
