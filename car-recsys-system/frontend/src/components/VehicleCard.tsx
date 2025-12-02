'use client';

'use client';

import { Vehicle } from '@/types';
import Link from 'next/link';
import { useFavoriteStore } from '@/store/favoriteStore';
import { feedbackService } from '@/services/feedbackService';
import { useAuthStore } from '@/store/authStore';

interface VehicleCardProps {
  vehicle: Vehicle;
}

export default function VehicleCard({ vehicle }: VehicleCardProps) {
  const { isFavorite, addFavorite, removeFavorite } = useFavoriteStore();
  const { isAuthenticated } = useAuthStore();
  const favorite = isFavorite(String(vehicle.id));

  const handleFavoriteClick = async (e: React.MouseEvent) => {
    e.preventDefault();
    if (!isAuthenticated) {
      window.location.href = '/login';
      return;
    }

    const vehicleIdStr = String(vehicle.id);
    try {
      if (favorite) {
        await feedbackService.removeFavorite(vehicleIdStr);
        removeFavorite(vehicleIdStr);
      } else {
        await feedbackService.addFavorite(vehicleIdStr);
        addFavorite(vehicleIdStr);
      }
    } catch (error) {
      console.error('Failed to toggle favorite:', error);
    }
  };

  const handleClick = async () => {
    if (isAuthenticated) {
      try {
        await feedbackService.trackInteraction({
          vehicle_id: String(vehicle.id),
          action: 'click',
        });
      } catch (error) {
        console.error('Failed to track click:', error);
      }
    }
  };

  const formatPrice = (price: number | null) => {
    if (!price) return 'Liên hệ';
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND',
    }).format(price);
  };

  return (
    <Link href={`/vehicle/${vehicle.id}`} onClick={handleClick}>
      <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow">
        <div className="relative">
          <img
            src={vehicle.image_url || 'https://via.placeholder.com/400x300?text=No+Image'}
            alt={vehicle.title || 'Vehicle'}
            className="w-full h-48 object-cover"
            onError={(e) => {
              e.currentTarget.src = 'https://via.placeholder.com/400x300?text=No+Image';
            }}
          />
          <button
            onClick={handleFavoriteClick}
            className="absolute top-2 right-2 bg-white rounded-full p-2 hover:bg-gray-100"
          >
            <svg
              className={`w-6 h-6 ${favorite ? 'fill-red-500 text-red-500' : 'text-gray-400'}`}
              fill={favorite ? 'currentColor' : 'none'}
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
              />
            </svg>
          </button>
        </div>
        
        <div className="p-4">
          <h3 className="text-lg font-semibold text-gray-900 truncate">{vehicle.title || 'Untitled'}</h3>
          <p className="text-sm text-gray-600 mb-2">
            {vehicle.brand || 'N/A'} {vehicle.model || ''} {vehicle.year ? `• ${vehicle.year}` : ''}
          </p>
          
          <div className="flex items-center justify-between mb-2">
            <span className="text-xl font-bold text-primary-600">{formatPrice(vehicle.price)}</span>
          </div>
          
          <div className="flex items-center text-sm text-gray-500 space-x-4">
            {vehicle.mileage && (
              <span>🛣️ {vehicle.mileage.toLocaleString()} km</span>
            )}
            {vehicle.transmission && (
              <span>⚙️ {vehicle.transmission}</span>
            )}
          </div>
          
          {vehicle.fuel_type && (
            <div className="mt-2 text-sm text-gray-500">
              ⛽ {vehicle.fuel_type}
            </div>
          )}
          
          {vehicle.location && (
            <div className="mt-2 text-sm text-gray-500">
              📍 {vehicle.location}
            </div>
          )}
        </div>
      </div>
    </Link>
  );
}
