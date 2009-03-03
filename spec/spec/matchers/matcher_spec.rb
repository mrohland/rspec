require File.dirname(__FILE__) + '/../../spec_helper'




module Spec
  module Matchers
    describe "#create" do
      context "telling #create what I want it to do" do
        it "returns true if I say so" do
          # FIXME - this expects new to be called, but we need something
          # more robust - that expects new to be called with a specific
          # block (lambda, proc, whatever)
          mod = Module.new
          mod.extend Spec::DSL::Matchers
          mod.create(:foo)
          
          Spec::Matchers::Matcher.should_receive(:new).with(:foo, 3)
          
          mod.foo(3)
        end
      end
    end
    
    describe Spec::Matchers::Matcher do
      context "defaults" do
        before(:each) do
          @matcher = Spec::Matchers::Matcher.new(:be_a_multiple_of, 3) do |multiple|
            match do |actual|
              actual % multiple == 0
            end
          end
        end
        
        it "provides a default description" do
          @matcher.matches?(0)
          @matcher.description.should == "be a multiple of 3"
        end

        it "provides a default failure message for #should" do
          @matcher.matches?(8)
          @matcher.failure_message.should == "expected 8 to be a multiple of 3"
        end

        it "provides a default failure message for #should_not" do
          @matcher.matches?(9)
          @matcher.negative_failure_message.should == "expected 9 not to be a multiple of 3"
        end
      end
      
      context "overrides" do
        it "overrides the description" do
          matcher = Spec::Matchers::Matcher.new(:be_a_multiple_of, 3) do |multiple|
            match do |actual|
              actual % multiple == 0
            end
            description do
              "be a multiple of #{multiple}, dude"
            end
          end
          matcher.matches?(0)
          matcher.description.should == "be a multiple of 3, dude"
        end

        it "overrides the failure message for #should" do
          matcher = Spec::Matchers::Matcher.new(:be_a_multiple_of, 3) do |multiple|
            match do |actual|
              actual % multiple == 0
            end
            failure_message_for(:should) do |actual|
              "expected #{actual} to be a multiple of #{multiple}, dude"
            end
          end
          matcher.matches?(8)
          matcher.failure_message.should == "expected 8 to be a multiple of 3, dude"
        end
        
        it "overrides the failure message for #should_not" do
          matcher = Spec::Matchers::Matcher.new(:be_a_multiple_of, 3) do |multiple|
            match do |actual|
              actual % multiple == 0
            end
            failure_message_for(:should_not) do |actual|
              "expected #{actual} not to be a multiple of #{multiple}, dude"
            end
          end
          matcher.matches?(9)
          matcher.negative_failure_message.should == "expected 9 not to be a multiple of 3, dude"
        end
      end
      
      
      context "#new" do
        it "passes matches? arg to match block" do
          matcher = Spec::Matchers::Matcher.new(:ignore) do 
            match do |actual|
              actual == 5
            end
          end
          matcher.matches?(5).should be_true
        end

        it "exposes arg submitted through #new to matcher block" do
          matcher = Spec::Matchers::Matcher.new(:ignore, 4) do |expected|
            match do |actual|
              actual > expected
            end
          end
          matcher.matches?(5).should be_true
        end
      end
    end
  end
end