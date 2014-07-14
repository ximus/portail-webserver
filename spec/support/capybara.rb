poltergeist_opts = {
  extensions: [
    # https://github.com/ariya/phantomjs/issues/10522
    App.paths.tests.join('support/bind-polyfill.js').to_s
  ]
}
Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    poltergeist_opts.merge(inspector: true, debug: true)
  )
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, poltergeist_opts)
end

# Capybara.register_driver :selenium_chrome do |app|
#   Capybara::Selenium::Driver.new(app, browser: :chrome)
# end

Capybara.app = App.endpoint

# Capybara.javascript_driver = :selenium
Capybara.javascript_driver = :poltergeist
# Capybara.javascript_driver = :poltergeist_debug

Capybara.save_and_open_page_path = App.paths.tmp.join('test')