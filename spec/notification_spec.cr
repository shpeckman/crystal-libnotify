# spec/notification_spec.cr
require "./spec_helper"

describe Libnotify::Notification do
  it "initializes" do
    w = Libnotify::Notification.new("summary", "body")
    w.summary.should eq "summary"
    w.body.should eq "body"
  end

  it "initializes with block" do
    Libnotify::Notification.new do |notify|
      notify.summary = "hello"
      notify.body = "world"
      notify.timeout = 1.5
      notify.urgency = :critical
      notify.append = false
      notify.transient = true
      notify.icon_path = File.expand_path("images/crystal-120x120.png")
    end.show
  end

  it "initializes and updates" do
    n = Libnotify::Notification.new "update 1" do |n|
      n.body = "Should not be displayed"
    end
    n.body = "Should be displayed"
    n.show

    n = Libnotify::Notification.new "update 2 not displayed" do |n|
      n.body = "Should not be displayed"
    end
    n.update(body: "Should be displayed") do |n|
      n.summary = "update 2"
    end.show
  end

  it "default summary and body to an empty string" do
    Libnotify::Notification.new.show
    Libnotify::Notification.new(summary: "", body: "").show
  end

  it "can add and clear actions" do
    n = Libnotify::Notification.new("Action Test", "Testing actions")
    n.add_action("default", "Default Action") do
    end
    n.clear_actions
    n.show
  end

  it "can close programmatically and get reason" do
    n = Libnotify::Notification.new("Close Test", "Will be closed quickly")
    n.show
    n.close

    reason = n.closed_reason
    reason.should be_a(Int32)
  end

  it "can set pixbuf pointers" do
    n            = Libnotify::Notification.new("Pixbuf Test")
    null_pointer = Pointer(Void).null
    n.icon_pixbuf = null_pointer
    n.image_pixbuf = null_pointer
  end
end
