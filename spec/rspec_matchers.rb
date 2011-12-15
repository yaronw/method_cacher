RSpec::Matchers.define :be_twice_the_same do |options|
  match do |proc|
    cached = proc.call
    proc.call == cached
  end

  failure_message_for_should do |proc|
    "expected #{proc} to return the same value when called twice"
  end

  failure_message_for_should_not do |proc|
    "expected #{proc} to return two different values when called twice"
  end
end