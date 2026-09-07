# src/crystal-libnotify.cr
require "./libnotify/*"

module Libnotify
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  def self.new(*args, **options)
    Notification.new(*args, **options)
  end

  def self.new(*args, **options, &)
    Notification.new(*args, **options) { |n| yield n }
  end

  def self.show(*args, **options)
    new(*args, **options).show
  end

  def self.show(*args, **options, &)
    new(*args, **options) { |n| yield n }.show
  end

  def self.uninit
    C.uninit if C.is_initted != 0
  end

  def self.server_caps : Array(String)
    caps         = [] of String
    current_node = C.get_server_caps

    while current_node && !current_node.null?
      caps << String.new(current_node.value.data.as(LibC::Char*))
      current_node = current_node.value.next
    end
    caps
  end

  def self.server_info
    name = vendor = version = spec = Pointer(LibC::Char).null
    if C.get_server_info(pointerof(name), pointerof(vendor), pointerof(version), pointerof(spec)) != 0
      {
        name:    name.null? ? nil : String.new(name),
        vendor:  vendor.null? ? nil : String.new(vendor),
        version: version.null? ? nil : String.new(version),
        spec:    spec.null? ? nil : String.new(spec),
      }
    end
  end
end
