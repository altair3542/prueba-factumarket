module Domain
  module Repositories
    class ClientesRepository
      def create!(_entity)
        raise NotImplementedError
      end

      def find(_id)
        raise NotImplementedError
      end

      def list(limit: 100)
        raise NotImplementedError
      end
    end
  end
end
