import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: const String.fromEnvironment('EXPO_PUBLIC_SUPABASE_URL', 
      defaultValue: 'https://vtuuogjfmpknlnryxdvp.supabase.co'),
    anonKey: const String.fromEnvironment('EXPO_PUBLIC_SUPABASE_ANON_KEY', 
      defaultValue: 'sb_publishable_7EBiA6_yp_EWE92jV2HuvA_FFPozsDO'),
  );
}

final supabase = Supabase.instance.client;
