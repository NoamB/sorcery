require 'spec_helper'

require 'rails/generators'
# require 'rails/generators/base'
require_relative '../../lib/generators/sorcery/install_generator.rb'

describe Sorcery::Generators::InstallGenerator, type: :generator do

  destination File.expand_path("../../tmp", __FILE__)
  arguments({model: "student"})

  before(:all) do
    prepare_destination
    run_generator
  end

  it "works" do

  end
end
