'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import VehicleCard from '@/components/VehicleCard';
import { feedbackService } from '@/services/feedbackService';
import { vehicleService } from '@/services/vehicleService';
import { Vehicle } from '@/types';
import { useAuthStore } from '@/store/authStore';
import { useFavoriteStore } from '@/store/favoriteStore';

export default function FavoritesPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();
  const { favorites } = useFavoriteStore();
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/login');
      return;
    }
    loadFavorites();
  }, [isAuthenticated, favorites]);

  const loadFavorites = async () => {
    try {
      setLoading(true);
      // Load vehicle details for each favorite
      const vehiclePromises = favorites.map(id => vehicleService.getById(id));
      const vehicleData = await Promise.allSettled(vehiclePromises);
      const loadedVehicles = vehicleData
        .filter((result): result is PromiseFulfilledResult<Vehicle> => result.status === 'fulfilled')
        .map(result => result.value);
      setVehicles(loadedVehicles);
    } catch (error) {
      console.error('Failed to load favorites:', error);
    } finally {
      setLoading(false);
    }
  };

  if (!isAuthenticated) {
    return null;
  }

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          ❤️ Xe yêu thích
        </h1>
        <p className="text-gray-600">
          Bạn có {favorites.length} xe trong danh sách yêu thích
        </p>
      </div>

      {loading ? (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
        </div>
      ) : vehicles && vehicles.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {vehicles.map((vehicle) => (
            <VehicleCard key={vehicle.id} vehicle={vehicle} />
          ))}
        </div>
      ) : (
        <div className="text-center py-12 bg-white rounded-lg shadow-md">
          <div className="text-6xl mb-4">🤍</div>
          <p className="text-gray-600 text-lg mb-2">Chưa có xe yêu thích</p>
          <p className="text-gray-500 mb-6">
            Hãy thêm những chiếc xe bạn quan tâm vào danh sách yêu thích
          </p>
          <a
            href="/search"
            className="inline-block bg-primary-600 text-white px-6 py-3 rounded-md hover:bg-primary-700 font-medium"
          >
            Khám phá xe ngay
          </a>
        </div>
      )}
    </div>
  );
}
