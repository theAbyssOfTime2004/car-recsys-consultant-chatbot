'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import SearchBar from '@/components/SearchBar';
import VehicleCard from '@/components/VehicleCard';
import { vehicleService } from '@/services/vehicleService';
import { recommendationService } from '@/services/recommendationService';
import { SearchFilters, Vehicle, Recommendation } from '@/types';
import { useAuthStore } from '@/store/authStore';

export default function HomePage() {
  const { isAuthenticated } = useAuthStore();
  const [featuredVehicles, setFeaturedVehicles] = useState<Vehicle[]>([]);
  const [recommendations, setRecommendations] = useState<Recommendation[]>([]);
  const [loading, setLoading] = useState(true);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (mounted) {
      loadHomepageData();
    }
  }, [mounted, isAuthenticated]);

  const loadHomepageData = async () => {
    try {
      setLoading(true);
      // Load featured vehicles
      const searchResult = await vehicleService.search({ page_size: 8, sort_by: 'id', sort_order: 'desc' });
      setFeaturedVehicles(searchResult.results);

      // Load personalized recommendations if authenticated
      if (isAuthenticated) {
        const recos = await recommendationService.getHybrid(8);
        setRecommendations(recos);
      }
    } catch (error) {
      console.error('Failed to load homepage data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (filters: SearchFilters) => {
    const params = new URLSearchParams();
    Object.entries(filters).forEach(([key, value]) => {
      if (value) params.append(key, String(value));
    });
    window.location.href = `/search?${params.toString()}`;
  };

  // Prevent hydration mismatch by not rendering auth-dependent content until mounted
  if (!mounted) {
    return (
      <div className="space-y-12">
        {/* Hero Section */}
        <section className="bg-gradient-to-r from-primary-600 to-primary-800 text-white rounded-lg p-8 md:p-12">
          <h1 className="text-4xl md:text-5xl font-bold mb-4">
            Tìm chiếc xe ô tô hoàn hảo của bạn
          </h1>
          <p className="text-xl mb-8">
            Hàng nghìn xe mới và đã qua sử dụng đang chờ bạn khám phá
          </p>
          <SearchBar onSearch={handleSearch} />
        </section>
        
        {/* Loading placeholder */}
        <section>
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          </div>
        </section>
      </div>
    );
  }

  return (
    <div className="space-y-12">
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-primary-600 to-primary-800 text-white rounded-lg p-8 md:p-12">
        <h1 className="text-4xl md:text-5xl font-bold mb-4">
          Tìm chiếc xe ô tô hoàn hảo của bạn
        </h1>
        <p className="text-xl mb-8">
          Hàng nghìn xe mới và đã qua sử dụng đang chờ bạn khám phá
        </p>
        <SearchBar onSearch={handleSearch} />
      </section>

      {/* Personalized Recommendations */}
      {isAuthenticated && recommendations.length > 0 && (
        <section>
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-3xl font-bold text-gray-900">
              🎯 Gợi ý dành cho bạn
            </h2>
            <Link href="/recommendations" className="text-primary-600 hover:text-primary-700 font-medium">
              Xem tất cả →
            </Link>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {recommendations && recommendations.map((reco) => (
              <VehicleCard key={reco.vehicle.id} vehicle={reco.vehicle} />
            ))}
          </div>
        </section>
      )}

      {/* Featured Vehicles */}
      <section>
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-3xl font-bold text-gray-900">
            ⭐ Xe nổi bật
          </h2>
          <Link href="/search" className="text-primary-600 hover:text-primary-700 font-medium">
            Xem tất cả →
          </Link>
        </div>
        {loading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          </div>
        ) : featuredVehicles && featuredVehicles.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {featuredVehicles.map((vehicle) => (
              <VehicleCard key={vehicle.id} vehicle={vehicle} />
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <p className="text-gray-600">Không có xe nào</p>
          </div>
        )}
      </section>

      {/* Quick Categories */}
      <section>
        <h2 className="text-3xl font-bold text-gray-900 mb-6">
          🚙 Danh mục phổ biến
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <Link href="/search?condition=new" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg text-center">
            <div className="text-4xl mb-2">🆕</div>
            <h3 className="font-semibold">Xe mới</h3>
          </Link>
          <Link href="/search?condition=used" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg text-center">
            <div className="text-4xl mb-2">🚗</div>
            <h3 className="font-semibold">Xe đã qua sử dụng</h3>
          </Link>
          <Link href="/search?body_type=SUV" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg text-center">
            <div className="text-4xl mb-2">🚙</div>
            <h3 className="font-semibold">SUV</h3>
          </Link>
          <Link href="/search?body_type=Sedan" className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg text-center">
            <div className="text-4xl mb-2">🚘</div>
            <h3 className="font-semibold">Sedan</h3>
          </Link>
        </div>
      </section>

      {/* CTA Section */}
      {!isAuthenticated && (
        <section className="bg-gray-100 rounded-lg p-8 text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">
            Đăng ký ngay để nhận gợi ý xe phù hợp
          </h2>
          <p className="text-gray-600 mb-6">
            Hệ thống AI của chúng tôi sẽ đề xuất những chiếc xe phù hợp nhất với nhu cầu của bạn
          </p>
          <Link href="/register" className="inline-block bg-primary-600 text-white px-8 py-3 rounded-md hover:bg-primary-700 font-medium">
            Đăng ký miễn phí
          </Link>
        </section>
      )}
    </div>
  );
}
