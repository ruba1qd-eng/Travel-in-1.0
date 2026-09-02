import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://vtuuogjfmpknlnryxdvp.supabase.co',
    anonKey: 'sb_publishable_7EBiA6_yp_EWE92jV2HuvA_FFPozsDO',
  );
}

final supabase = Supabase.instance.client;
