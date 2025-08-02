// File: frontend/src/services/api.js
// Description: API service for localhost development with integrated database

import axios from "axios";

// ========= BASE URLs FOR LOCAL DEVELOPMENT =========
// Backend berjalan di localhost Flask default port 5000
const BASE_URL = process.env.REACT_APP_FAKTUR_SERVICE_URL || "http://localhost:5000";

// ========= AXIOS INSTANCES =========

// 🔹 Main API instance untuk semua requests
export const api = axios.create({
  baseURL: BASE_URL,
  timeout: 300000, // 5 minutes untuk OCR processing
  headers: {
    "Content-Type": "application/json",
    "Accept": "application/json",
  },
});

// 🔸 Form API instance untuk file uploads
export const formApi = axios.create({
  baseURL: BASE_URL,
  timeout: 300000,
  headers: {
    "Accept": "application/json",
  },
});

// ========= ERROR HANDLING =========

// 🛡️ Error interceptor untuk API
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error("❌ API Error:", error.response?.status, error.message);
    
    if (error.response?.status === 0 || error.code === 'ERR_NETWORK') {
      console.error('🌐 Network Error - Backend tidak berjalan di localhost:5000');
    }
    return Promise.reject(error);
  }
);

// 🛡️ Error interceptor untuk Form API
formApi.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error("❌ Upload Error:", error.response?.status, error.message);
    return Promise.reject(error);
  }
);

// ========= RESPONSE HELPERS =========

// 🔄 Transform backend response to frontend expected format
export const transformBackendResponse = (backendResponse) => {
  // Response dari backend berupa object dengan success dan results
  if (backendResponse.success && backendResponse.results) {
    return {
      data: {
        results: backendResponse.results
      }
    };
  }
  
  return backendResponse;
};

// ========= API ENDPOINTS =========

// --- FAKTUR ENDPOINTS ---
export const processFaktur = async (formData) => {
  const response = await formApi.post("/api/process", formData, {
    headers: { "Content-Type": "multipart/form-data" },
  });
  
  return {
    ...response,
    data: transformBackendResponse(response.data).data
  };
};

export const saveFaktur = (data) => api.post("/api/save-faktur", data);
export const deleteFaktur = (jenis, id) => api.delete(`/api/faktur/${jenis}/${id}`);
export const fetchFakturHistory = (page = 1, per_page = 50) => 
  api.get(`/api/faktur-history?page=${page}&per_page=${per_page}`);

// --- BUKTI SETOR ENDPOINTS ---
export const processBuktiSetor = (formData) => formApi.post("/api/bukti_setor/process", formData);
export const saveBuktiSetor = (data) => api.post("/api/save-bukti-setor", data);
export const deleteBuktiSetor = (id) => api.delete(`/api/bukti_setor/delete/${id}`);
export const fetchBuktiSetorHistory = (page = 1, per_page = 50) => 
  api.get(`/api/bukti-setor-history?page=${page}&per_page=${per_page}`);

// ========= UTILITIES =========

// Error handler utility
export const handleApiError = (error) => {
  if (error.code === 'ERR_NETWORK') {
    return 'Koneksi ke server gagal. Pastikan backend berjalan di localhost:5000.';
  }
  if (error.response?.status === 404) {
    return 'Endpoint tidak ditemukan. Periksa URL API.';
  }
  if (error.response?.status === 500) {
    return 'Terjadi kesalahan di server. Silakan coba lagi nanti.';
  }
  return error.message || 'Terjadi kesalahan yang tidak diketahui.';
};

// Test connection to backend
export const testFakturConnection = async () => {
  try {
    const response = await api.get("/");
    return { success: true, status: response.status };
  } catch (error) {
    return { success: false, error: error.message };
  }
};

// Helper function untuk construct preview URL dari uploads folder
export const getPreviewUrl = (itemData) => {
  if (itemData?.preview_image) {
    return `${BASE_URL}/uploads/${itemData.preview_image}`;
  }
  
  if (itemData?.preview_url) {
    return `${BASE_URL}${itemData.preview_url}`;
  }
  
  return null;
};