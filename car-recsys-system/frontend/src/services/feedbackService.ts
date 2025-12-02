import api from '@/lib/api';

export interface FeedbackRequest {
  vehicle_id: string;
  action: 'view' | 'click' | 'favorite' | 'compare' | 'contact';
  context?: Record<string, any>;
}

export const feedbackService = {
  async trackInteraction(data: FeedbackRequest): Promise<void> {
    await api.post('/feedback', data);
  },

  async getFavorites(): Promise<string[]> {
    const response = await api.get<string[]>('/favorites');
    return response.data;
  },

  async addFavorite(vehicleId: string): Promise<void> {
    await api.post(`/favorites/${vehicleId}`);
  },

  async removeFavorite(vehicleId: string): Promise<void> {
    await api.delete(`/favorites/${vehicleId}`);
  },
};
