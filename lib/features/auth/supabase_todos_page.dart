import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTodosPage extends StatefulWidget {
  const SupabaseTodosPage({super.key});

  @override
  State<SupabaseTodosPage> createState() => _SupabaseTodosPageState();
}

class _SupabaseTodosPageState extends State<SupabaseTodosPage> {
  late final Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = Supabase.instance.client
        .from('todos')
        .select()
        .then((data) => data as List<dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Todos')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final todos = snapshot.data;
          if (todos == null || todos.isEmpty) {
            return const Center(child: Text('No todos found'));
          }

          return ListView.separated(
            itemCount: todos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final todo = todos[index] as Map<String, dynamic>;
              return ListTile(
                title: Text(todo['name']?.toString() ?? 'Unnamed'),
                subtitle: Text(todo['description']?.toString() ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
