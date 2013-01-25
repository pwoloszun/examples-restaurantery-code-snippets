class RestaurantConfigurationController < ApplicationController

  before_filter :require_authorization, :set_model

  def show_configuration
  end

  def submit_configuration
    if @restaurant.update_attributes params[:restaurant]
      add_information_flash_message("restaurant_configuration.saved")
      redirect_to_show_configuration
    else
      add_error_message("restaurant_configuration.validation_errors_present")
      render :show_configuration
    end
  end

  def add_tables_set
    capacity = params[:tables_set][:capacity].to_i
    count = params[:tables_set][:count].to_i
    existing_tables_set = @restaurant.tables_set_for(capacity)
    if (existing_tables_set.nil?)
      @restaurant.add_tables(count, capacity)
    else
      existing_tables_set.count = count
      existing_tables_set.save
    end
    add_information_flash_message("restaurant_configuration.tables_set_added")
    redirect_to_show_configuration
  end

  def remove_tables_set
    to_remove = @restaurant.tables_set_for(params[:capacity].to_i)
    @restaurant.tables_sets.delete(to_remove)
    redirect_to_show_configuration
  end

  private

  def set_model
    set_restaurant
    @new_tables_set = TablesSet.new
  end

  def redirect_to_show_configuration
    redirect_to restaurant_configuration_path(:restaurant_id => @restaurant.restaurant_id)
  end

end
