# gem wrongfully assumes we are using sinatra and messes up this path
module Capybara
  module Screenshot
    def self.capybara_root
      Capybara.save_and_open_page_path
    end
  end
end