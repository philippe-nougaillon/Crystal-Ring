class AddWorkflowStateToFacture < ActiveRecord::Migration[6.0]
  def change
    add_column :factures, :workflow_state, :string
    add_index :factures, :workflow_state
  end
end
