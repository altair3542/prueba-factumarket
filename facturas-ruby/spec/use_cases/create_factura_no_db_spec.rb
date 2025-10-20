require_relative '../test_no_db'

RSpec.describe Application::CreateFactura do
  class FakeRepo < Domain::Repositories::FacturasRepository
    attr_reader :last_entity
    def create!(entity)
      @last_entity = entity
      OpenStruct.new(ID: 10, CLIENTE_ID: entity.cliente_id, MONTO: entity.monto, FECHA: entity.fecha, DESCRIPCION: entity.descripcion)
    end
    def find(_); end
    def list(limit: 100); []; end
    def list_between(_,_); []; end
  end

  class FakeAuditor
    attr_reader :calls
    def initialize; @calls = []; end
    def post_event!(**args); @calls << args; end
  end

  class OkClientesApi
    def self.cliente_existe?(_id) = true
  end

  class NoClientesApi
    def self.cliente_existe?(_id) = false
  end

  it "crea factura y envía evento" do
    uc = described_class.new(repo: FakeRepo.new, auditor: FakeAuditor.new, clientes_api: OkClientesApi)
    rec = uc.call({ "cliente_id" => 1, "monto" => 1000, "fecha" => "2025-10-18", "descripcion" => "Servicio" })
    expect(rec.ID).to eq(10)
  end

  it "falla si el cliente no existe" do
    uc = described_class.new(repo: FakeRepo.new, auditor: FakeAuditor.new, clientes_api: NoClientesApi)
    expect {
      uc.call({ "cliente_id" => 999, "monto" => 1000, "fecha" => "2025-10-18" })
    }.to raise_error(ArgumentError, "Cliente no existe")
  end
end
