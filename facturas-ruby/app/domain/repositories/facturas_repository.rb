module Domain
  module Repositories
    class FacturasRepository
      def create!(_entity) = raise NotImplementedError
      def find(_id) = raise NotImplementedError
      def list(limit: 100) = raise NotImplementedError
      def list_between(_ini,_fin) = raise NotImplementedError
    end
  end
end
