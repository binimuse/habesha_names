enum SyncStatus { success, skipped, failed }

class SyncResult {
  const SyncResult(
    this.status, {
    this.upserted = 0,
    this.deleted = 0,
    this.error,
  });

  final SyncStatus status;
  final int upserted;
  final int deleted;
  final Object? error;

  bool get changedAnything => upserted > 0 || deleted > 0;

  @override
  String toString() =>
      'SyncResult(${status.name}, +$upserted, -$deleted'
      '${error == null ? '' : ', $error'})';
}
