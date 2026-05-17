class Rack::Attack
  # Login brute force
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.post? && req.path.ends_with?("/users/sign_in")
      req.ip
    end
  end

  # Signup spam
  throttle("signups/ip", limit: 5, period: 1.minute) do |req|
    if req.post? && req.path.ends_with?("/users")
      req.ip
    end
  end

  # Orders spam
  throttle("orders/ip", limit: 5, period: 1.minute) do |req|
    if req.post? && req.path.ends_with?("/orders")
      req.ip
    end
  end
end
