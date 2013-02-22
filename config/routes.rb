Exceliderp::Application.routes.draw do
  root :to => redirect('/reports/index')

  get ':controller(/:action(.:format))'
end
