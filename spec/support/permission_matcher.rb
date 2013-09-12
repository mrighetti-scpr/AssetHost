RSpec::Matchers.define :be_allowed_to do |ability, resource|
  match do |api_user|
    api_user.may?(ability, resource)
  end

  description do
    "have the ability to #{ability} #{resource}"
  end

  failure_message_for_should do
    "expected user to have the ability to #{ability} #{resource}, but it didn't."
  end

  failure_message_for_should_not do
    "expected user bot to have the ability to #{ability} #{resource}, but it did."
  end
end
