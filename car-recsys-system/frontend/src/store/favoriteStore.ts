import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';

interface FavoriteState {
  favorites: string[];
  addFavorite: (vehicleId: string) => void;
  removeFavorite: (vehicleId: string) => void;
  isFavorite: (vehicleId: string) => boolean;
}

export const useFavoriteStore = create<FavoriteState>()(
  persist(
    (set, get) => ({
      favorites: [],
      addFavorite: (vehicleId) =>
        set((state) => ({
          favorites: [...state.favorites, vehicleId],
        })),
      removeFavorite: (vehicleId) =>
        set((state) => ({
          favorites: state.favorites.filter((id) => id !== vehicleId),
        })),
      isFavorite: (vehicleId) => get().favorites.includes(vehicleId),
    }),
    {
      name: 'favorites-storage',
      storage: createJSONStorage(() => 
        typeof window !== 'undefined' ? localStorage : {
          getItem: () => null,
          setItem: () => {},
          removeItem: () => {}
        }
      ),
    }
  )
);
