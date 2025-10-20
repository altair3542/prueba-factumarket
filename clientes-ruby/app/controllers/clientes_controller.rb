# class ClientesController < ApplicationController
#   def index
#     render json: $clientes_repo.list(limit: 100)
#   end

#   def create
#     rec = $create_cliente_uc.call(params.require(:cliente).to_unsafe_h)
#     render json: rec, status: :created
#   rescue ArgumentError => e
#     render json: {error: e.message}, status: :unprocessable_entity
#   rescue ActiveRecord::RecordInvalid => e
#     render json: {error: e.record.errors.full_messages}, status: :unprocessable_entity
#   end
# end

# app/controllers/clientes_controller.rb
class ClientesController < ApplicationController
  def create
    rec = $create_cliente_uc.call(cliente_params.to_h)
    render json: as_uppercase(rec), status: :created
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def cliente_params
    params.require(:cliente).permit(:nombre, :email, :identificacion)
  end

  # (opcional) Si quieres responder en MAYÚSCULAS como en la BD:
  def as_uppercase(rec)
    {
      ID: rec.id,
      NOMBRE: rec.nombre,
      EMAIL: rec.email,
      IDENTIFICACION: rec.identificacion
    }
  end
end
