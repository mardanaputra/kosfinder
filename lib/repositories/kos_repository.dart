import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos_model.dart';

class KosRepository {
  final SupabaseClient? _client;

  KosRepository({SupabaseClient? client}) : _client = client;

  SupabaseClient get client => _client ?? Supabase.instance.client;

  Future<List<KosModel>> getKosList() async {
    final response = await client
        .from('kos')
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => KosModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<KosModel?> getKosById(String id) async {
    final response =
        await client.from('kos').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return KosModel.fromJson(response);
  }

  Future<List<KosModel>> getKosByOwner(String ownerId) async {
    final response = await client
        .from('kos')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => KosModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<KosModel> createKos(KosModel kos) async {
    final response = await client
        .from('kos')
        .insert(kos.toJson(includeId: false))
        .select()
        .single();

    return KosModel.fromJson(response);
  }

  Future<KosModel> updateKos(KosModel kos) async {
    final response = await client
        .from('kos')
        .update(kos.toJson(includeId: false))
        .eq('id', kos.id)
        .select()
        .single();

    return KosModel.fromJson(response);
  }

  Future<void> deleteKos(String id) async {
    await client.from('kos').delete().eq('id', id);
  }
}
