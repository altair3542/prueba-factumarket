# module Infrastructure
#   module Repositories
#     class OracleClientesRepository < Domain::Repositories::ClientesRepository
#       def create!(entity)
#         rec = Cliente.new(
#           "NOMBRE" => entity.nombre,
#           "EMAIL"  => entity.email,
#           "IDENTIFICACION" => entity.identificacion
#         )
#         rec.save!
#         rec
#       end

#       def find(id)
#         Cliente.find(id)
#       end

#       def list(limit: 100)
#         Cliente.order(ID: :desc).limit(limit)
#       end
#     end
#   end
# end

module Infrastructure
  module Repositories
    class OracleClientesRepository < Domain::Repositories::ClientesRepository
      def create!(entity)
        rec = Cliente.new(
          nombre:          entity.nombre,
          email:           entity.email,
          identificacion:  entity.identificacion
        )
        rec.save!
        rec
      end

      def find_by_identificacion(ident)
        Cliente.find_by(identificacion: ident)
      end
    end
  end
end
