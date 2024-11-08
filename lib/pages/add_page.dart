import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippt/checklist_provider.dart';

class OtherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('다른 페이지'),
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          final checklistItems = checklistProvider.checklistItems;

          return ListView.builder(
            itemCount: checklistItems.length,
            itemBuilder: (context, index) {
              final item = checklistItems[index];
              return ListTile(
                title: Text(item['title']),
                subtitle: Text(item['tags'].join(', ')), // 태그들을 쉼표로 구분하여 출력
              );
            },
          );
        },
      ),
    );
  }
}
