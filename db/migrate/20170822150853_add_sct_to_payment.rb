class AddSctToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :gtwrefno, :string
    add_column :payments, :description, :text
    add_column :payments, :concerned_bank, :string
  end
end
