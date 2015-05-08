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

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :chrome_debug do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, args: [
    '--verbose',
    "--log-path=#{App.paths.tmp.join('capybara.log')}"
  ])
end

Capybara.add_selector(:css) do
  css { |css| 'html /deep/' + css }
end

Capybara.app = App.endpoint

# Capybara.javascript_driver = :selenium
Capybara.javascript_driver = :chrome_debug
# Capybara.javascript_driver = :poltergeist_debug

Capybara.save_and_open_page_path = App.paths.tmp.join('screenshots')
