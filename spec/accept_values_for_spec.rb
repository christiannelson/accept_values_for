require 'spec_helper'

describe "AcceptValuesFor" do
  let(:person) { Person.new(:gender => "MALE", :group => Group.new(:name => "Primary")) }
  let(:accept_values_for_object) { accept_values_for(:gender, *values) }

  describe "#matches?" do
    subject { accept_values_for_object.matches?(person) }
    context "when value is accepted" do
      let(:values) { ['MALE'] }
      it { should eq(true) }
    end
    context "when value is not accepted" do
      let(:values) { ['INVALID'] }
      it { should eq(false) }
      it "should have correct failure message for should" do
        accept_values_for_object.matches?(person)
        accept_values_for_object.failure_message_for_should.should == "expected #{person.inspect} to accept values \"INVALID\" for :gender, but it was not\n\nValue: \"INVALID\"\tErrors: gender is not included in the list"
      end
      it "should assign the old value for attribute" do
        accept_values_for_object.matches?(person)
        person.gender.should == 'MALE'
      end
    end
    context "when 2 values are not accepted" do
      let(:values) { ["INVALID", "WRONG"] }
      it { should eq(false) }
      it "should have correct failure message for should" do
        accept_values_for_object.matches?(person)
        accept_values_for_object.failure_message_for_should.should == "expected #{person.inspect} to accept values \"INVALID\", \"WRONG\" for :gender, but it was not\n\nValue: \"INVALID\"\tErrors: gender is not included in the list\nValue: \"WRONG\"\tErrors: gender is not included in the list"
      end
    end
    context "when not accepte values of different types" do
      let(:values) { ['INVALID', nil, 1] }
      it { should eq(false) }
      it "should have correct failure message for should" do
        accept_values_for_object.matches?(person)
        accept_values_for_object.failure_message_for_should.should == <<MSG.strip
expected #{person.inspect} to accept values nil, 1, \"INVALID\" for :gender, but it was not

Value: nil\tErrors: gender is not included in the list
Value: 1\tErrors: gender is not included in the list
Value: \"INVALID\"\tErrors: gender is not included in the list
MSG
      end
    end
    context "when one value is accept and other is not" do
      let(:values) { ['MALE', 'INVALID'] }
      it { should eq(false) }
    end
  end

  describe "#does_not_match?" do
    subject { accept_values_for_object.does_not_match?(person) }
    context "when value is not accepted" do
      let(:values) { ['INVALID'] }
      it { should eq(true) }
    end
    context "when value is accepted" do
      let(:values) { ['FEMALE'] }
      it { should eq(false) }
      it "should have correct failure message for should" do
        accept_values_for_object.does_not_match?(person)
        accept_values_for_object.failure_message_for_should_not.should == "expected #{person.inspect} to not accept values \"FEMALE\" for :gender attribute, but was"
      end
      it "should assign the old value for attribute" do
        accept_values_for_object.does_not_match?(person)
        person.gender.should == 'MALE'
      end
    end
    context "when 2 values are accepted" do
      let(:values) { ["FEMALE", "MALE"] }
      it { should eq(false) }
      it "should have correct failure message for should" do
        accept_values_for_object.does_not_match?(person)
        accept_values_for_object.failure_message_for_should_not.should == "expected #{person.inspect} to not accept values \"FEMALE\", \"MALE\" for :gender attribute, but was"
      end
    end
    context "when one value is accept and other is not" do
      let(:values) { ['MALE', 'INVALID'] }
      it { should eq(false) }
    end
  end

  describe "api" do
    subject { person }
    it { should accept_values_for(:gender, "MALE", "FEMALE")}
    it { should_not accept_values_for(:gender, "INVALID", nil)}
    it { should_not accept_values_for(:group, nil) }
    it { should accept_values_for(:group, Group.new) }
  end
end
