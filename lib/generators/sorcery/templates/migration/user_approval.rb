class SorceryUserApproval < ActiveRecord::Migration
  def change
    add_column :<%= model_class_name.tableize %>, :approval_state, :string, :default => nil
  end
end
