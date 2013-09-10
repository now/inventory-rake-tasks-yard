# -*- coding: utf-8 -*-

require 'inventory-1.0'

class Inventory::Rake::Tasks::YARD
  Version = Inventory.new(1, 4, 2){
    authors{
      author 'Nikolai Weibull', 'now@disu.se'
    }

    homepage 'http://disu.se/software/inventory-rake-tasks-yard-1.0/'

    licenses{
      license 'LGPLv3+',
              'GNU Lesser General Public License, version 3 or later',
              'http://www.gnu.org/licenses/'
    }

    def dependencies
      super + Inventory::Dependencies.new{
        development 'lookout', 3, 0, 0
        development 'lookout-rake', 3, 1, 0
        development 'yard-heuristics', 1, 2, 0
        runtime 'inventory-rake', 1, 6, 0
        runtime 'rake', 10, 0, 0, :feature => 'rake'
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
