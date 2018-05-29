module AuthorizationHelper
  class UnauthorizedError < StandardError
  end
  def can? user, resource, ability
    return true if user.is_admin
    permissions = user.permissions || []
    permission  = permissions.find{|p| p["resource"] == resource }
    return false if !permission || !permission["ability"]
    return true  if permission["ability"] == ability
    return true  if ability == "read" && permission["ability"] == "write"
    false
  end
  def authorize *args
    return if can?(*args)
    raise UnauthorizedError
  end
end

