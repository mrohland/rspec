module Spec
  module Matchers
    class Matcher
      include Spec::Matchers::Pretty
      
      attr_reader :expected, :actual
      
      def initialize(name, *expected, &declarations)
        @name = name
        @expected = expected
        @diffable = false
        @messages = {
          :description => lambda {"#{name_to_sentence}#{expected_to_sentence}"},
          :failure_message_for_should => lambda {|actual| "expected #{actual.inspect} to #{name_to_sentence}#{expected_to_sentence}"},
          :failure_message_for_should_not => lambda {|actual| "expected #{actual.inspect} not to #{name_to_sentence}#{expected_to_sentence}"}
        }
        # NOTE - for reasons I don't yet understand, documenting methods declared
        # while evaluating the &declarations block and then treating them as public
        # via method_missing, is necessary in practical use, as demonstrated in
        # in define_matcher_with_fluent_interface.feature, but it is not necessary
        # within the matcher_spec. In other words, if this is removed, all of the
        # matcher specs will still pass, but the feature will fail and the behaviour
        # won't actually work. And then some users will be unhappy. So don't change
        # it.
        documenting_declared_methods do
          instance_exec(*@expected, &declarations)
        end
      end
      
      def matches?(actual)
        @actual = actual
        instance_exec(@actual, &@match_block)
      end
      
      def description(&block)
        cache_or_call_cached(:description, &block)
      end
      
      def failure_message_for_should(&block)
        cache_or_call_cached(:failure_message_for_should, @actual, &block)
      end
      
      def failure_message_for_should_not(&block)
        cache_or_call_cached(:failure_message_for_should_not, @actual, &block)
      end
      
      def match(&block)
        @match_block = block
      end
      
      def diffable?
        @diffable
      end
      
      def diffable
        @diffable = true
      end
            
    private

      def method_missing(m, *a, &b)
        if declared? m
          __send__(m, *a, &b)
        else
          super
        end
      end

      def documenting_declared_methods # :nodoc:
        orig_private_methods = private_methods
        yield
        @declared_methods = private_methods - orig_private_methods
      end

      def declared?(m)
        @declared_methods.grep(/#{m}/)
      end

      def cache_or_call_cached(key, actual=nil, &block)
        block ? @messages[key] = block : 
                actual.nil? ? @messages[key].call : @messages[key].call(actual)
      end
    
      def name_to_sentence
        split_words(@name)
      end
      
      def expected_to_sentence
        to_sentence(@expected)
      end
    
    end
  end
end