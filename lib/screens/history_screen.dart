// lib/screens/history_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int? _filterSeverity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique',
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<int?>(
            icon: Icon(Icons.filter_list, color: theme.iconTheme.color),
            onSelected: (val) => setState(() => _filterSeverity = val),
            itemBuilder: (_) => [
              PopupMenuItem(value: null, child: Text('Tous')),
              PopupMenuItem(value: 1, child: Text('Gravité 1')),
              PopupMenuItem(value: 2, child: Text('Gravité 2')),
              PopupMenuItem(value: 3, child: Text('Gravité 3')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: secondary));
          }
          final docs = snap.data?.docs.where((d) {
            final sev = (d['severity'] as int);
            return _filterSeverity == null || sev == _filterSeverity;
          }).toList();
          if (docs == null || docs.isEmpty) {
            return Center(
              child: Text(
                'Aucun signalement.',
                style: TextStyle(
                  color: secondary,
                  fontFamily: 'Ubuntu',
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data()! as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final formatted = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
              final isNew = DateTime.now().difference(timestamp) < Duration(hours: 24);

              // Severity color
              final sevColor = data['severity'] == 1
                  ? Colors.green
                  : data['severity'] == 2
                  ? Colors.orange
                  : Colors.red;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Icon(Icons.circle, color: sevColor, size: 16),
                  title: Row(
                    children: [
                      Text(
                        'Gravité : ${data['severity']}',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isNew) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('Nouveau'),
                          backgroundColor: secondary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: secondary,
                            fontFamily: 'Ubuntu',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((data['comment'] as String?)?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            data['comment'],
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          formatted,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Ubuntu',
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
