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

    let(:global_config) { Class.new(GlobalConfig).instance }

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

    it "should be returned with host name appended from global config" do
      global_config.add_config("host_url", "http://requestb.in")
      api = WebApi.new(global_config).init("sample", "/sample") { method :get }

      expect(api.url).to eq("http://requestb.in/sample")
    end

    it "should be formatted to remove redundant slashes" do
      global_config.add_config("host_url", "http://requestb.in/")
      api = WebApi.new(global_config).init("sample", "/sample") { method :get }

      expect(api.url).to eq("http://requestb.in/sample")
    end

    it "should be only relative url when host url is not present" do
      api = WebApi.new(global_config).init("sample", "/sample") { method :get }

      expect(api.url).to eq("/sample")
    end

    it "should be interpolated with passed in hash to dynamically poplate values" do
      api = WebApi.new(global_config).init("sample", "/sample/%{id}/%{name}") { method :get }

      expect(api.url({id: "1", "name": "twilo"})).to eq("/sample/1/twilo")
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
        headers :"content-type" => "application/json", "content-type" => "text/html"
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

    it "should have keys converted to a symbol" do
      api = WebApi.new(global_config).init("sample", "/sample") do
        method :get
        headers "content-type" => "application/json"
      end

      expect(api.http_headers).to eq({:"content-type" => "application/json"})
    end

    it "should allow for dynamic header values" do
      global_config.add_config("dynamic_headers", {:"request_id" => Proc.new() { "123" }})

      expect(api.http_headers).to eq({:request_id=>"123", :"content-type"=>"application/json"})
    end

    it "should override dynamic headers with scoped headers" do
      global_config.add_config("dynamic_headers", {:"request_id" => Proc.new() { "123" }})
      api = WebApi.new(global_config).init("sample", "/sample") do
        method :get
        headers "request_id" => "1111"
      end

      expect(api.http_headers).to eq({:request_id=>"1111"})
    end

  end

  context "response handler" do

    class TestHandler
    end

    module Test
      class ModuleHandler
      end
    end

    it "should accept a handler class name" do
      api = WebApi.new.init("sample", "/sample") do
        method :get
        response_handler TestHandler
      end
      expect(api.handler).to eq(TestHandler)
    end

    it "should accept name of response handler as string" do
      api = WebApi.new.init("sample", "/sample") do
        method :get
        response_handler "TestHandler"
      end
      expect(api.handler).to eq(TestHandler)
    end

    it "should resolve handler with module in string name" do
      api = WebApi.new.init("sample", "/sample") do
        method :get
        response_handler "Test::ModuleHandler"
      end
      expect(api.handler).to eq(Test::ModuleHandler)
    end

    it "should assign default handler when not provided" do
      api = WebApi.new.init("sample", "/sample") do
        method :get
      end
      expect(api.handler).to eq(Handlers::Default)
    end

    it "should assign default handler when provided handler not found" do
      api = WebApi.new.init("sample", "/sample") do
        method :get
        response_handler "NonExistent"
      end
      expect(api.handler).to eq(Handlers::Default)
    end

    it "should assign default handler when non class object is assigned as handler" do
      api = WebApi.new.init("sample", "/sample") do
        method :get
        response_handler Test
      end
      expect(api.handler).to eq(Handlers::Default)
    end

  end



end
