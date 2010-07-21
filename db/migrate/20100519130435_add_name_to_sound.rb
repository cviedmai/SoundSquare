class AddNameToSound < ActiveRecord::Migration
  def self.up
    add_column :sounds, :name, :string, :default => "A cool song!"
  end

  def self.down
    remove_column :sounds, :name
  end
end
