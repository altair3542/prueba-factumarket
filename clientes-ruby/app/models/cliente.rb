# app/models/cliente.rb
class Cliente < ApplicationRecord
  self.table_name  = "CLIENTES"
  self.primary_key = "id"
  self.sequence_name = "CLIENTES_SEQ"

  alias_attribute :NOMBRE, :nombre
  alias_attribute :IDENTIFICACION, :identificacion

  validates :nombre, presence: true
  validates :identificacion, uniqueness: true, allow_nil: true
end
