library;

/// Definisi skema dan struktur koleksi Firestore untuk aplikasi ProdTrack.
/// Digunakan sebagai panduan data contract antara Flutter dan Cloud Firestore.

class FirestoreCollections {
  /// Koleksi metadata pabrik (stok gudang, target harian)
  /// Dokumen: `factory_config/default`
  static const String factoryConfig = 'factory_config';

  /// Koleksi entri catatan produksi & QC harian
  /// Dokumen: auto-generated ID
  static const String productionLogs = 'production_logs';

  /// Koleksi antrean pesanan klien / pasar (FIFO)
  /// Dokumen: auto-generated ID
  static const String clients = 'clients';

  /// Koleksi inventaris mesin pabrik & data siklus pemeliharaan
  /// Dokumen: auto-generated ID
  static const String machines = 'machines';
}

class FactoryConfigFields {
  static const String stock = 'stock';
  static const String dailyTarget = 'daily_target';
  static const String updatedAt = 'updated_at';
}

class ProductionLogFields {
  static const String timestamp = 'timestamp';
  static const String good = 'good';
  static const String rej = 'rej';
  static const String note = 'note';
  static const String createdAt = 'created_at';
}

class ClientFields {
  static const String name = 'name';
  static const String qty = 'qty';
  static const String priority = 'priority';
  static const String createdAt = 'created_at';
}

class MachineFields {
  static const String name = 'name';
  static const String since = 'since';
  static const String total = 'total';
  static const String last = 'last';
  static const String maintenanceNotes = 'maintenanceNotes';
}
