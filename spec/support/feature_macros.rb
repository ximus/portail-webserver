module FeatureMacros
  def has_popup?
    # seems that for poltergeist, the main window is not in here at all
    page.driver.browser.window_handles.any?
  end

  def wait_for_oauth_popup
    # page.document.synchronize { not has_popup? }
    sleep 1
  end
end