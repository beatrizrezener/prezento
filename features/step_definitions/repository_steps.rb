Given(/^I have a sample configuration with native metrics but without ranges$/) do
  reading_group = FactoryGirl.create(:reading_group, id: nil)
  reading = FactoryGirl.create(:reading, {id: nil, group_id: reading_group.id})
  @mezuro_configuration = FactoryGirl.create(:mezuro_configuration, id: nil)
  metric_configuration = FactoryGirl.create(:metric_configuration,
                                            {id: nil,
                                             metric: FactoryGirl.build(:loc),
                                             reading_group_id: reading_group.id,
                                             configuration_id: @mezuro_configuration.id,
                                             code: 'loc'})
end

Given(/^I have a sample configuration with native metrics$/) do
  reading_group = FactoryGirl.create(:reading_group, id: nil)
  reading = FactoryGirl.create(:reading, {id: nil, group_id: reading_group.id})
  @mezuro_configuration = FactoryGirl.create(:mezuro_configuration, id: nil)
  metric_configuration = FactoryGirl.create(:metric_configuration,
                                            {id: nil,
                                             metric: FactoryGirl.build(:loc),
                                             reading_group_id: reading_group.id,
                                             configuration_id: @mezuro_configuration.id,
                                             code: 'loc'})
  range = FactoryGirl.build(:mezuro_range, {id: nil, reading_id: reading.id, beginning: '-INF', :end => 'INF', metric_configuration_id: metric_configuration.id})
  range.save
end

Given(/^I have a sample repository within the sample project$/) do
  @repository = FactoryGirl.create(:repository, {project_id: @project.id,
                                                 configuration_id: @mezuro_configuration.id, id: nil})
end

Given(/^I have a sample repository within the sample project named "(.+)"$/) do |name|
  @repository = FactoryGirl.create(:repository, {project_id: @project.id,
                                                 configuration_id: @mezuro_configuration.id, id: nil, name: name})
end

Given(/^I start to process that repository$/) do
  @repository.process
end

Given(/^I wait up for a ready processing$/) do
  unless Processing.has_ready_processing(@repository.id)
    while(true)
      if Processing.has_ready_processing(@repository.id)
        break
      else
        sleep(10)
      end
    end
  end
end

Given(/^I am at the New Repository page$/) do
  visit new_project_repository_path(@project.id)
end

Given(/^I am at repository edit page$/) do
  visit edit_project_repository_path(@repository.project_id, @repository.id)
end

Given(/^I ask for the last ready processing of the given repository$/) do
  @processing = Processing.last_ready_processing_of @repository.id
end

Given(/^I ask for the module result of the given processing$/) do
  @module_result = ModuleResult.find @processing.results_root_id
end

Given(/^I ask for the metric results of the given module result$/) do
  @metric_results = @module_result.metric_results
end

Given(/^I see a sample metric's name$/) do
  expect(page).to have_content(@metric_results.first.metric_configuration_snapshot.metric.name)
end

When(/^I click on the sample metric's name$/) do
  find_link(@metric_results.first.metric_configuration_snapshot.metric.name).trigger('click')
end

When(/^I set the select field "(.+)" as "(.+)"$/) do |field, text|
  select text, from: field
end

When(/^I visit the repository show page$/) do
  visit project_repository_path(@project.id, @repository.id)
end

When(/^I click on the sample child's name$/) do
  click_link @module_result.children.first.module.name
end

When(/^I click the "(.*?)" h3$/) do |text|
  page.find('h3', text: text).click()
end

When(/^I wait up for the ajax request$/) do
  while (page.driver.network_traffic.last.response_parts.empty?) do
    sleep(10)
  end
end

When(/^I get the Creation date information as "(.*?)"$/) do |variable|
  val = page.find('p', text: 'Creation date').text.match(/^Creation date:(.*)$/).captures.first
  eval ("@#{variable} = '#{val}'")
end

Then(/^I should see the sample repository name$/) do
  expect(page).to have_content(@repository.name)
end

Then(/^the field "(.*?)" should be filled with "(.*?)"$/) do |field, value|
  expect(page.find_field(field).value).to eq(value)
end

Then(/^I should see the given module result$/) do
  expect(page).to have_content(@module_result.module.name)
end

Then(/^I should see a sample child's name$/) do
  expect(page).to have_content(@module_result.children.first.module.name)
end

Then(/^I should see the given repository's content$/) do
  expect(page).to have_content(@repository.type)
  expect(page).to have_content(@repository.description)
  expect(page).to have_content(@repository.name)
  expect(page).to have_content(@repository.license)
  expect(page).to have_content(@repository.address)
  expect(page).to have_content(@mezuro_configuration.name)
  expect(page).to have_content("1 day") # The given repository periodicity
end

Then(/^I should see a loaded graphic for the sample metric$/) do
  expect(page.all("canvas#container" + @metric_results.first.id.to_s)[0]).to_not be_nil
end

Then(/^I wait for "(.*?)" seconds or until I see "(.*?)"$/) do |timeout, text|
  start_time = Time.now
  while(page.html.match(text).nil?)
    break if (Time.now - start_time) >= timeout.to_f
    sleep 1
  end

  expect(page).to have_content(text)
end

Then(/^I wait for "(.*?)" seconds$/) do |timeout|
  sleep timeout.to_f
end

Then(/^I should see the saved repository's content$/) do
  @repository = Repository.all.last # suposing the last repository created is the only created too.
  expect(page).to have_content(@repository.type)
  expect(page).to have_content(@repository.description)
  expect(page).to have_content(@repository.name)
  expect(page).to have_content(@repository.license)
  expect(page).to have_content(@repository.address)
  expect(page).to have_content(@mezuro_configuration.name)
end

Then(/^"(.*?)" should be less than "(.*?)"$/) do |arg1, arg2|
  v1 = eval "@#{arg1}"
  v2 = eval "@#{arg2}"
  expect(v1 < v2).to be_truthy
end
