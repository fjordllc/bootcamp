require 'spec_helper'

describe "Companies" do
  describe "GET /companies" do
    it "works!" do
      get companies_path
      response.status.should be(200)
    end
  end
end
