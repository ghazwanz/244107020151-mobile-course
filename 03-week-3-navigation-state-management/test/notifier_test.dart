import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_state/providers/stats_provider.dart';
import 'package:navigation_state/providers/todo_provider.dart';

void main() {
  group('TodoListNotifier Unit Tests', () {
    test('State awal harus berupa list kosong', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final todos = container.read(todoListProvider);
      expect(todos, isEmpty);
    });

    test('add() menambahkan tugas baru secara immutable', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(todoListProvider.notifier).add('Belajar Riverpod');
      final todos = container.read(todoListProvider);

      expect(todos.length, 1);
      expect(todos.first.title, 'Belajar Riverpod');
      expect(todos.first.done, isFalse);
    });

    test('toggle() mengubah status selesai tugas', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(todoListProvider.notifier).add('Tugas 1');
      container.read(todoListProvider.notifier).toggle(0);

      final todos = container.read(todoListProvider);
      expect(todos.first.done, isTrue);
    });

    test('remove() menghapus tugas berdasarkan indeks', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(todoListProvider.notifier).add('Tugas 1');
      container.read(todoListProvider.notifier).add('Tugas 2');
      container.read(todoListProvider.notifier).remove(0);

      final todos = container.read(todoListProvider);
      expect(todos.length, 1);
      expect(todos.first.title, 'Tugas 2');
    });

    test('uncompletedTodosProvider memfilter hanya tugas yang belum selesai', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(todoListProvider.notifier).add('Tugas 1');
      container.read(todoListProvider.notifier).add('Tugas 2');
      container.read(todoListProvider.notifier).toggle(0);

      final uncompleted = container.read(uncompletedTodosProvider);
      expect(uncompleted.length, 1);
      expect(uncompleted.first.title, 'Tugas 2');
    });
  });

  group('StatsNotifier Unit Tests', () {
    setUp(() {
      StatsNotifier.enableFailureSimulation = false;
    });

    tearDown(() {
      StatsNotifier.enableFailureSimulation = true;
    });

    test('State awal adalah AsyncLoading sebelum data selesai dimuat', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(statsProvider);
      expect(state, isA<AsyncLoading>());
    });

    test('State awal saat daftar tugas kosong mengembalikan list kosong', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final stats = await container.read(statsProvider.future);
      expect(stats, isEmpty);
    });

    test('Data statistik sinkron secara reaktif dengan todoListProvider', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Menambahkan 2 tugas dan menyelesaikan 1 tugas
      container.read(todoListProvider.notifier).add('Tugas A');
      container.read(todoListProvider.notifier).add('Tugas B');
      container.read(todoListProvider.notifier).toggle(0);

      final stats = await container.read(statsProvider.future);
      expect(stats.length, 3);
      expect(stats[0], 'Total Tugas: 2 Item');
      expect(stats[1], 'Tugas Selesai: 1 Item');
      expect(stats[2], 'Tugas Belum Selesai: 1 Item');
    });
  });
}
