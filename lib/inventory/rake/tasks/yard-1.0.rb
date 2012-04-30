# -*- coding: utf-8 -*-

# Namespace for Inventory, see {http://disu.se/software/inventory}.
class Inventory; end

# Namespace for Rake integration of Inventory, see
# {http://disu.se/software/inventory-rake}.
module Inventory::Rake
end

# Namespace for Rake tasks.
module Inventory::Rake::Tasks
end

class Inventory::Rake::Tasks::YARD
  load File.expand_path('../yard/version.rb', __FILE__)
  Version.load

  include Rake::DSL

  def initialize(options = {})
    self.name = options.fetch(:name, :html)
    self.options = options.fetch(:options,
                                 ['--no-private',
                                  '--protected',
                                  '--private',
                                  ['--query', '"(!object.docstring.blank?&&!(YARD::CodeObjects::NamespaceObject===object.namespace&&(a=object.namespace.aliases[object])&&object.name==:eql?&&a==:==)&&!(object.visibility!=:public&&((@return.text==\'\'&&@return.types==%w\'Boolean\')||object.docstring.start_with?(\'Returns the value of attribute \', \'Sets the attribute \')||(@raise&&@raise.types=[]))))||object.root?"'],
                                  ['--markup', 'markdown'],
                                  '--no-stats'])
    self.inventory = options.fetch(:inventory, Inventory::Rake::Tasks.inventory)
    self.files = options.fetch(:files){ ENV.include?('FILES') ? FileList[ENV['FILES']] : inventory.lib_files }
    self.globals = options.fetch(:globals, {})
    yield self if block_given?
    define
  end

  attr_accessor :name, :options, :files, :inventory, :globals

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
      yardoc.options.merge! globals
      Rake.rake_output_message 'yard doc %s' % Shellwords.shelljoin(arguments(yardoc.yardopts.dup)) if verbose
      yardoc.run(nil)
    end
  end

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
end
