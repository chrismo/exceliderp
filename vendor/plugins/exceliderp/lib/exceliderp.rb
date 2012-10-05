Mime::Type.register 'application/vnd.ms-excel', :xls

require 'action_controller/mime_responds'

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
  def template_format_with_xls_handling
    value = template_format_without_xls_handling
    value == :xls ? :html : value
  end
end

# The default HTML rendering will include the layout, so here we intercept the options during normalization and if we
# know we started with an xls requested format, we force the layout to not be rendered.
module XlsSupport
  def pick_layout(options)
    xls_requested? ? nil : super
  end

  def xls_requested?
    request.params[:format] == Mime::XLS.to_sym.to_s
  end
end

# Strip it down to just the table and inject the meta tag to support utf8 extended characters.
module XlsRenderSupport
  def encoding_meta_tag
    '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
  end

  def render_with_xls_handling(options = nil, extra_options = {}, &block)
    content = render_without_xls_handling(options, extra_options, &block)
    if xls_requested?
      body = self.response.body
      self.response.content_type = Mime::XLS.to_s
      self.response.body = encoding_meta_tag + body.scan(/<table.*\/table>/mi).join
    end
    content
  end
end

class ActionController::Base
  include XlsSupport
  include XlsRenderSupport

  alias_method_chain :render, :xls_handling
end

class ActionView::Base
  include XlsContextSupport

  alias_method_chain :template_format, :xls_handling
end