import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { SUPABASE_URL, SUPABASE_ANON_KEY, isSupabaseConfigured } from '../config/supabase.js';
export const supabase = isSupabaseConfigured() ? createClient(SUPABASE_URL, SUPABASE_ANON_KEY) : null;
export { isSupabaseConfigured };
