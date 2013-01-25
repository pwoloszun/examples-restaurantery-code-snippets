Given /^a restaurant called "([^"]*)"$/ do |name|
  @restaurant = Restaurant.new(:name => name, :restaurant_id => name.downcase)
  @restaurant.save!(:validate => false)
end

Given /^restaurant is fully configured$/ do
  define_opening_hours @restaurant, "08:00", "23:00"
  @restaurant.add_tables 6, 4
  @restaurant.save!
end

When /^I enter restaurant configuration page$/ do
  visit restaurant_configuration_path(:restaurant_id => @restaurant.restaurant_id)
end

When /^I enter restaurant street "([^"]*)"$/ do |street|
  @entered_street = street
  When "I fill in \"#{I18n.t("restaurant_configuration.street")}\" with \"#{street}\""
end

When /^I enter restaurant name "([^"]*)"$/ do |name|
  @entered_name = name
  When "I fill in \"#{I18n.t("restaurant_configuration.name")}\" with \"#{name}\""
end

When /^I enter restaurant city "([^"]*)"$/ do |city|
  @entered_city = city
  When "I fill in \"#{I18n.t("restaurant_configuration.city")}\" with \"#{city}\""
end

When /^I enter restaurant zip code "([^"]*)"$/ do |zip_code|
  @entered_zip_code = zip_code
  When "I fill in \"#{I18n.t("restaurant_configuration.zip_code")}\" with \"#{zip_code}\""
end

When /^I enter restaurant telephone "([^"]*)"$/ do |telephone|
  @entered_telephone = telephone
  When "I fill in \"#{I18n.t("restaurant_configuration.telephone")}\" with \"#{telephone}\""
end

When /^I enter restaurant tables sets:$/ do |table|
  @entered_tables_sets = []
  table.hashes.each() do |row|
    if row["count"].empty?
      count = ""
    else
      count = row["count"].to_i
    end
    capacity = row["capacity"].to_i
    @entered_tables_sets << TablesSet.new(:capacity => capacity, :count => count)
    When "I fill in \"#{ts_capacity_label(capacity)}\" with \"#{count}\""
  end
end

When /^I enter restaurant opening hours:$/ do |table|
  @entered_opening_hours_on_week_days = []
  table.hashes.each() do |row|
    week_day_number = row["week_day_number"].to_i
    if row["closed"].empty? && row["opened_24h"].empty?
      enter_opening_hours row, week_day_number
    else
      if row["closed"].empty?
        check_week_day week_day_number, :opened_24h
      else
        check_week_day week_day_number, :closed
      end
    end
  end
end

def enter_opening_hours row, week_day_number
  opened_from = row["opened_from"]
  opened_until = row["opened_until"]
  opened_from_parts = opened_from.split(":")
  opened_until_parts = opened_until.split(":")
  opening_hours_parts = opened_from_parts + opened_until_parts
  opening_hours_fields = opening_hours_fields_names week_day_number
  @entered_opening_hours_on_week_days << new_opening_hours(
      week_day_number,
      :opened_from_h => opened_from_parts[0],
      :opened_from_m => opened_from_parts[1],
      :opened_until_h => opened_until_parts[0],
      :opened_until_m => opened_until_parts[1]
  )
  (0..3).each() do |i|
    When "I select \"#{opening_hours_parts[i]}\" from \"#{opening_hours_fields[i]}\""
  end
end

def check_week_day week_day_number, check_box
  @entered_opening_hours_on_week_days << new_opening_hours(week_day_number, check_box => true)
  When "I check \"#{opening_hours_field_name(week_day_number, check_box.to_s)}\""
end

def new_opening_hours week_day_number, params
  OpeningHoursOnWeekDay.new(
      common_opening_hours_params(week_day_number).merge(params)
  )
end

def common_opening_hours_params(week_day_number)
  {:restaurant_id => @restaurant.id, :week_day_number => week_day_number}
end

When /^I press save configuration button$/ do
  When "I press \"#{I18n.t("restaurant_configuration.save_configuration")}\""
end

When /^I press add tables set button-link$/ do
  When "I follow \"#{I18n.t("restaurant_configuration.add_tables_set")}\""
end

When /^I press remove button-link within (\d+) people tables set$/ do |capacity|
  click_link_within("#tables_sets_list tr[@data-capacity='#{capacity}']", I18n.t("restaurant_configuration.remove_tables_set"))
end

When /^I check that I want to receive sms notifications$/ do
  @wants_to_receive_sms_notifications = true
  When "I check \"#{I18n.t("restaurant_configuration.wants_to_receive_sms_notifications")}\""
end

When /^I enter notifications telephone number "([^"]*)"$/ do |telephone_number|
  @sms_notifications_number = telephone_number
  When "I fill in \"#{I18n.t("restaurant_configuration.sms_notifications_number")}\" with \"#{telephone_number}\""
end

When /^I enter facebook page id "([^"]*)"$/ do |fb_page_id|
  @fb_page_id = fb_page_id
  When "I fill in \"#{I18n.t("restaurant_configuration.fb_page_id")}\" with \"#{fb_page_id}\""
end

Then /^I should be on restaurant configuration page$/ do
  Then "I should be on \"#{restaurant_configuration_path(:restaurant_id => @restaurant.restaurant_id)}\""
end

Then /^I should see new tables set dialog$/ do
  Then "I should be on restaurant configuration page"
  within "#new_tables_set_dialog" do
    Then "the \"restaurant_configuration.new_tables_set.capacity\" field should be empty"
    And "the \"restaurant_configuration.new_tables_set.count\" field should be empty"
    And "I should see button labeled \"#{I18n.t("restaurant_configuration.new_tables_set.confirm")}\""
  end
end

When /^I set capacity to (\d+), count to (\d+) and confirm dialog$/ do |capacity, count|
  When "I fill in \"#{I18n.t("restaurant_configuration.new_tables_set.capacity")}\" with \"#{capacity}\""
  And "I fill in \"#{I18n.t("restaurant_configuration.new_tables_set.count")}\" with \"#{count}\""
  And "I press \"#{I18n.t("restaurant_configuration.new_tables_set.confirm")}\""
end

Then /^I see configuration form with tables set containing (\d+) tables for (\d+) people$/ do |count, capacity|
  Then "the field labeled \"#{ts_capacity_label(capacity)}\" should contain \"#{count}\""
end

Then /^I see configuration form with name filled in$/ do
  Then "the \"restaurant_configuration.name\" field should contain \"#{@restaurant.name}\""
  And "the \"restaurant_configuration.street\" field should be empty"
  And "the \"restaurant_configuration.city\" field should be empty"
  And "the \"restaurant_configuration.telephone\" field should be empty"
  And "the \"restaurant_configuration.zip_code\" field should be empty"
  And "I should see \"#{I18n.t("restaurant_configuration.enter_tables")}\""
  And "tables sets fields should contain 0"
  And "I should see add tables set button-link"
  And "I should see \"#{I18n.t("restaurant_configuration.enter_opening_hours")}\""
  And "opening hours fields should be empty"
  And "the \"#{I18n.t("restaurant_configuration.wants_to_receive_sms_notifications")}\" checkbox should not be checked"
  And "the \"restaurant_configuration.sms_notifications_number\" field should be empty"
  And "the \"restaurant_configuration.fb_page_id\" field should be empty"
end

Then /^I should see add tables set button-link$/ do
  Then "I should see button-link labeled \"#{I18n.t("restaurant_configuration.add_tables_set")}\" with id add_tables_set"
end


Then /^tables sets fields should contain (\d+)$/ do |count|
  (1..@restaurant.tables_sets.size).each() do |capacity|
    Then "the #{capacity} person field should contain #{count}"
  end
end

Then /^the (\d+) person field should contain (\d+)$/ do |capacity, count|
  Then "the field labeled \"#{ts_capacity_label(capacity)}\" should contain \"#{count}\""
end

Then /^the (\d+) person field should be empty$/ do |capacity|
  Then "the field labeled \"#{ts_capacity_label(capacity)}\" should contain \"0\""
end

def ts_capacity_label capacity
  I18n.t("restaurant_configuration.table_capacity", :capacity => capacity)
end

Then /^opening hours fields should be empty$/ do
  (1..7).each() do |dow|
    Then "the #{dow} day of week opening field should be empty"
  end
end

Then /^the (\d) day of week opening field should be empty$/ do |dow_number|
  Then "I should see \"#{Class.new.extend(RestaurantConfigurationHelper).week_day_name dow_number.to_i}\""
  opening_hours_fields_names(dow_number.to_i).each() do |field_name|
    field_value(field_name).should be_empty
  end
end

def opening_hours_fields_names week_day_number
  [
      opening_hours_field_name(week_day_number, "opened_from_h"),
      opening_hours_field_name(week_day_number, "opened_from_m"),
      opening_hours_field_name(week_day_number, "opened_until_h"),
      opening_hours_field_name(week_day_number, "opened_until_m")
  ]
end

def opening_hours_field_name week_day_number, part_name
  "restaurant[opening_hours_on_week_days_attributes][#{week_day_number - 1}][#{part_name}]"
end

Then /^System saves configuration I have entered$/ do
  response.should be_successful
  Then "I should be on restaurant configuration page"
  And "displayed restaurant data should be stored in database"
  And "I should see \"#{I18n.t("restaurant_configuration.saved")}\""
end

Then /^displayed restaurant data should be stored in database$/ do
  restaurant_fetched_from_db = Restaurant.find(@restaurant.id)
  restaurant_fetched_from_db.name.should == @entered_name
  restaurant_fetched_from_db.telephone.should == @entered_telephone
  restaurant_fetched_from_db.city.should == @entered_city
  restaurant_fetched_from_db.zip_code.should == @entered_zip_code
  restaurant_fetched_from_db.street.should == @entered_street
  restaurant_fetched_from_db.opening_hours_on_week_days.should have_elements_with_same_values_as @entered_opening_hours_on_week_days
  restaurant_fetched_from_db.tables_sets.should == @entered_tables_sets
  restaurant_fetched_from_db.wants_to_receive_sms_notifications.should == @wants_to_receive_sms_notifications
  restaurant_fetched_from_db.sms_notifications_number.should == @sms_notifications_number
  restaurant_fetched_from_db.fb_page_id.should == @fb_page_id
end

def field_value name
  field_named(name).value || ""
end

Then /^I should see that name is required$/ do
  Then "I should see \"#{I18n.t("activerecord.errors.models.restaurant.attributes.name.blank")}\""
end

Then /^I should see that tables sets are required$/ do
  Then "I should see \"#{I18n.t("restaurant_configuration.validation_errors.tables_sets_required")}\""
end

Then /^I should see that opening hours on each day are required$/ do
  Then "I should see \"#{I18n.t("restaurant_configuration.validation_errors.opening_hours_required")}\""
end

Then /^I should see count should be a non\-negative integer$/ do
  Then "I should see \"#{I18n.t("activerecord.errors.models.tables_set.attributes.count.greater_than_or_equal_to")}\""
end

Then /^I should see that restaurant cannot be closed every day$/ do
  Then "I should see \"#{I18n.t("restaurant_configuration.validation_errors.closed_every_day")}\""
end

Then /^I should see there are configuration errors$/ do
  Then "I should see \"#{I18n.t("restaurant_configuration.validation_errors_present")}\""
end

Then /^I see configuration form without tables set for (\d+) people$/ do |capacity|
  Then "I should not see \"#{ts_capacity_label(capacity)}\" within \"#tables_sets_list\""
end

Then /^I should see I should enter sms notifications telephone number$/ do
  Then "I should see \"#{I18n.t("activerecord.errors.models.restaurant.attributes.sms_notifications_number.blank")}\""
end

Then /^I should see that telephone should contain 7 digits$/ do
  Then "I should see \"#{I18n.t("activerecord.errors.models.restaurant.attributes.sms_notifications_number.invalid")}\""
end