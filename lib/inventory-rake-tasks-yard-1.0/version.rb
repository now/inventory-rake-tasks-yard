# -*- coding: utf-8 -*-

require 'inventory-1.0'

class Inventory::Rake::Tasks::YARD
  Version = Inventory.new(1, 3, 3){
    def dependencies
      super + Inventory::Dependencies.new{
        development 'lookout', 3, 0, 0
        development 'lookout-rake', 3, 0, 0
        development 'yard-heuristics', 1, 1, 0
        runtime 'inventory-rake', 1, 4, 0
        runtime 'rake', 0, 9, 2, :feature => 'rake'
        optional 'yard', 0, 8, 0
      }
    end

    def requires
      %w[shellwords]
    end

    def additional_libs
      super + %w[inventory/rake/tasks/yard-1.0.rb]
    end

    def unit_tests
      super - %w[inventory/rake/tasks/yard-1.0.rb]
    end
  }
end
