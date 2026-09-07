# spec/libnotify_spec.cr
require "./spec_helper"

describe Libnotify do
  it "delegates .new to Notification.new w/o block" do
    Libnotify.new(summary: "no block", body: "hello").show
  end

  it "delegates .new to Notification.new with block" do
    Libnotify.new do |notify|
      notify.summary = "with block"
      notify.body = "hello2"
    end.show
  end

  it "creates and shows w/o block" do
    Libnotify.show(summary: "no block", body: "hello")
  end

  it "creates and shows with block" do
    Libnotify.show do |n|
      n.summary = "with block"
      n.body = "hello2"
    end
  end

  it "can fetch server caps" do
    caps = Libnotify.server_caps
    caps.should be_a(Array(String))
  end

  it "can fetch server info" do
    info = Libnotify.server_info
    if info
      info[:name].should be_a(String | Nil)
      info[:vendor].should be_a(String | Nil)
      info[:version].should be_a(String | Nil)
      info[:spec].should be_a(String | Nil)
    else
      info.should be_nil
    end
  end

  it "can uninit" do
    Libnotify.uninit
    Libnotify.new("test after uninit").show
  end
end
