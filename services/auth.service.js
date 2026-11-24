import { supabase } from './supabase.client.js';
export async function signIn(email,password){if(!supabase)throw new Error('Configura Supabase primero.');const {data,error}=await supabase.auth.signInWithPassword({email,password});if(error)throw error;return data.user;}
export async function signUp(email,password){if(!supabase)throw new Error('Configura Supabase primero.');const {data,error}=await supabase.auth.signUp({email,password});if(error)throw error;return data.user;}
export async function signOut(){if(supabase)await supabase.auth.signOut();}
export async function currentUser(){if(!supabase)return null;const {data}=await supabase.auth.getUser();return data.user||null;}
