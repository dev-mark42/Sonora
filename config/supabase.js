// Sustituye estos valores por los de tu proyecto Supabase.
// La publishable/anon key puede estar en el navegador; NUNCA pongas service_role aquí.
export const SUPABASE_URL = 'https://uhvhixfxvzdcuvhqacbl.supabase.co/rest/v1/';
export const SUPABASE_ANON_KEY = 'sb_publishable_z6ifSxlfADlL5OyVEyYHDw_dqrXvfYY';
export const isSupabaseConfigured = () => SUPABASE_URL.startsWith('https://') && !SUPABASE_URL.includes('TU-PROYECTO') && !SUPABASE_ANON_KEY.includes('TU_SUPABASE');
