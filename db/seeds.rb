if User.find_by(username: "admin")
  User.create(username: "admin", password: "password", is_admin: true)
end

