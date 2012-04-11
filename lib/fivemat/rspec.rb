require 'rspec/core/formatters/progress_formatter'

module Fivemat
  class RSpec < ::RSpec::Core::Formatters::ProgressFormatter
    def initialize(*)
      super
      @group_level = 0
      @index_offset = 0
    end

    def example_group_started(group)
      if @group_level.zero?
        output.print "#{group.description} "
        @failure_output = []
      end
      @group_level += 1
    end

    def example_group_finished(group)
      @group_level -= 1
      if @group_level.zero?
        output.puts
        failed_examples.each_with_index do |example, index|
          if pending_fixed?(example)
            dump_pending_fixed(example, @index_offset + index)
          else
            dump_failure(example, @index_offset + index)
          end
          dump_backtrace(example)
        end
        @index_offset += failed_examples.size
        failed_examples.clear
      end
    end

    def start_dump
      # Skip the call to output.puts in the messiest way possible.
      self.class.superclass.superclass.instance_method(:start_dump).bind(self).call
    end
  end
end
