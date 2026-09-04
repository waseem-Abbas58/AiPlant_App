const MIN_IDENTIFY_CONFIDENCE = 0.18;
const MIN_DIAGNOSE_CONFIDENCE = 0.28;
const MIN_ALT_DIAGNOSE_CONFIDENCE = 0.18;
const MIN_SIMILAR_CONFIDENCE = 0.20;

const asMap = (raw) => (raw && typeof raw === 'object' && !Array.isArray(raw) ? { ...raw } : {});

const asString = (raw) => (typeof raw === 'string' ? raw.trim() : '');

const asNumber = (raw) => (typeof raw === 'number' && Number.isFinite(raw) ? raw : null);

const asStringList = (raw) => {
  if (!Array.isArray(raw)) return [];
  return raw.filter((item) => typeof item === 'string').map((item) => item.trim()).filter(Boolean);
};

const firstString = (raw) => {
  const list = asStringList(raw);
  return list.length === 0 ? '' : list[0];
};

const firstNonEmpty = (values) => values.find((value) => String(value || '').trim()) || '';

const probability = (item) => {
  const value = asNumber(item.probability) ?? 0;
  return Math.min(1, Math.max(0, value));
};

const firstSentence = (text) => {
  const trimmed = String(text || '').trim();
  if (!trimmed) return '';
  const match = trimmed.match(/(.+?[.!?])(\s|$)/);
  if (!match) {
    return trimmed.length > 160 ? `${trimmed.slice(0, 157).trim()}…` : trimmed;
  }
  return match[1].trim();
};

const suggestionList = (raw) => {
  const root = asMap(raw);
  if (!Array.isArray(root.suggestions)) return [];
  return root.suggestions.filter((item) => item && typeof item === 'object' && !Array.isArray(item));
};

const isPlant = (result) => {
  const block = result.is_plant;
  if (block && typeof block === 'object') {
    if (typeof block.binary === 'boolean') return block.binary;
    const value = asNumber(block.probability);
    if (value != null) return value >= 0.35;
  }
  if (typeof block === 'boolean') return block;
  if (typeof block === 'number') return block >= 0.35;
  return true;
};

const imageUrl = (details, similar) => {
  const urls = imageUrls(details, similar, 1);
  return urls[0] || '';
};

const imageUrls = (details, similar, limit = 6) => {
  const urls = [];
  const push = (value) => {
    const url = asString(value);
    if (url.startsWith('http') && !urls.includes(url) && urls.length < limit) {
      urls.push(url);
    }
  };

  const image = details.image;
  if (typeof image === 'string') push(image);
  if (image && typeof image === 'object') {
    push(image.value);
    push(image.url);
  }
  if (Array.isArray(similar)) {
    similar.forEach((item) => {
      if (!item || typeof item !== 'object') return;
      push(item.url);
      push(item.url_small);
    });
  }
  return urls;
};

const kindFor = (categoryId, details) => {
  const kingdom = asString(asMap(details.taxonomy).kingdom).toLowerCase();
  if (kingdom.includes('fungi')) return 'mushroom';
  if (categoryId === 'tree') return 'tree';
  if (categoryId === 'mushroom') return 'mushroom';
  if (categoryId === 'weed') return 'weed';
  return 'plant';
};

const toxicToward = (text, subjects) => {
  const lower = text.toLowerCase();
  return subjects.some((subject) => {
    if (new RegExp(`non[- ]?toxic[^.\\n]{0,40}${subject}`).test(lower)) return false;
    if (new RegExp(`not toxic[^.\\n]{0,40}${subject}`).test(lower)) return false;
    return new RegExp(`toxic[^.\\n]{0,40}${subject}`).test(lower);
  });
};

const toxicity = (text) => {
  if (!text) return null;
  const pets = toxicToward(text, ['cat', 'dog', 'pet', 'animal']);
  const kids = toxicToward(text, ['human', 'child', 'kid', 'people', 'ingest']);
  return {
    toxicToPets: pets,
    toxicToKids: kids,
    summary: text,
    petsDetail: pets ? text : '',
    kidsDetail: kids ? text : '',
  };
};

const lightLevel = (text) => {
  const lower = text.toLowerCase();
  if (lower.includes('full sun') || lower.includes('direct') || lower.includes('bright')) {
    return 'Bright';
  }
  if (lower.includes('low') || lower.includes('shade') || lower.includes('dark')) {
    return 'Low';
  }
  return 'Medium';
};

const care = (watering, lightText) => {
  const min = asNumber(watering.min) ?? 2;
  const max = asNumber(watering.max) ?? 3;
  const avg = (min + max) / 2;
  const waterDays = avg <= 1.5 ? 14 : avg <= 2.5 ? 10 : avg <= 3.5 ? 7 : avg <= 4.5 ? 4 : 3;
  const waterAmount = avg <= 2.2 ? 'Light' : avg <= 3.6 ? 'Moderate' : 'Generous';
  return {
    waterDays,
    mistDays: 3,
    fertilizerMonths: 2,
    rotateMonths: 1,
    cutMonths: 6,
    waterAmount,
    location: 'Indoor',
    potSize: 'Medium',
    lightLevel: lightLevel(lightText),
    syncCalendar: true,
    autoReminders: false,
    waterTime: '9:00 AM',
    lastWateredAt: null,
    nextWaterOn: null,
  };
};

const careHighlights = (watering, waterText, lightText, soilText) => {
  const highlights = [];
  if (waterText) highlights.push(firstSentence(waterText));
  else if (Object.keys(watering).length > 0) highlights.push('When the top soil is dry');
  if (lightText) highlights.push(firstSentence(lightText));
  if (soilText) highlights.push(firstSentence(soilText));
  return highlights.slice(0, 3);
};

const failedIdentify = (failReason) => ({
  imagePath: '',
  commonName: '',
  scientificName: '',
  confidence: 0,
  careHighlights: [],
  similarMatches: [],
  kind: 'unknown',
  toxicity: null,
  care: null,
  sampleImageAsset: null,
  sampleImageUrl: null,
  referenceImageUrls: [],
  isIdentified: false,
  failReason,
  isLocalPreview: false,
});

const identify = (json, { categoryId = 'plant' } = {}) => {
  const result = asMap(json.result);
  if (!isPlant(result)) return failedIdentify('notPlant');

  const suggestions = suggestionList(result.classification);
  if (suggestions.length === 0) return failedIdentify('noMatch');

  const top = suggestions[0];
  const confidence = probability(top);
  if (confidence < MIN_IDENTIFY_CONFIDENCE) return failedIdentify('noMatch');

  const details = asMap(top.details);
  const scientific = asString(top.name);
  const common = firstString(details.common_names) || scientific;
  if (!common) return failedIdentify('noMatch');

  const similarMatches = [];
  for (let index = 1; index < suggestions.length && similarMatches.length < 3; index += 1) {
    const item = suggestions[index];
    const itemDetails = asMap(item.details);
    const name = firstString(itemDetails.common_names);
    const science = asString(item.name);
    const label = name || science;
    if (!label) continue;
    if (probability(item) < MIN_SIMILAR_CONFIDENCE) continue;
    similarMatches.push({
      commonName: label,
      scientificName: science,
      confidence: probability(item),
      imageAsset: null,
      imageUrl: imageUrl(itemDetails, item.similar_images),
    });
  }

  const watering = asMap(details.watering);
  const lightText = asString(details.best_light_condition);
  const waterText = asString(details.best_watering);
  const soilText = asString(details.best_soil_type);

  return {
    imagePath: '',
    commonName: common,
    scientificName: scientific,
    confidence,
    careHighlights: careHighlights(watering, waterText, lightText, soilText),
    similarMatches,
    kind: kindFor(categoryId, details),
    toxicity: toxicity(asString(details.toxicity)),
    care: care(watering, lightText),
    sampleImageAsset: null,
    sampleImageUrl: imageUrl(details, top.similar_images),
    referenceImageUrls: imageUrls(details, top.similar_images, 6),
    isIdentified: true,
    failReason: 'none',
    isLocalPreview: false,
  };
};

const humanSymptom = (id) => {
  switch (id) {
    case 'yellow_leaves':
      return 'Yellow leaves';
    case 'brown_spots':
      return 'Brown spots';
    case 'drooping':
      return 'Drooping';
    case 'holes':
      return 'Holes / bites';
    case 'white_coating':
      return 'White coating';
    case 'pests':
      return 'Pests';
    default:
      return 'A health concern';
  }
};

const symptomKeywords = (symptomId) => {
  switch (symptomId) {
    case 'yellow_leaves':
      return ['yellow', 'chlorosis', 'nitrogen', 'nutrient', 'water'];
    case 'brown_spots':
      return ['spot', 'blight', 'rust', 'anthracnose', 'leaf spot'];
    case 'drooping':
      return ['wilt', 'droop', 'overwater', 'underwater', 'root'];
    case 'holes':
      return ['insect', 'feeding', 'chew', 'pest', 'slug', 'hole'];
    case 'white_coating':
      return ['powdery', 'mildew', 'mealy', 'mold', 'white'];
    case 'pests':
      return ['pest', 'insect', 'mite', 'aphid', 'scale', 'whitefly'];
    default:
      return [];
  }
};

const matchesKeywords = (item, keywords) => {
  const details = asMap(item.details);
  const hay = [
    asString(item.name),
    asString(details.local_name),
    asString(details.description),
    ...asStringList(details.common_names),
    ...asStringList(details.classification),
  ]
    .join(' ')
    .toLowerCase();
  return keywords.some((keyword) => hay.includes(keyword));
};

const rankDiseases = (suggestions, symptomId) => {
  if (suggestions.length === 0) return suggestions;
  const keywords = symptomKeywords(symptomId);
  if (keywords.length === 0) return suggestions;
  const top = probability(suggestions[0]);
  return [...suggestions].sort((left, right) => {
    const leftScore = probability(left) + (probability(left) >= top - 0.15 && matchesKeywords(left, keywords) ? 0.08 : 0);
    const rightScore = probability(right) + (probability(right) >= top - 0.15 && matchesKeywords(right, keywords) ? 0.08 : 0);
    return rightScore - leftScore;
  });
};

const isHarmful = (item) => {
  const details = asMap(item.details);
  if (typeof details.is_harmful === 'boolean') return details.is_harmful;
  const name = asString(item.name).toLowerCase();
  return !name.includes('senescence') && !name.includes('flower') && !name.includes('lichen') && !name.includes('harmless');
};

const splitAdvice = (text) => {
  const trimmed = String(text || '').trim();
  if (!trimmed) return [];
  const byLine = trimmed
    .split(/[\n•]+|(?:\d+\.\s+)/)
    .map((item) => item.trim())
    .filter(Boolean);
  if (byLine.length > 1) return byLine;
  const sentence = firstSentence(trimmed);
  return sentence ? [sentence] : [];
};

const adviceList = (raw) => {
  if (Array.isArray(raw)) {
    return raw.filter((item) => typeof item === 'string').flatMap(splitAdvice).filter(Boolean).slice(0, 6);
  }
  if (typeof raw === 'string') return splitAdvice(raw).filter(Boolean).slice(0, 6);
  return [];
};

const diseaseKind = (details, name) => {
  const raw = [...asStringList(details.classification), name].join(' ').toLowerCase();
  if (raw.includes('fung')) return 'Fungus';
  if (raw.includes('bacter')) return 'Bacteria';
  if (raw.includes('virus')) return 'Virus';
  if (raw.includes('insect') || raw.includes('pest') || raw.includes('mite') || raw.includes('aphid')) {
    return 'Pest';
  }
  if (raw.includes('nutrient') || raw.includes('deficien')) return 'Nutrient';
  if (raw.includes('water') || raw.includes('abiotic')) return 'Abiotic';
  const first = firstString(details.classification);
  if (!first) return 'Issue';
  return first[0].toUpperCase() + first.slice(1);
};

const emptyDiagnose = () => ({
  healthy: false,
  title: '',
  summary: '',
  steps: [],
  symptoms: [],
  severity: '',
  kind: '',
  prevention: '',
  caution: '',
  hosts: '',
  spreadsWhen: '',
  imageAsset: null,
  imageUrl: '',
  confidence: 0,
  diseaseName: '',
  isLocalPreview: false,
  failReason: 'none',
  alternatives: [],
});

const noMatchDiagnose = () => ({
  ...emptyDiagnose(),
  title: 'Could not diagnose',
  summary: 'We could not match a clear issue from these photos. Try one damaged leaf in brighter light.',
  failReason: 'noMatch',
});

const unnamedIssue = () => ({
  ...emptyDiagnose(),
  healthy: false,
  title: 'Issue not named',
  summary:
    'This photo looks unhealthy, but no disease name was confident enough to show.',
  steps: [
    'Photograph one damaged leaf so it fills the frame.',
    'Use clear daylight and keep the camera steady.',
    'Add that closer photo here to confirm the issue.',
  ],
});

const healthyHint = (plantName, symptomId) => {
  const who = plantName.trim() || 'This plant';
  const marked = symptomId.trim()
    ? ` You marked ${humanSymptom(symptomId).toLowerCase()} — watch that area for a few days.`
    : '';
  return {
    ...emptyDiagnose(),
    healthy: true,
    title: 'Looks healthy',
    summary: `${who} did not show a clear disease, pest, or nutrient problem in these photos.${marked}`,
    confidence: 0.7,
    steps: [
      'Keep your usual watering and light routine.',
      'Scan again if new spots, pests, or drooping appear.',
    ],
  };
};

const issueName = (item) => {
  const details = asMap(item.details);
  return firstNonEmpty([
    asString(details.local_name),
    firstString(details.common_names),
    asString(item.name),
  ]);
};

const mapIssue = (chosen, { plantName = '', symptomId = '' } = {}) => {
  const details = asMap(chosen.details);
  const diseaseName = issueName(chosen);
  const description = asString(details.description);
  const treatment = asMap(details.treatment);
  const biological = adviceList(treatment.biological);
  const chemical = adviceList(treatment.chemical);
  const prevention = adviceList(treatment.prevention);
  const kind = diseaseKind(details, diseaseName);
  const confidence = probability(chosen);

  let summary = '';
  if (plantName.trim()) summary += `On ${plantName.trim()}: `;
  if (description) summary += description;
  else if (diseaseName) summary += `Photos also match ${diseaseName}.`;
  else summary += 'A possible health issue showed up in the photos.';
  if (symptomId.trim()) summary += ` You marked ${humanSymptom(symptomId).toLowerCase()}.`;

  const symptoms = [];
  if (symptomId.trim()) symptoms.push(`You selected: ${humanSymptom(symptomId)}`);
  const sentence = firstSentence(description);
  if (sentence && sentence.length < 180) symptoms.push(sentence);

  return {
    ...emptyDiagnose(),
    healthy: false,
    title: diseaseName || `Possible ${kind} issue`,
    diseaseName,
    summary,
    confidence,
    kind,
    severity: confidence >= 0.75 ? 'High' : confidence >= 0.5 ? 'Moderate' : 'Mild',
    symptoms,
    steps: [...biological, ...chemical].slice(0, 6),
    prevention: prevention.join(' '),
    caution: chemical.length === 0 ? '' : 'Keep sprays away from pets and kids. Follow the product label.',
    imageUrl: imageUrl(details, chosen.similar_images),
  };
};

const diagnose = (json, { plantName = '', symptomId = '' } = {}) => {
  const result = asMap(json.result);
  const healthyBlock = asMap(result.is_healthy);
  const healthyFlag =
    typeof healthyBlock.binary === 'boolean'
      ? healthyBlock.binary
      : (asNumber(healthyBlock.probability) ?? 0) >= 0.6;

  const ranked = rankDiseases(suggestionList(result.disease), symptomId);
  const top = ranked[0] || null;
  const topConfidence = top ? probability(top) : 0;
  const topHarmful = ranked.find((item) => isHarmful(item) && probability(item) >= MIN_DIAGNOSE_CONFIDENCE) || null;

  const useIssue = Boolean(topHarmful) && (!healthyFlag || probability(topHarmful) >= 0.45);
  const fallback = !useIssue && !healthyFlag && Boolean(top) && topConfidence >= MIN_DIAGNOSE_CONFIDENCE;

  if (!useIssue && !fallback) {
    return healthyFlag ? healthyHint(plantName, symptomId) : unnamedIssue();
  }

  const chosen = topHarmful || top;
  if (!chosen) return noMatchDiagnose();

  const primary = mapIssue(chosen, { plantName, symptomId });
  const used = new Set([issueName(chosen).toLowerCase()]);
  primary.alternatives = ranked
    .filter((item) => item !== chosen && probability(item) >= MIN_ALT_DIAGNOSE_CONFIDENCE)
    .map((item) => mapIssue(item))
    .filter((issue) => {
      const key = String(issue.diseaseName || issue.title).trim().toLowerCase();
      if (!key || used.has(key)) return false;
      used.add(key);
      return true;
    })
    .slice(0, 3);
  return primary;
};

module.exports = { identify, diagnose };
