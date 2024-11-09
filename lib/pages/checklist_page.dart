import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippt/utils/colors.dart';
import 'package:zippt/providers/checklist_provider.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
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
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.mainGrey,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.black54),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '집을 방문하기 전에, 꼭 체크해야하는 부분을 아래에 추가해주세요!',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _itemController,
                  decoration: InputDecoration(
                    labelText: '새로운 체크리스트 항목',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        if (_itemController.text.isNotEmpty) {
                          checklistProvider.addItem(_itemController.text);
                          _itemController.clear();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: checklistProvider.checklistItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = checklistProvider.checklistItems[index];
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    child: ExpansionTile(
                      title: Text(
                        item['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      shape: const Border(),
                      collapsedShape: const Border(),
                      children: [
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (item['tags'].isNotEmpty) ...[
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: List<Widget>.generate(
                                    item['tags'].length,
                                    (tagIndex) {
                                      return Chip(
                                        label: Text(
                                          item['tags'][tagIndex],
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        deleteIcon:
                                            const Icon(Icons.close, size: 18),
                                        onDeleted: () => checklistProvider
                                            .removeTag(index, tagIndex),
                                        backgroundColor: Colors.grey[100],
                                        side: BorderSide.none,
                                      );
                                    },
                                  ).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _tagController,
                                      decoration: const InputDecoration(
                                        hintText: '새로운 태그 추가',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: () {
                                      if (_tagController.text.isNotEmpty) {
                                        checklistProvider.addTag(
                                            index, _tagController.text);
                                        _tagController.clear();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20),
                                  label: const Text(
                                    '삭제',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'GowunBatang',
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red[400],
                                  ),
                                  onPressed: () =>
                                      checklistProvider.removeItem(index),
                                ),
                              ),
                            ],
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

  @override
  void dispose() {
    _itemController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
