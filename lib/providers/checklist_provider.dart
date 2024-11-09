import 'package:flutter/material.dart';

class ChecklistProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _checklistItems = [
    {
      'title': '화장실 수압 상태',
      'tags': ['좋음', '보통', '나쁨']
    },
    {
      'title': '창문 방향',
      'tags': ['남', '동', '서', '북']
    },
    {
      'title': '층수',
      'tags': ['1층', '2-3층', '4층 이상', '반지하']
    },
  ];

  List<Map<String, dynamic>> get checklistItems => _checklistItems;

  void addItem(String title) {
    if (title.isNotEmpty) {
      _checklistItems.add({'title': title, 'tags': []});
      notifyListeners();
    }
  }

  void addTag(int index, String tag) {
    if (tag.isNotEmpty) {
      _checklistItems[index]['tags'].add(tag);
      notifyListeners();
    }
  }

  void removeItem(int index) {
    _checklistItems.removeAt(index);
    notifyListeners();
  }

  void removeTag(int itemIndex, int tagIndex) {
    _checklistItems[itemIndex]['tags'].removeAt(tagIndex);
    notifyListeners();
  }
}
