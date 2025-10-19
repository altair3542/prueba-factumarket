db = db.getSiblingDB('auditoria');
db.events.createIndex({ facturaId: 1 });
db.events.createIndex({ eventId: 1 }, { unique: true });
