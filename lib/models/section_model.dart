import 'package:flutter/material.dart';

class SectionModel {
  final int id;
  final String title;
  final String subtitle;
  final Color color;
  final String iconPath;
  
  SectionModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.color,
    required this.iconPath,
  });
  
  factory SectionModel.fromJson(Map<String, dynamic> json, {Color? defaultColor}) {
    return SectionModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Section',
      subtitle: json['subtitle'] ?? '',
      color: defaultColor ?? const Color(0xFFE6DAFF),
      iconPath: json['icon_path'] ?? 'assets/icons/default.png',
    );
  }
}