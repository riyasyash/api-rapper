require 'spec_helper'

describe Service do

  context "api call" do

    let(:config) { Class.new(GlobalConfig).instance }
    let(:service) { Class.new(Service).instance }

    let(:api) do
      WebApi.new(config).init("sample","/sample") do
          method :get
          headers :"content-type" => "application/json"
      end
    end

    let(:configure_api) do
      config.add_config("host_url", "http://requestb.in:")
      service.add_api("sample", api)
    end

    before(:each) do
      stub_request(:get, "http://requestb.in/sample").to_return(body: "abc", status: 200)
    end

    it "should call the api when it has been added" do
      configure_api
      response = service.sample

      headers = {"content-type" => "application/json"}
      url = "http://requestb.in/sample"
      expect(WebMock).to have_requested(:get, url).with(headers: headers).once
      expect(response.value).to eq("abc")
    end

    it "should raise error when api has not been configured" do
      configure_api
      expect {service.pop}.to raise_error(NoMethodError)
    end

  end

end
