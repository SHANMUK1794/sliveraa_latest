import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:3000/api', // Match the backend port 3000
});

// Mock Auth Interceptor (In real scenario, fetch JWT from localStorage)
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
