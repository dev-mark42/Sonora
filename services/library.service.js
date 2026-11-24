import { supabase } from './supabase.client.js';
import {getAllLocal,putLocal,deleteLocal} from './offline.service.js';
export async function listFavorites(){const local=await getAllLocal('favorites');if(!supabase)return local;const {data,error}=await supabase.from('favorites').select('track_id,tracks(*)');if(error)return local;return (data||[]).map(x=>x.tracks).filter(Boolean);}
export async function toggleFavorite(track,user){const id=String(track.id);const local=await getAllLocal('favorites');if(local.some(x=>x.id===id)){await deleteLocal('favorites',id);if(supabase&&user)await supabase.from('favorites').delete().eq('track_id',id);return false;}await putLocal('favorites',{id,...track});if(supabase&&user)await supabase.from('favorites').upsert({user_id:user.id,track_id:id});return true;}
export async function listPlaylists(){return getAllLocal('playlists');}
export async function createPlaylist(name){const item={id:crypto.randomUUID(),name,track_ids:[],created_at:new Date().toISOString()};await putLocal('playlists',item);return item;}
