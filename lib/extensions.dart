extension MyDoubleExt on double {
  String toTimeFromSeconds() {
    final int hours = (this / 3600).floor();
    final int minutes = ((this - hours * 3600) / 60).floor();
    return '${hours > 0 ? '${hours}h' : ''}${minutes > 0 ? '${minutes.toString().padLeft(2, '0')}min' : ''}';
  }

  String toTimeFromMinutes() {
    return (this * 60).toTimeFromSeconds();
  }
}

extension MyIntExt on int {
  String toTimeFromSeconds() {
    final int hours = (this / 3600).floor();
    final int minutes = ((this - hours * 3600) / 60).floor();
    return '${hours > 0 ? '${hours}h' : ''}${minutes > 0 ? '${minutes.toString().padLeft(2, '0')}min' : ''}';
  }

  String toTimeFromMinutes() {
    return (this * 60).toTimeFromSeconds();
  }
}

extension MyIterableExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
