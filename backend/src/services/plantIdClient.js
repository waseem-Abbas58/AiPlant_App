const env = require('../config/env');
const { ApiError } = require('../utils/apiResponse');

const BASE_URL = 'https://plant.id/api/v3';

const IDENTIFY_DETAILS =
  'common_names,url,description,taxonomy,image,watering,' +
  'best_watering,best_light_condition,best_soil_type,toxicity,' +
  'propagation_methods';

const DIAGNOSE_DETAILS =
  'local_name,description,treatment,classification,common_names,url';

const requireKey = () => {
  if (!String(env.plantIdApiKey || '').trim()) {
    throw new ApiError(503, 'Plant.id is not configured');
  }
};

const postIdentification = async ({ images, details, extra = {} }) => {
  requireKey();

  const url = new URL(`${BASE_URL}/identification`);
  url.searchParams.set('details', details);
  url.searchParams.set('language', 'en');

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 45000);

  let response;
  try {
    response = await fetch(url, {
      method: 'POST',
      headers: {
        'Api-Key': env.plantIdApiKey.trim(),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        images: images.map((file) => file.buffer.toString('base64')),
        ...extra,
      }),
      signal: controller.signal,
    });
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new ApiError(504, 'Plant.id request timed out');
    }
    throw new ApiError(502, 'Could not reach Plant.id');
  } finally {
    clearTimeout(timer);
  }

  let data = {};
  try {
    data = await response.json();
  } catch (_error) {
    data = {};
  }

  if (response.status === 401 || response.status === 403) {
    throw new ApiError(503, 'Plant.id rejected the API key');
  }
  if (response.status === 429) {
    throw new ApiError(429, 'Plant.id rate limit reached');
  }
  if (!response.ok) {
    throw new ApiError(502, 'Plant.id request failed', { status: response.status });
  }

  return data;
};

const identify = (images, categoryId = 'plant') => {
  const extra = { similar_images: true };
  if (categoryId === 'tree') {
    extra.suggestion_filter = { classification: 'tree' };
  }
  return postIdentification({ images, details: IDENTIFY_DETAILS, extra });
};

const diagnose = (images) => {
  return postIdentification({
    images,
    details: DIAGNOSE_DETAILS,
    extra: { similar_images: true, health: 'only' },
  });
};

module.exports = { identify, diagnose };
