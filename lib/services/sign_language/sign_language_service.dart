import 'package:eazytalk/models/instruction_model.dart';
import 'package:eazytalk/models/tip_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eazytalk/models/section_model.dart';
import 'package:eazytalk/models/word_model.dart';
import 'package:eazytalk/utilities/color_helpers.dart';

class SignLanguageService {
  final _supabase = Supabase.instance.client;
  
  /// Fetch all sections from the database
  Future<List<SectionModel>> fetchSections() async {
    try {
      final response = await _supabase
          .from('Sections')
          .select()
          .order('id');
      
      return response.map<SectionModel>((section) {
        return SectionModel(
          id: section['id'],
          title: section['title'] ?? 'Unknown Section',
          subtitle: section['subtitle'] ?? '',
          color: ColorHelpers.hexToColor(section['color'] ?? '#E6DAFF'),
          iconPath: section['icon_path'] ?? 'assets/icons/default.png',
        );
      }).toList();
    } catch (e) {
      print('Error fetching sections: $e');
      throw Exception('Failed to load sections. Please check your connection.');
    }
  }
  
  /// Fetch most used words from the database
  Future<List<WordModel>> fetchMostUsedWords() async {
    try {
      final response = await _supabase
          .from('Words')
          .select()
          .eq('is_most_used', true)
          .order('id');
      
      return response.map<WordModel>((word) => WordModel.fromJson(word)).toList();
    } catch (e) {
      print('Error fetching most used words: $e');
      throw Exception('Failed to load words. Please check your connection.');
    }
  }
  
// Fetch words for a specific section
Future<List<WordModel>> fetchWordsBySection(int sectionId) async {
  try {
    final response = await _supabase
        .from('Words')
        .select()
        .eq('section_id', sectionId)
        .order('word');
    
    return response.map<WordModel>((word) => WordModel.fromJson(word)).toList();
  } catch (e) {
    print('Error loading words for section $sectionId: $e');
    throw Exception('Failed to load words. Please check your connection.');
  }
}

// Filter and sort word list
List<WordModel> filterAndSortWords({
  required List<WordModel> words,
  required String searchQuery,
  required bool showFavoritesOnly,
  required Set<int> favoriteIds,
  required String sortOption,
}) {
  // Create a copy of the list to avoid modifying the original
  List<WordModel> filteredList = List.from(words);
  
  // Apply search filter
  if (searchQuery.isNotEmpty) {
    filteredList = filteredList.where((word) {
      return word.word.toLowerCase().contains(searchQuery.toLowerCase()) ||
             word.description.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }
  
  // Filter by favorites
  if (showFavoritesOnly) {
    filteredList = filteredList.where((word) => favoriteIds.contains(word.id)).toList();
  }
  
  // Apply sorting
  if (sortOption == 'alphabetical') {
    filteredList.sort((a, b) => a.word.compareTo(b.word));
  } else if (sortOption == 'difficulty') {
    final difficultyOrder = {
      'beginner': 0,
      'intermediate': 1,
      'advanced': 2,
    };
    
    filteredList.sort((a, b) {
      return (difficultyOrder[a.difficultyLevel] ?? 0)
          .compareTo(difficultyOrder[b.difficultyLevel] ?? 0);
    });
  }
  
  return filteredList;
}
  
  /// Fetch a single word by ID
  Future<WordModel> fetchWordById(int wordId) async {
    try {
      final response = await _supabase
          .from('Words')
          .select()
          .eq('id', wordId)
          .single();
      
      return WordModel.fromJson(response);
    } catch (e) {
      print('Error fetching word $wordId: $e');
      throw Exception('Failed to load word. Please check your connection.');
    }
  }

  // Fetch word details including instructions and tips
Future<Map<String, dynamic>> fetchWordDetails(int wordId) async {
  try {
    // Fetch instructions
    final instructionsResponse = await _supabase
        .from('Instructions')
        .select()
        .eq('word_id', wordId)
        .order('step_number');
        
    // Fetch tips
    final tipsResponse = await _supabase
        .from('Tips')
        .select()
        .eq('word_id', wordId);
        
    // Fetch additional word details
    final wordDetailsResponse = await _supabase
        .from('Words')
        .select('difficulty_level, is_common_phrase, translation')
        .eq('id', wordId)
        .single();
        
    // Convert to models
    final instructions = instructionsResponse
        .map<InstructionModel>((item) => InstructionModel.fromJson(item))
        .toList();
        
    final tips = tipsResponse
        .map<TipModel>((item) => TipModel.fromJson(item))
        .toList();
        
    return {
      'instructions': instructions,
      'tips': tips,
      'difficultyLevel': wordDetailsResponse['difficulty_level'] ?? 'beginner',
      'isCommonPhrase': wordDetailsResponse['is_common_phrase'] ?? false,
      'translation': wordDetailsResponse['translation'] ?? '',
    };
  } catch (e) {
    print('Error fetching word details: $e');
    throw Exception('Failed to load word details. Please check your connection.');
  }
}
}