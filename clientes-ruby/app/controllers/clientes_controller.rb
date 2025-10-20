class ClientesController < ApplicationController
  def index
    render json: $clientes_repo.list(limit: 100)
  end

  def create
    rec = $create_cliente_uc.call(params.require(:cliente).to_unsafe_h)
    render json: rec, status: :created
  rescue ArgumentError => e
    render json: {error: e.message}, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: {error: e.record.errors.full_messages}, status: :unprocessable_entity
  end
end
