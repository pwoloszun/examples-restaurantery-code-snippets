require 'spec_helper'
require 'mocks_helper'

describe RestaurantConfigurationController do

  before(:each) do
    mock_logged_in_user
    should_find_restaurant_by_id
    should_instantiate_new_tables_set
  end

  describe "GET #show_configuration" do

    before(:each) do
      get :show_configuration, :restaurant_id => restaurant_id
    end

    it "should set restaurant" do
      assigns[:restaurant].should == restaurant
    end

    it "should set new tables set" do
      assigns[:new_tables_set].should == new_tables_set
    end

  end

  describe "PUT #submit_configuration" do

    before(:each) do
      restaurant_configuration_update succeeds
      submit_configuration
    end

    context "configuration successfully updated" do
      let(:succeeds) { true }

      it "should save configuration and redirect to show configuration" do
        should_redirect_to_show_configuration
      end

      it "should add information message" do
        should_add_information_flash_message "restaurant_configuration.saved"
      end

    end

    context "configuration update fails" do
      let(:succeeds) { false }

      it "should show configuration" do
        response.should render_template(:show_configuration)
      end

      it "should set error message" do
        should_add_error_message "restaurant_configuration.validation_errors_present"
      end

    end

    def restaurant_configuration_update succeeds_or_fails
      restaurant.should_receive(:update_attributes).with(submitted_configuration).and_return(succeeds_or_fails)
    end

    def submit_configuration
      put :submit_configuration, :restaurant_id => restaurant_id, :restaurant => submitted_configuration
    end

  end

  describe "POST #add_tables_set" do

    after(:each) do
      should_redirect_to_show_configuration
      should_add_information_flash_message "restaurant_configuration.tables_set_added"
    end

    context "new tables set" do

      it "should add tables set to restaurant" do
        restaurant.should_receive(:tables_set_for).with(capacity).and_return(nil)
        restaurant.should_receive(:add_tables).with(count, capacity)
        post :add_tables_set, :restaurant_id => restaurant_id, :tables_set => tables_set_params
      end

    end

    context "existing tables set" do

      it "should update tables set to restaurant" do
        tables_set = mock_model(TablesSet).as_null_object
        restaurant.should_receive(:tables_set_for).with(capacity).and_return(tables_set)
        tables_set.should_receive(:count=).with(count)
        tables_set.should_receive(:save)
        post :add_tables_set, :restaurant_id => restaurant_id, :tables_set => tables_set_params
      end

    end

    let(:count) { 2 }
    let(:capacity) { 11 }
    let(:tables_set_params) { {"capacity" => capacity.to_s, "count" => count.to_s} }

  end

  def should_instantiate_new_tables_set
    TablesSet.should_receive(:new).and_return(new_tables_set)
  end

  def should_redirect_to_show_configuration
    response.should redirect_to restaurant_configuration_path(:restaurant_id => restaurant_id)
  end

  let(:restaurant_id) { "denis" }
  let(:restaurant) { mock_model(Restaurant, :restaurant_id => restaurant_id).as_null_object }
  let(:new_tables_set) { mock_model(TablesSet).as_new_record.as_null_object }
  let(:submitted_configuration) { {"name" => "Denis", "telephone" => "222-22-22", "city" => "San Diego"} }

end
