import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/client.dart';
import '../models/log.dart';
import '../models/machine.dart';
import 'firebase_schema.dart';

/// Service Backend Firestore aktif untuk aplikasi ProdTrack.
abstract class IFirestoreService {
  // --- KONFIGURASI PABRIK (STOK & TARGET) ---
  Future<Map<String, dynamic>?> getFactoryConfig();
  Future<void> updateStock(int newStock);
  Future<void> updateTarget(int newTarget);

  // --- CATATAN PRODUKSI (LOGS & QC) ---
  Future<List<Log>> getProductionLogs();
  Stream<List<Log>> streamProductionLogs();
  Future<String> addProductionLog({required int good, required int rej, String? note});
  Future<void> deleteProductionLog(Log log);

  // --- DAFTAR PEMESAN (CLIENTS & FIFO SHIPPING) ---
  Future<List<Client>> getClients();
  Stream<List<Client>> streamClients();
  Future<String> addClient({required String name, required int qty});
  Future<int> shipClientOrder({required String clientId, required int amountToShip});
  Future<void> deleteClient(String clientId);

  // --- KONDISI MESIN & SIKLUS PERAWATAN ---
  Future<List<Machine>> getMachines();
  Stream<List<Machine>> streamMachines();
  Future<String> addMachine({required String name});
  Future<void> addMachineHours({required String machineId, required double additionalHours});
  Future<void> recordMaintenance({required String machineId, required String note});
}

/// Implementasi Aktif Cloud Firestore untuk ProdTrack
class FirestoreService implements IFirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================================================
  // 1. Konfigurasi Pabrik (Stok Gudang & Target Harian)
  // =========================================================

  @override
  Future<Map<String, dynamic>?> getFactoryConfig() async {
    final doc = await _db
        .collection(FirestoreCollections.factoryConfig)
        .doc('default')
        .get();
    return doc.data();
  }

  @override
  Future<void> updateStock(int newStock) async {
    await _db
        .collection(FirestoreCollections.factoryConfig)
        .doc('default')
        .set({
          FactoryConfigFields.stock: newStock,
          FactoryConfigFields.updatedAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  @override
  Future<void> updateTarget(int newTarget) async {
    await _db
        .collection(FirestoreCollections.factoryConfig)
        .doc('default')
        .set({
          FactoryConfigFields.dailyTarget: newTarget,
          FactoryConfigFields.updatedAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  // =========================================================
  // 2. Produksi & QC Logs
  // =========================================================

  @override
  Future<List<Log>> getProductionLogs() async {
    final snap = await _db
        .collection(FirestoreCollections.productionLogs)
        .orderBy(ProductionLogFields.timestamp, descending: false)
        .get();
    return snap.docs.map((d) => Log.fromMap(d.data(), id: d.id)).toList();
  }

  @override
  Stream<List<Log>> streamProductionLogs() {
    return _db
        .collection(FirestoreCollections.productionLogs)
        .orderBy(ProductionLogFields.timestamp, descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Log.fromMap(d.data(), id: d.id)).toList());
  }

  /// Transaksi Atomik: Saat log produksi disimpan, stok pabrik otomatis bertambah sebesar `good` unit.
  @override
  Future<String> addProductionLog({required int good, required int rej, String? note}) async {
    final newLog = Log(DateTime.now(), good, rej, note: note);
    return await _db.runTransaction((transaction) async {
      final configRef = _db.collection(FirestoreCollections.factoryConfig).doc('default');
      final configSnap = await transaction.get(configRef);
      final currentStock = (configSnap.data()?[FactoryConfigFields.stock] as num?)?.toInt() ?? 0;

      final newLogRef = _db.collection(FirestoreCollections.productionLogs).doc();
      transaction.set(newLogRef, newLog.toMap());
      transaction.set(configRef, {
        FactoryConfigFields.stock: currentStock + good,
        FactoryConfigFields.updatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return newLogRef.id;
    });
  }

  /// Transaksi Atomik: Menghapus log produksi dan mengurangi stok gudang sebesar `good` unit yang dibatalkan.
  @override
  Future<void> deleteProductionLog(Log log) async {
    if (log.id == null || log.id!.isEmpty) return;
    await _db.runTransaction((transaction) async {
      final configRef = _db.collection(FirestoreCollections.factoryConfig).doc('default');
      final logRef = _db.collection(FirestoreCollections.productionLogs).doc(log.id);
      final configSnap = await transaction.get(configRef);
      final currentStock = (configSnap.data()?[FactoryConfigFields.stock] as num?)?.toInt() ?? 0;

      transaction.delete(logRef);
      transaction.set(configRef, {
        FactoryConfigFields.stock: (currentStock - log.good).clamp(0, 9999999),
        FactoryConfigFields.updatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  // =========================================================
  // 3. Antrean Pemesan & Pengiriman FIFO
  // =========================================================

  @override
  Future<List<Client>> getClients() async {
    final snap = await _db
        .collection(FirestoreCollections.clients)
        .orderBy(ClientFields.createdAt, descending: false)
        .get();
    return snap.docs.map((d) => Client.fromMap(d.data(), id: d.id)).toList();
  }

  @override
  Stream<List<Client>> streamClients() {
    return _db
        .collection(FirestoreCollections.clients)
        .orderBy(ClientFields.createdAt, descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Client.fromMap(d.data(), id: d.id)).toList());
  }

  @override
  Future<String> addClient({required String name, required int qty}) async {
    final client = Client(name, qty);
    final map = client.toMap();
    map[ClientFields.createdAt] = FieldValue.serverTimestamp();
    final docRef = await _db.collection(FirestoreCollections.clients).add(map);
    return docRef.id;
  }

  /// Transaksi Atomik: Mengurangi stok gudang dan mengurangi kuota pemesan secara bersamaan.
  @override
  Future<int> shipClientOrder({required String clientId, required int amountToShip}) async {
    return await _db.runTransaction((transaction) async {
      final configRef = _db.collection(FirestoreCollections.factoryConfig).doc('default');
      final clientRef = _db.collection(FirestoreCollections.clients).doc(clientId);

      final configSnap = await transaction.get(configRef);
      final clientSnap = await transaction.get(clientRef);

      final currentStock = (configSnap.data()?[FactoryConfigFields.stock] as num?)?.toInt() ?? 0;
      final clientQty = (clientSnap.data()?[ClientFields.qty] as num?)?.toInt() ?? 0;

      final actualShipped = amountToShip.clamp(0, currentStock);
      final remainingClientQty = clientQty - actualShipped;

      transaction.set(configRef, {
        FactoryConfigFields.stock: currentStock - actualShipped,
        FactoryConfigFields.updatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (remainingClientQty <= 0) {
        transaction.delete(clientRef);
      } else {
        transaction.update(clientRef, {ClientFields.qty: remainingClientQty});
      }

      return actualShipped;
    });
  }

  @override
  Future<void> deleteClient(String clientId) async {
    await _db.collection(FirestoreCollections.clients).doc(clientId).delete();
  }

  // =========================================================
  // 4. Inventaris Mesin & Siklus Servis
  // =========================================================

  @override
  Future<List<Machine>> getMachines() async {
    final snap = await _db.collection(FirestoreCollections.machines).get();
    return snap.docs.map((d) => Machine.fromMap(d.data(), id: d.id)).toList();
  }

  @override
  Stream<List<Machine>> streamMachines() {
    return _db
        .collection(FirestoreCollections.machines)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Machine.fromMap(d.data(), id: d.id)).toList());
  }

  @override
  Future<String> addMachine({required String name}) async {
    final m = Machine(name, 0, 0, DateTime.now());
    final docRef = await _db.collection(FirestoreCollections.machines).add(m.toMap());
    return docRef.id;
  }

  @override
  Future<void> addMachineHours({required String machineId, required double additionalHours}) async {
    final docRef = _db.collection(FirestoreCollections.machines).doc(machineId);
    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      final currentSince = (snap.data()?[MachineFields.since] as num?)?.toDouble() ?? 0.0;
      final currentTotal = (snap.data()?[MachineFields.total] as num?)?.toDouble() ?? 0.0;
      transaction.update(docRef, {
        MachineFields.since: currentSince + additionalHours,
        MachineFields.total: currentTotal + additionalHours,
      });
    });
  }

  @override
  Future<void> recordMaintenance({required String machineId, required String note}) async {
    final docRef = _db.collection(FirestoreCollections.machines).doc(machineId);
    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      final rawNotes = snap.data()?[MachineFields.maintenanceNotes] as List? ?? [];
      final List<String> notes = rawNotes.map((e) => e.toString()).toList();
      notes.insert(0, note.trim().isEmpty ? 'Servis berkala (reset jam siklus)' : note.trim());

      transaction.update(docRef, {
        MachineFields.since: 0.0, // Reset siklus servis ke 0 jam
        MachineFields.last: DateTime.now().toIso8601String(),
        MachineFields.maintenanceNotes: notes,
      });
    });
  }
}
