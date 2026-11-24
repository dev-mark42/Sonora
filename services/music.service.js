import { supabase } from './supabase.client.js';
import { putLocal, getAllLocal } from './offline.service.js';
const EDGE_BASE=()=>{const url=import.meta.env?.VITE_SUPABASE_URL;return url?`${url}/functions/v1`:null;};
export async function searchMusic(query='',source='jamendo',page=1){
  if(supabase){const {data,error}=await supabase.functions.invoke('music-search',{body:{query,source,page}});if(!error&&data?.tracks)return data.tracks;}
  const base=EDGE_BASE();if(base){const response=await fetch(`${base}/music-search`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({query,source,page})});if(response.ok){const data=await response.json();return data.tracks||[];}}
  const cached=await getAllLocal('tracks');if(!navigator.onLine&&cached.length)return cached.filter(t=>`${t.title} ${t.artist}`.toLowerCase().includes(query.toLowerCase()));
  throw new Error('No se pudo conectar con el catálogo. Configura Supabase y la función music-search.');
}
export async function saveTrackMetadata(track){await putLocal('tracks',{...track,id:String(track.id),cachedAt:Date.now()});}
export async function getCatalogCache(){return getAllLocal('tracks');}
export async function getDatabaseCatalog(){if(!supabase)return [];const {data,error}=await supabase.from('tracks').select('*').eq('is_published',true).order('created_at',{ascending:false}).limit(60);if(error)throw error;return data||[];}
