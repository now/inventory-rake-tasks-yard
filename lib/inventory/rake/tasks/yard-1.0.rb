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
    self.options = options.fetch(:options, Shellwords.split('--no-private --protected --private --query "(!object.docstring.blank?&&!(YARD::CodeObjects::NamespaceObject===object.namespace&&(a=object.namespace.aliases[object])&&object.name==:eql?&&a==:==)&&!(object.visibility!=:public&&((@return.text==\'\'&&@return.types==%w\'Boolean\')||object.docstring.start_with?(\'Returns the value of attribute \', \'Sets the attribute \')||(@raise&&@raise.types=[]))))||object.root?" --markup markdown --no-stats'))
    self.options += Shellwords.split(ENV['OPTIONS']) if ENV.include? 'OPTIONS'
    self.inventory = options.fetch(:inventory, Inventory::Rake::Tasks.inventory)
    self.files = options.fetch(:files){ ENV.include?('FILES') ? FileList[ENV['FILES']] : inventory.lib_files }
    self.globals = options.fetch(:globals, {})
    yield self if block_given?
    define
  end

  attr_accessor :name, :options, :files, :inventory, :globals

  def define
    desc name == :html ?
      'Generate documentation in HTML format' :
      'Generate documentation for %s in HTML format' % name
    task name do
      require 'yard'
      yardoc = YARD::CLI::Yardoc.new
      yardoc.parse_arguments(*arguments)
      yardoc.options.merge! globals
      Rake.rake_output_message 'yard doc %s' % Shellwords.join(arguments(yardoc.yardopts)) if verbose
      yardoc.run(nil)
    end
  end

  private

  def arguments(additional = [])
    options.dup.concat(additional).push('--').concat(files)
  end
end
