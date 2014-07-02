module ControllerHelpers
  def session
    env['rack.session']
  end

  def current_identity
    @current_identity ||= begin
      Identity.includes(:user).find_by(slug: session[:iid]) if session[:iid]
    end
  end

  def current_user
    current_identity.try(:user)
  end

  def authorized?
    !!current_user
  end

  def authenticated?
    !!current_identity
  end

  # Was hoping to have auth required by default and require
  # actions to opt out through route definition options ex. get '/foo', auth: false
  # but this proved non-trivial
  def require_auth
    (authorized? && authenticated?) || halt(401)
  end

  def require_authorization
    authorized? || halt(403)
  end

  def require_authentication
    authenticated? || halt(401)
  end
end