require 'spec_helper'
require 'ostruct'

# Mock necesario para las clases de dominio
module Domain
  class FacturaEntity < OpenStruct; end

  module Repositories
    class FacturasRepository
      def create!(_); raise NotImplementedError; end
      def find(_); raise NotImplementedError; end
      def list(_); raise NotImplementedError; end
      def list_between(_,_); raise NotImplementedError; end
    end
  end
end

# Cargar el caso de uso que queremos probar
require_relative '../app/application/create_factura'
