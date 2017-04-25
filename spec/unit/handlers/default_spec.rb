require 'spec_helper'

describe Handlers::Default do

  context "success" do

    let(:raw_response) { double(:response, body: "record created", code: 200) }
    subject { Handlers::Default.new(raw_response) }

    it "should return error occured as false" do
      expect(subject.error_occured?).to be false
    end

    it "should return the response as the value" do
      expect(subject.value).to eq("record created")
    end

    it "should return statuc code" do
      expect(subject.status).to eq(200)
    end

    it "should return the raw response" do
      resp = subject.raw_response

      expect(resp.body).to eq("record created")
      expect(resp.code).to eq(200)
    end

  end

  context "failure" do

    let(:raw_response) { double(:response, body: "server error", code: 400) }
    subject { Handlers::Default.new(raw_response) }

    it "should return true for error occured" do
      expect(subject.error_occured?).to be true
    end

    it "should return error response" do
      expect(subject.error_message).to eq("server error")
    end

    it "should return the status code" do
      expect(subject.status).to eq(400)
    end

    it "should return raw response" do
      resp = subject.raw_response

      expect(resp.body).to eq("server error")
      expect(resp.code).to eq(400)
    end

  end

end
