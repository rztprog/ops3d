class Rack::Attack
  # Login brute force
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end

  # Signup spam
  throttle("signups/ip", limit: 5, period: 1.minute) do |req|
    if req.path == "/users" && req.post?
      req.ip
    end
  end
end
