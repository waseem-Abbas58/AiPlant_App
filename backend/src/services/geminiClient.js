const env = require('../config/env');
const { ApiError } = require('../utils/apiResponse');

const GEMINI_MODEL = 'gemini-3.5-flash';

const isConfigured = () => Boolean(String(env.geminiApiKey || '').trim());

const chat = async ({ message, plantName = '', issue = '' }) => {
  if (!isConfigured()) {
    throw new ApiError(503, 'Ask AI is not connected yet. Add GEMINI_API_KEY in backend/.env', {
      code: 'GEMINI_MISSING',
    });
  }

  const text = String(message || '').trim();
  if (!text) {
    throw new ApiError(400, 'Write a question first', { code: 'EMPTY_MESSAGE' });
  }

  const contextLines = [
    'You are Ask Botanist in a plant-care app.',
    'Give short, practical answers. Do not invent a plant species or toxicity facts.',
    'Do not replace a vet or doctor. If unsure, say so.',
    'Format with Markdown so the app can style it:',
    'Start with 1-2 intro sentences.',
    'Use ## for section titles and ### for subtitles.',
    'Use numbered or bullet lists. Each point starts with **Short label:** then one or two sentences.',
    'Keep answers scannable. No walls of same-size text.',
  ];
  if (plantName.trim()) {
    contextLines.push(`The user is asking about this identified plant: ${plantName.trim()}.`);
  }
  if (issue.trim()) {
    contextLines.push(`A health scan suggested this issue: ${issue.trim()}.`);
  }

  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': env.geminiApiKey.trim(),
    },
    body: JSON.stringify({
      systemInstruction: {
        parts: [{ text: contextLines.join(' ') }],
      },
      contents: [{ role: 'user', parts: [{ text }] }],
    }),
  });

  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    const detail = payload.error?.message || `Gemini HTTP ${response.status}`;
    console.error('Gemini chat failed:', response.status, detail);
    throw new ApiError(502, detail, { code: 'GEMINI_ERROR' });
  }

  const reply = payload.candidates?.[0]?.content?.parts
    ?.map((part) => String(part.text || ''))
    .join('\n')
    .trim();

  if (!reply) {
    throw new ApiError(502, 'Ask AI returned an empty reply', { code: 'GEMINI_EMPTY' });
  }

  return { reply, model: GEMINI_MODEL };
};

module.exports = { chat, isConfigured };
