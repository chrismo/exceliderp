Mime::Type.register 'application/vnd.ms-excel', :xls

require 'action_controller/metal/mime_responds'

# this defaults the respond_to Collector instance to have Mime::XLS as the first mime type to respond to, so controllers
# do not have to define the xls format. See ActionController::MimeResponds#retrieve_response_from_mimes for where the
# request's format (xls - the extension/:format from the route/url) is matched up to what the controller will respond to
# in the Collector.
class ActionController::MimeResponds::Collector
  def initialize(&block)
    @order, @responses, @default_response = [], {}, block
    custom(Mime::XLS)
  end
end

# The LookupContext will have the request's format passed into it (xls), unless we intervene in order to render the
# HTML template in its place.
module XlsContextSupport
  def formats=(value)
    super(value == [:xls] ? [:html] : value)
  end
end

# The default HTML rendering will include the layout, so here we intercept the options during normalization and if we
# know we started with an xls requested format, we force the layout to not be rendered.
module XlsSupport
  def _normalize_options(options)
    super
    options[:layout] = nil if xls_requested?
  end

  def xls_requested?
    request.formats.include?(Mime::XLS)
  end
end

# Strip it down to just the table and inject the meta tag to support utf8 extended characters.
module XlsRenderSupport
  def encoding_meta_tag
    '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
  end

  def render_to_body(*args, &block)
    content = super
    if xls_requested?
      self.content_type = Mime::XLS.to_s
      (encoding_meta_tag + content.scan(/<table.*\/table>/mi).join)
    else
      content
    end
  end
end

class ActionController::Base
  include XlsSupport
  include XlsRenderSupport
end

class ActionView::LookupContext
  include XlsContextSupport
end