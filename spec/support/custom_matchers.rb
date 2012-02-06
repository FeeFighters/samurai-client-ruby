RSpec::Matchers.define :have_the_error do |key, expected|
  match do |actual|
    [actual.errors[key]].flatten.include?(expected)
  end
  failure_message_for_should do |actual|
    "expected that #{actual.errors[key].inspect} would have the error #{expected.inspect}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual.errors[key].inspect} would not have the error '#{expected.inspect}'"
  end

  description do
    "have the error #{key.inspect} - #{expected.inspect}"
  end
end
