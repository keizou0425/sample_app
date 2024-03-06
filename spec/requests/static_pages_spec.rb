require 'rails_helper'

RSpec.describe "Statuses", type: :request do
  let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  it "should get root" do
    get root_url
    expect(response).to have_http_status(200)
    expect(response.body).to include(full_title(""))
  end

  it "should get help" do
    get help_url
    expect(response).to have_http_status(200)
    expect(response.body).to include(full_title("Help"))
  end

  it "should get about" do
    get about_url
    expect(response).to have_http_status(200)
    expect(response.body).to include(full_title("About"))
  end

  it "should get contact" do
    get contact_url
    expect(response).to have_http_status(200)
    expect(response.body).to include(full_title("Contact"))
  end
end
