module Domain
  class ClienteEntity
    attr_reader :nombre, :email, :identificacion

    def initialize(nombre:, email: nil, identificacion: nil)
      @nombre = nombre
      @email = email
      @identificacion = identificacion
    end
  end
end
