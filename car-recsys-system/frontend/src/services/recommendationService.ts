import api from '@/lib/api';
import { Recommendation } from '@/types';

export const recommendationService = {
  async getCandidates(limit: number = 20): Promise<Recommendation[]> {
    const response = await api.get<Recommendation[]>('/reco/candidate', {
      params: { limit },
    });
    return response.data;
  },

  async getHybrid(limit: number = 20): Promise<Recommendation[]> {
    const response = await api.get<Recommendation[]>('/reco/hybrid', {
      params: { limit },
    });
    return response.data;
  },

  async getSimilar(vehicleId: string, limit: number = 10): Promise<Recommendation[]> {
    const response = await api.get<Recommendation[]>(`/reco/similar/${vehicleId}`, {
      params: { limit },
    });
    return response.data;
  },
};
