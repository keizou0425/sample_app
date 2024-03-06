require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  it "full title helper" do
    title = "home"
    expect(full_title(title)).to eq "home | Ruby on Rails Tutorial Sample App"
  end
end
