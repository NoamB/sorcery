require 'spec_helper'

require 'shared_examples/user_activity_logging_shared_examples'

describe User, "with activity logging submodule", :data_mapper => true do

  it_behaves_like "rails_3_activity_logging_model"

  it "raises an error when incompatible adapter" do
    allow(User.repository.adapter).to receive(:is_a?).with(DataMapper::Adapters::MysqlAdapter) { false }
    expect(-> { sorcery_reload!(:activity_logging) }).to raise_error(Exception)
  end

end
