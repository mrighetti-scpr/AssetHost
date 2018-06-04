module AuthorizationHelper
  class UnauthorizedError < StandardError
  end
  ##
  # Given a user, a resource name, and an ability(read|write), returns a boolean
  # depending on whether those values match a permission defined on the user.
  ##
  def can? user, resource, ability
    return true if user.is_admin
    permissions = user.permissions || []
    permission  = permissions.find{|p| Array(resource).any?{|r| r == p["resource"]} }
    return false if !permission || !permission["ability"]
    return true  if permission["ability"] == ability
    return true  if ability == "read" && permission["ability"] == "write"
    false
  end
  ##
  # The same as #can? but raises UnauthoirzedError if the user does not have permission.
  ##
  def authorize *args
    return if can?(*args)
    raise UnauthorizedError
  end
end

