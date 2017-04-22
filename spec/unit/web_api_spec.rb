require_relative '../spec_helper'

describe WebApi do

  context "method name" do

    it "should be configured from method" do
      api = WebApi.new.init("sample", "/sample") { method :get}

      expect(api.http_method).to eq(:get)
    end

    it "should be converted in sym format" do
      api = WebApi.new.init("sample", "/sample") { method "GET"}

      expect(api.http_method).to eq(:get)
    end

    it "should be accepted if a valid HTTP method" do
      [:get, :post, :put, :patch, :delete].each do |http_method|
        api = WebApi.new.init("sample", "/sample") { method http_method }

        expect(api.http_method).to eq(http_method)
      end
    end

    it "should be rejected if not a valid HTTP method" do
      api = WebApi.new.init("sample", "/sample") { method :unknown }

      expect(api.valid?).to be false
    end

  end

  context "url" do

    it "should be configured from url value" do
      api = WebApi.new.init("sample", "/sample")

      expect(api.url).to eq("/sample")
    end

    it "should be accepted only if present" do
      api = WebApi.new.init("sample", "/sample") { method :get }

      expect(api.valid?).to be true
    end

    it "should be rejected if not present" do
      ["", nil, "    "].each do |url|
        api = WebApi.new.init("sample", url) { method :get }

        expect(api.valid?).to be false
      end
    end

  end

  context "headers" do

    let!(:global_config) do
      Class.new(GlobalConfig).instance
    end

    let(:api) do
      WebApi.new(global_config).init("sample", "/sample") do
        method :get
        headers :"content-type" => "application/json"
      end
    end

    let(:api_with_dup_headers) do
      WebApi.new.init("sample", "/sample") do
        method :get
        headers :"content-type" => "application/json", :"content-type" => "text/html"
      end
    end

    it "should be set when supplied" do
      expect(api.http_headers).to include(:"content-type" => "application/json")
    end

    it "should merge duplicate values" do
      expect(api_with_dup_headers.http_headers).to include({:"content-type" => "text/html"})
    end

    it "should merge headers with global headers" do
      global_config.add_config("headers", {"authorization": "OAuth 1234"})

      expect(api.http_headers).to include({:"content-type" => "application/json"})
      expect(api.http_headers).to include({:authorization => "OAuth 1234"})
    end

    it "from api config should override global header" do
      global_config.add_config("headers", {:"content-type" => "application/xml"})

      expect(api.http_headers.size).to eq(1)
      expect(api.http_headers).to include({:"content-type" => "application/json"})
    end

    it "should be converted to keep keys as symbol" do
      api = WebApi.new(global_config).init("sample", "/sample") do
        method :get
        headers "content-type" => "application/json"
      end

      expect(api.http_headers).to eq({:"content-type" => "application/json"})
    end

  end

end
