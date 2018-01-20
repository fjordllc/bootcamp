class RequestRedirector
  OLD_DOMAIN = "256interns.com"
  NEW_DOMAIN = "bootcamp.fjord.jp"

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.host == OLD_DOMAIN
      location = request.url.sub(OLD_DOMAIN, NEW_DOMAIN)
      [301, { "Location" => location, "Content-Type" => "text/html" }, []]
    else
      @app.call(env)
    end
  end
end
