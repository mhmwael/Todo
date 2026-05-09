import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task.dart';
import '../../models/task_priority.dart';

// Singleton service for syncing tasks with Firebase Firestore (cloud backup and multi-device sync)
class FirebaseTaskService {
  static final FirebaseTaskService
  _instance = FirebaseTaskService._internal();
  factory FirebaseTaskService() => _instance;
  FirebaseTaskService._internal();

  final FirebaseFirestore
  _firestore = FirebaseFirestore.instance; // Firestore reference
  static const String
  _tasksCollection = 'tasks'; // Collection name in Firestore

  // Get reference to user's tasks collection in Firestore
  CollectionReference
  _getUserTasksCollection(
    String userId,
  ) {
    return _firestore
        .collection(
          'users',
        )
        .doc(
          userId,
        )
        .collection(
          _tasksCollection,
        );
  }

  /// Add a new task to Firestore
  Future<
    void
  >
  addTask(
    String userId,
    Task task,
  ) async {
    try {
      await _getUserTasksCollection(
            userId,
          )
          .doc(
            task.id,
          )
          .set(
            {
              'id': task.id,
              'title': task.title,
              'description': task.description,
              'dueDate': task.dueDate.toIso8601String(),
              'priority': task.priority
                  .toString()
                  .split(
                    '.',
                  )
                  .last,
              'isCompleted': task.isCompleted,
              'category': task.category,
              'isPinned': task.isPinned,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
    } catch (
      e
    ) {
      throw Exception(
        'Error adding task: $e',
      );
    }
  }

  /// Update an existing task in Firestore
  Future<
    void
  >
  updateTask(
    String userId,
    Task task,
  ) async {
    try {
      await _getUserTasksCollection(
            userId,
          )
          .doc(
            task.id,
          )
          .update(
            {
              'title': task.title,
              'description': task.description,
              'dueDate': task.dueDate.toIso8601String(),
              'priority': task.priority
                  .toString()
                  .split(
                    '.',
                  )
                  .last,
              'isCompleted': task.isCompleted,
              'category': task.category,
              'isPinned': task.isPinned,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
    } catch (
      e
    ) {
      throw Exception(
        'Error updating task: $e',
      );
    }
  }

  /// Delete a task from Firestore
  Future<
    void
  >
  deleteTask(
    String userId,
    String taskId,
  ) async {
    try {
      await _getUserTasksCollection(
            userId,
          )
          .doc(
            taskId,
          )
          .delete();
    } catch (
      e
    ) {
      throw Exception(
        'Error deleting task: $e',
      );
    }
  }

  /// Get all tasks for a user as a stream
  Stream<
    List<
      Task
    >
  >
  getUserTasksStream(
    String userId,
  ) {
    try {
      return _getUserTasksCollection(
            userId,
          )
          .orderBy(
            'updatedAt',
            descending: true,
          )
          .snapshots()
          .map(
            (
              snapshot,
            ) {
              return snapshot.docs.map(
                (
                  doc,
                ) {
                  final data =
                      doc.data()
                          as Map<
                            String,
                            dynamic
                          >;
                  return Task(
                    id:
                        data['id']
                            as String,
                    title:
                        data['title']
                            as String,
                    description:
                        data['description']
                            as String?,
                    dueDate: DateTime.parse(
                      data['dueDate']
                          as String,
                    ),
                    priority: TaskPriority.values.firstWhere(
                      (
                        e,
                      ) =>
                          e
                              .toString()
                              .split(
                                '.',
                              )
                              .last ==
                          data['priority'],
                    ),
                    isCompleted:
                        data['isCompleted']
                            as bool,
                    category:
                        data['category']
                            as String,
                    isPinned:
                        data['isPinned']
                            as bool? ??
                        false,
                  );
                },
              ).toList();
            },
          );
    } catch (
      e
    ) {
      throw Exception(
        'Error getting tasks stream: $e',
      );
    }
  }

  /// Get all tasks for a user as a future (one-time fetch)
  Future<
    List<
      Task
    >
  >
  getUserTasks(
    String userId,
  ) async {
    try {
      final snapshot =
          await _getUserTasksCollection(
                userId,
              )
              .orderBy(
                'updatedAt',
                descending: true,
              )
              .get();
      return snapshot.docs.map(
        (
          doc,
        ) {
          final data =
              doc.data()
                  as Map<
                    String,
                    dynamic
                  >;
          return Task(
            id:
                data['id']
                    as String,
            title:
                data['title']
                    as String,
            description:
                data['description']
                    as String?,
            dueDate: DateTime.parse(
              data['dueDate']
                  as String,
            ),
            priority: TaskPriority.values.firstWhere(
              (
                e,
              ) =>
                  e
                      .toString()
                      .split(
                        '.',
                      )
                      .last ==
                  data['priority'],
            ),
            isCompleted:
                data['isCompleted']
                    as bool,
            category:
                data['category']
                    as String,
            isPinned:
                data['isPinned']
                    as bool? ??
                false,
          );
        },
      ).toList();
    } catch (
      e
    ) {
      throw Exception(
        'Error fetching tasks: $e',
      );
    }
  }

  /// Sync local tasks to Firebase (used for initial sync or offline changes)
  Future<
    void
  >
  syncLocalTasks(
    String userId,
    List<
      Task
    >
    localTasks,
  ) async {
    try {
      final batch = _firestore.batch();
      for (var task in localTasks) {
        final docRef =
            _getUserTasksCollection(
              userId,
            ).doc(
              task.id,
            );
        batch.set(
          docRef,
          {
            'id': task.id,
            'title': task.title,
            'description': task.description,
            'dueDate': task.dueDate.toIso8601String(),
            'priority': task.priority
                .toString()
                .split(
                  '.',
                )
                .last,
            'isCompleted': task.isCompleted,
            'category': task.category,
            'isPinned': task.isPinned,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );
      }
      await batch.commit();
    } catch (
      e
    ) {
      throw Exception(
        'Error syncing tasks: $e',
      );
    }
  }
}
