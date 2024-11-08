import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippt/colors.dart';
import 'package:zippt/checklist_provider.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final checklistProvider = Provider.of<ChecklistProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.main,
      appBar: AppBar(
        title: const Text(
          '집보기 체크리스트',
          style: TextStyle(
            fontFamily: 'GowunBatang',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.main,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.mainGrey,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                '꼭 체크해야하는 부분을 아래에 자유롭게 추가해 주세요.',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _itemController,
              decoration: InputDecoration(
                labelText: '새로운 체크리스트 항목',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    checklistProvider.addItem(_itemController.text);
                    _itemController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: checklistProvider.checklistItems.length,
                itemBuilder: (context, index) {
                  final item = checklistProvider.checklistItems[index];
                  return Card(
                    color: const Color.fromARGB(255, 238, 224, 224),
                    child: ExpansionTile(
                      title: Text(item['title']),
                      children: [
                        Wrap(
                          spacing: 8.0,
                          children: List<Widget>.generate(
                            item['tags'].length,
                            (tagIndex) {
                              return Chip(
                                label: Text(item['tags'][tagIndex]),
                                onDeleted: () => checklistProvider.removeTag(index, tagIndex),
                              );
                            },
                          ).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              labelText: '태그 추가',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  checklistProvider.addTag(index, _tagController.text);
                                  _tagController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 79, 79, 79)),
                            onPressed: () => checklistProvider.removeItem(index),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
