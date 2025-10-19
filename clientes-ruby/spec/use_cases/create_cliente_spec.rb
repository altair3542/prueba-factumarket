require "rails_helper"

RSpec.describe Application::CreateCliente do
  class FakeRepo < Domain::Repositories::ClientesRepository
    attr_reader :last_entity
    def create!(entity)
      @last_entity = entity
      Struct.new(:ID, :NOMBRE, :EMAIL).new(1, entity.nombre, entity.email)
    end
    def find(_); end
    def list(limit: 100); []; end
  end

  class FakeAuditor
    attr_reader :calls
    def initialize; @calls = []; end
    def post_event!(**args); @calls << args; "event-1"; end
  end

  it "crea un cliente y envia un evento" do
    repo = FakeRepo.new
    auditor = FakeAuditor.new
    uc = described_class.new(repo: repo, auditor: auditor)

    rec = uc.call({ "nombre" => "Juliana", "email" => "juliana@mail.com" })

    expect(repo.last_entity.nombre).to eq("Juliana")
    expect(rec.NOMBRE).to eq("Juliana")
    expect(auditor.calls.last[:type]).to eq("cliente_creado")
    expect(auditor.calls.last[:clienteId]).to eq(1)
  end

  it "falla si no hay nombre" do
    uc = described_class.new(repo: FakeRepo.new, auditor: FakeAuditor.new)
    expect { uc.call({}) }.to raise_error(ArgumentError, "NOMBRE requerido")
  end

end
