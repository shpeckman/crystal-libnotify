# src/libnotify/notification.cr
require "box"
require "./c"

class Libnotify::Notification
  getter notify      : C::NotifyNotification*
  property summary   : String?
  property body      : String?
  property icon_path : String?
  property app_name  : String
  property timeout   : Int32
  property category  : String?
  property append    : Bool
  property transient : Bool
  property urgency   : Libnotify::C::NotifyUrgency

  # Keep a reference to the blocks so the Garbage Collector doesn't free them
  # while the native C library might still try to call them.
  @action_callbacks = [] of Proc(Nil)

  def initialize(@summary = nil, @body = nil, @icon_path = nil,
                 @timeout = -1, @category = nil, @urgency = Libnotify::C::NotifyUrgency::NotifyUrgencyNormal,
                 @append = false, @transient = true,
                 @app_name = "default")
    init_app!
    @notify = new_notification(@summary, @body, @icon_path)
    update!
  end

  def initialize(@summary = nil, @body = nil, @icon_path = nil,
                 @timeout = -1, @category = nil, @urgency = Libnotify::C::NotifyUrgency::NotifyUrgencyNormal,
                 @append = false, @transient = true,
                 @app_name = "default", &block)
    init_app!
    @notify = new_notification(@summary, @body, @icon_path)
    yield self
    update!
  end

  def update(@summary = nil, @body = nil, @icon_path = nil,
             @timeout = -1, @category = nil, @urgency = Libnotify::C::NotifyUrgency::NotifyUrgencyNormal,
             @append = false, @transient = true,
             @app_name = "default", &block)
    yield self
    update!
  end

  def update(@summary = nil, @body = nil, @icon_path = nil,
             @timeout = -1, @category = nil, @urgency = Libnotify::C::NotifyUrgency::NotifyUrgencyNormal,
             @append = false, @transient = true,
             @app_name = "default")
    update!
  end

  def show
    update!
    C.notification_show(@notify, nil)
    self
  end

  def close
    C.notification_close(@notify, nil)
  end

  def closed_reason : Int32
    C.notification_get_closed_reason(@notify)
  end

  def add_action(action_key : String, label : String, &block : ->)
    @action_callbacks << block
    boxed_data = Box.box(block)

    callback = ->(n : C::NotifyNotification*, action : LibC::Char*, user_data : Void*) {
      Box(Proc(Nil)).unbox(user_data).call
    }

    free_func = ->(user_data : Void*) {
      # No-op: Crystal's Boehm GC handles memory automatically.
      # We just provide an empty callback to satisfy the C signature.
    }

    C.notification_add_action(@notify, action_key, label, callback, boxed_data, free_func)
  end

  def clear_actions
    @action_callbacks.clear
    C.notification_clear_actions(@notify)
  end

  def timeout=(sec : Float::Primitive)
    @timeout = (sec * 1000).round.to_i
  end

  def urgency=(urgency : Symbol)
    @urgency = case urgency
               when :low
                 Libnotify::C::NotifyUrgency::NotifyUrgencyLow
               when :normal
                 Libnotify::C::NotifyUrgency::NotifyUrgencyNormal
               when :critical
                 Libnotify::C::NotifyUrgency::NotifyUrgencyCritical
               else
                 raise "Invalid NotifyUrgency"
               end
  end

  def icon_pixbuf=(pixbuf : Pointer(Void) | Libnotify::C::GdkPixbuf)
    C.notification_set_icon_from_pixbuf(@notify, pixbuf.as(Libnotify::C::GdkPixbuf))
  end

  def image_pixbuf=(pixbuf : Pointer(Void) | Libnotify::C::GdkPixbuf)
    C.notification_set_image_from_pixbuf(@notify, pixbuf.as(Libnotify::C::GdkPixbuf))
  end

  private def update!
    summary, body = ensure_nonempty(@summary, @body)
    C.notification_update(@notify, summary.to_s, body.to_s, @icon_path.to_s)
    C.notification_set_timeout(@notify, @timeout)
    C.notification_set_urgency(@notify, @urgency)
    C.notification_set_category(@notify, @category.to_s)
    C.notification_set_app_name(@notify, @app_name)

    C.notification_set_hint_int32(@notify, "transient", @transient ? 1 : 0)

    if @append
      C.notification_set_hint_string(@notify, "x-canonical-append", "true")
    else
      C.notification_set_hint_string(@notify, "x-canonical-append", "false")
    end

    self
  end

  private def init_app!
    C.init(@app_name) if C.is_initted == 0
    C.set_app_name(@app_name) if C.get_app_name != @app_name
  end

  private def new_notification(summary, body, icon_path)
    summary, body = ensure_nonempty(summary, body)
    C.notification_new(summary.to_s, body.to_s, icon_path.to_s)
  end

  private def ensure_nonempty(summary, body)
    summary = " " if summary.nil? || summary.empty?
    body    = " " if body.nil? || body.empty?
    return summary, body
  end
end
