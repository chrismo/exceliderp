ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action.:format', :defaults => {:format => 'html'}
end
