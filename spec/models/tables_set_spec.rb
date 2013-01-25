require 'spec_helper'

describe TablesSet do

  let(:tables_set) {TablesSet.new}

  describe "#empty?" do

    it "should return true when tables count is 0" do
      tables_set.count = 0
      tables_set.empty?.should be_true
    end

    it "should return false when tables count is > 0" do
      tables_set.count = 4
      tables_set.empty?.should be_false
    end

  end

  describe "#total_capacity" do

    it "should return 0 when count or capacity is nil" do
      tables_set.total_capacity.should == 0
    end

  end

  describe "#remove_one_table_from_set" do

    it "should decrease tables count by 1" do
      tables_set.count = 4
      tables_set.remove_one_table_from_set
      tables_set.count.should == 3
    end

    it "should not decrease tables count if table set is empty" do
      tables_set.count = 0
      tables_set.remove_one_table_from_set
      tables_set.count.should == 0
    end

  end

  describe "valid?" do

    before(:each) do
      tables_set.count = 10
      tables_set.capacity = 2
    end

    it "should be invalid when capacity and count are not numbers" do
      should_be_invalid_when {tables_set.count = "aaa"}
      should_be_invalid_when {tables_set.capacity = "aaa"}
    end

    it "should be invalid when capacity is not positive" do
      should_be_invalid_when {tables_set.capacity = 0}
      should_be_invalid_when {tables_set.capacity = -1}
    end

    it "should be invalid when count or capacity are nil" do
      should_be_invalid_when {tables_set.count = nil}
      should_be_invalid_when {tables_set.capacity = nil}
    end

    it "should be invalid when count or capacity are empty strings" do
      should_be_invalid_when {tables_set.count = ""}
      should_be_invalid_when {tables_set.capacity = ""}
    end

    it "should be invalid when count is less than zero" do
      should_be_invalid_when {tables_set.count = -1}
    end

    def should_be_valid_when
      yield
      tables_set.should be_valid
    end

    def should_be_invalid_when
      yield
      tables_set.should_not be_valid
    end

  end

end
