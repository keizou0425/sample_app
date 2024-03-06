require 'rails_helper'

RSpec.describe type: :request do

  it "new user" do
    get signup_path
    expect(response).to have_http_status(200)
  end
end
