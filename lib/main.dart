import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  int? draggingIndex;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return DragTarget<int>(
            onAccept: (fromIndex) {
              setState(() {
                final draggedItem = _items.removeAt(fromIndex);
                _items.insert(index, draggedItem);
              });
            },
            onWillAccept: (fromIndex) {
              return fromIndex != index;
            },
            builder: (context, candidateData, rejectedData) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                      scale: animation,
                      child: child); // it is used for animation while swaping.
                },
                child: Draggable<int>(
                  // Draggable used to drag from one place to other.
                  key: ValueKey(item),
                  data: index,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.7,
                      child: widget.builder(item),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: widget.builder(item),
                  ),
                  child: widget.builder(item),
                  onDragStarted: () {
                    setState(() {
                      draggingIndex = index;
                    });
                  },
                  onDragCompleted: () {
                    setState(() {
                      draggingIndex = null;
                    });
                  },
                  onDraggableCanceled: (_, __) {
                    setState(() {
                      draggingIndex = null;
                    });
                  },
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
