# -*- coding: utf-8 -*-

require 'inventory-1.0'

class Inventory::Rake::Tasks::YARD
  Version = Inventory.new(1, 2, 0){
    def dependencies
      super + Inventory::Dependencies.new{
        development 'lookout', 3, 0, 0
        development 'lookout-rake', 3, 0, 0
        runtime 'inventory-rake', 1, 3, 0
        optional 'rake', 0, 9, 2
        optional 'yard', 0, 7, 0
      }
    end

    def requires
      %w'
        rake
        shellwords
      '
    end
  }
end
