require 'rails_helper'

RSpec.describe "Statuses", type: :request do
  let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  it "should get root" do
    get root_url
    expect(response).to have_http_status(200)
    expect(response.body).to include("Home | #{base_title}")
  end

  it "should get home" do
    get static_pages_home_url
    expect(response).to have_http_status(200)
    expect(response.body).to include("Home | #{base_title}")
  end

  it "should get help" do
    get static_pages_help_url
    expect(response).to have_http_status(200)
    expect(response.body).to include("Help | #{base_title}")
  end

  it "should get about" do
    get static_pages_about_url
    expect(response).to have_http_status(200)
    expect(response.body).to include("About | #{base_title}")
  end

  it "should get contact" do
    get static_pages_contact_url
    expect(response).to have_http_status(200)
    expect(response.body).to include("Contact | #{base_title}")
  end
end
