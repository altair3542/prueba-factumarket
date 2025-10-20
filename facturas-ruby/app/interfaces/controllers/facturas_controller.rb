module Interfaces
  module Controllers
    class FacturasController < ApplicationController
      before_action :set_factura, only: :show

      def index
        if params[:fechaInicio].present? && params[:fechaFin].present?
          data = $facturas_repo.list_between(params[:fechaInicio], params[:fechaFin])
        else
          data = $facturas_repo.list(limit: 100)
        end
        render json: data
      end

      def show
        render json: @factura
      end

      def create
        rec = $create_factura_uc.call(params.require(:factura).to_unsafe_h)
        render json: rec, status: :created
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocesable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages } status: :unprocesable_entity
      end

      private
      def set_factura
        ActiveRecord::RecordNotFound
      rescue ActiveRecord::RecordNotFound
        render json: { error: "No Existe" }, status: :not_found
      end
    end
  end
end
