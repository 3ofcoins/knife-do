require 'spec_helper'

module KnifeTasks
  include Rake
  describe KnifeTasks do
    before do
       Dir.chdir(File.realpath(File.join(File.dirname(__FILE__), '../fixtures')))
    end

    it "shouldn't fail a smoke test" do
      expect { (2 + 2) == 4 }
    end

    it 'should properly recognize flags in the command line' do
      expect { `knife do -V`.include? "knife-do, version #{KnifeTasks::VERSION}" }
    end

    it 'should list all rake tasks in the project repository' do
      expect { `knife do`.include? "knife do task foo                # Task with an env variable\n" }
    end

    it 'should run the default task' do
      `knife do task `.must_equal "42\n"
    end

    it 'should perform a rake task without any arguments' do
      `knife do task meaning`.must_equal "42\n"
    end

    it 'should perform a rake task with environmental variables' do
      `knife do task foo FOO=3`.must_equal "variable = 3.\n"
    end

    it 'should execute ruby code' do
      `knife do task -e "p 2+2"`.must_equal "4\n"
    end
  end
end
