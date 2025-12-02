'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import VehicleCard from '@/components/VehicleCard';
import { recommendationService } from '@/services/recommendationService';
import { Recommendation } from '@/types';
import { useAuthStore } from '@/store/authStore';

export default function RecommendationsPage() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();
  const [recommendations, setRecommendations] = useState<Recommendation[]>([]);
  const [loading, setLoading] = useState(true);
  const [mode, setMode] = useState<'hybrid' | 'candidate'>('hybrid');

  useEffect(() => {
    if (!isAuthenticated) {
      router.push('/login');
      return;
    }
    loadRecommendations();
  }, [isAuthenticated, mode]);

  const loadRecommendations = async () => {
    try {
      setLoading(true);
      const recos = mode === 'hybrid'
        ? await recommendationService.getHybrid(20)
        : await recommendationService.getCandidates(20);
      setRecommendations(recos);
    } catch (error) {
      console.error('Failed to load recommendations:', error);
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
        <h1 className="text-3xl font-bold text-gray-900 mb-4">
          🎯 Gợi ý xe dành cho bạn
        </h1>
        <p className="text-gray-600 mb-6">
          Dựa trên lịch sử tìm kiếm và sở thích của bạn
        </p>

        <div className="flex space-x-4">
          <button
            onClick={() => setMode('hybrid')}
            className={`px-6 py-2 rounded-md font-medium ${
              mode === 'hybrid'
                ? 'bg-primary-600 text-white'
                : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
            }`}
          >
            Gợi ý thông minh
          </button>
          <button
            onClick={() => setMode('candidate')}
            className={`px-6 py-2 rounded-md font-medium ${
              mode === 'candidate'
                ? 'bg-primary-600 text-white'
                : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
            }`}
          >
            Phổ biến
          </button>
        </div>
      </div>

      {loading ? (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
        </div>
      ) : recommendations && recommendations.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {recommendations.map((reco) => (
            <div key={reco.vehicle.id} className="relative">
              <VehicleCard vehicle={reco.vehicle} />
              {reco.reason && (
                <div className="mt-2 bg-blue-50 text-blue-700 text-sm p-2 rounded">
                  💡 {reco.reason}
                </div>
              )}
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-12 bg-white rounded-lg shadow-md">
          <div className="text-6xl mb-4">🤔</div>
          <p className="text-gray-600 text-lg mb-2">Chưa có gợi ý</p>
          <p className="text-gray-500 mb-6">
            Hãy tìm kiếm và xem một số xe để chúng tôi có thể đưa ra gợi ý phù hợp hơn
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
