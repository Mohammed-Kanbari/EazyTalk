import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesService {
  final _supabase = Supabase.instance.client;
  final _auth = FirebaseAuth.instance;
  
  // Get user's favorite word IDs
  Future<Set<int>> getUserFavorites() async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        return {};
      }
      
      final response = await _supabase
          .from('UserFavorites')
          .select('word_id')
          .eq('user_id', user.uid);
      
      return response.map<int>((item) => item['word_id'] as int).toSet();
    } catch (e) {
      print('Error loading favorites: $e');
      return {};
    }
  }
  
  // Toggle favorite status for a word
  Future<bool> toggleFavorite(int wordId) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        return false;
      }
      
      // Check if word is already favorited
      final existing = await _supabase
          .from('UserFavorites')
          .select()
          .eq('user_id', user.uid)
          .eq('word_id', wordId);
      
      if (existing.isEmpty) {
        // Add to favorites
        await _supabase.from('UserFavorites').insert({
          'user_id': user.uid,
          'word_id': wordId,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      } else {
        // Remove from favorites
        await _supabase
            .from('UserFavorites')
            .delete()
            .eq('user_id', user.uid)
            .eq('word_id', wordId);
        return false;
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }
}