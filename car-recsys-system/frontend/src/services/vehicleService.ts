import api from '@/lib/api';
import { Vehicle, SearchFilters, SearchResponse } from '@/types';

export const vehicleService = {
  async search(filters: SearchFilters): Promise<SearchResponse> {
    const response = await api.get<SearchResponse>('/search', {
      params: filters,
    });
    return response.data;
  },

  async getById(id: string): Promise<Vehicle> {
    const response = await api.get<Vehicle>(`/listing/${id}`);
    return response.data;
  },

  async compare(ids: string[]): Promise<Vehicle[]> {
    const response = await api.post<Vehicle[]>('/compare', { vehicle_ids: ids });
    return response.data;
  },
};
