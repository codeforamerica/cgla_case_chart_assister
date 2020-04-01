module FixtureHelper
  FixtureNotFoundException = Class.new(StandardError)

  extend self

  def read_fixture(fixture_slug)
    fixture_path = Rails.root.join('spec', 'fixtures', fixture_slug)
    raise FixtureNotFoundException, fixture_path unless File.exist?(fixture_path)

    File.read(fixture_path)
  end
end