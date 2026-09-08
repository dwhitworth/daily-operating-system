// Shared DOS date/path helpers for pi extensions.
//
// NOT an extension itself (no top-level *.ts / */index.ts match), so pi's
// auto-loader ignores it — it's imported by the sibling extensions.
//
// LOCALE: every date is computed in DOS_TZ (default Australia/Sydney) and
// formatted with DOS_LOCALE (default en-AU, i.e. DD/MM/YYYY). Both are read from
// the environment so the same code works wherever the DOS is run — set them in
// your shell profile, not here. Zones that observe daylight saving flip their
// abbreviation (AEST<->AEDT), so we read the real abbreviation rather than assume.

import { join } from "node:path";

/** IANA zone all DOS dates are computed in. */
export const DOS_TZ = process.env.DOS_TZ ?? "Australia/Sydney";
/** BCP-47 locale used for the weekday name and tz abbreviation. */
export const DOS_LOCALE = process.env.DOS_LOCALE ?? "en-AU";

export interface DosDate {
  /** YYYY-MM-DD (DOS_TZ local) */
  iso: string;
  /** DD/MM/YYYY — the DOS house convention, independent of DOS_LOCALE */
  au: string;
  /** Full weekday name, e.g. "Friday" */
  weekday: string;
  /** ISO 8601 week number (matches `date +%V`) */
  week: number;
  /** Zero-padded ISO week, e.g. "34" */
  weekPad: string;
  /** Calendar year (DOS_TZ local) */
  year: number;
  /** true on Monday (DOS_TZ local) — the /weekly-scan trigger */
  isMonday: boolean;
  /** Timezone abbreviation actually in effect, e.g. "AEST" | "AEDT" */
  tz: string;
}

function pad2(n: number): string {
  return String(n).padStart(2, "0");
}

/** ISO 8601 week number for a Y/M/D (local, no tz math — caller passes local parts). */
function isoWeek(year: number, month1: number, day: number): number {
  const date = new Date(Date.UTC(year, month1 - 1, day));
  const dayNum = (date.getUTCDay() + 6) % 7; // Mon=0..Sun=6
  date.setUTCDate(date.getUTCDate() - dayNum + 3); // nearest Thursday
  const firstThursday = date.getTime();
  date.setUTCMonth(0, 1);
  if (date.getUTCDay() !== 4) {
    date.setUTCMonth(0, 1 + ((4 - date.getUTCDay() + 7) % 7));
  }
  return 1 + Math.round((firstThursday - date.getTime()) / (7 * 24 * 3600 * 1000));
}

/** Resolve "now" as DOS_TZ-local calendar parts + tz label. */
export function dosDate(now: Date = new Date()): DosDate {
  const parts = new Intl.DateTimeFormat(DOS_LOCALE, {
    timeZone: DOS_TZ,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    weekday: "long",
    timeZoneName: "short",
  }).formatToParts(now);

  const get = (t: string) => parts.find((p) => p.type === t)?.value ?? "";
  const year = Number(get("year"));
  const month = Number(get("month"));
  const day = Number(get("day"));
  const weekday = get("weekday");
  // Some ICU builds give "GMT+10" rather than a real abbreviation; pass it through
  // either way, the label is informational.
  const tz = get("timeZoneName");
  const week = isoWeek(year, month, day);

  return {
    iso: `${year}-${pad2(month)}-${pad2(day)}`,
    au: `${pad2(day)}/${pad2(month)}/${year}`,
    weekday,
    week,
    weekPad: pad2(week),
    year,
    isMonday: weekday === "Monday",
    tz,
  };
}

/** @deprecated name kept so existing imports keep working. Use dosDate(). */
export const sydneyDate = dosDate;

/** DOS/Journal/<year>/week-<WW> for a given DosDate. */
export function weekDir(cwd: string, d: DosDate): string {
  return join(cwd, "DOS", "Journal", String(d.year), `week-${d.weekPad}`);
}

/** Absolute path to today's battle card. */
export function battleCardPath(cwd: string, d: DosDate): string {
  return join(weekDir(cwd, d), `battle-card-${d.iso}.md`);
}

/** Absolute path to today's daily journal entry. */
export function journalEntryPath(cwd: string, d: DosDate): string {
  return join(weekDir(cwd, d), `${d.iso}.md`);
}

/** cwd-relative form for display, else the absolute path. */
export function relTo(cwd: string, abs: string): string {
  return abs.startsWith(cwd + "/") ? abs.slice(cwd.length + 1) : abs;
}
