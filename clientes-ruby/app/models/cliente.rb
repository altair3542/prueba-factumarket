class Cliente < ApplicationRecord
  self.table_name = "CLIENTES"
  self.primary_key = "ID"
  self.sequence_name = "CLIENTS_SEQ"

  validates :NOMBRE, presence: true
  validates :IDENTIFICACION, uniqueness: true, allow_nil: true
end


