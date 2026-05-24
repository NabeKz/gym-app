import type { Member } from "@/shared/generated/openapi.gen"

const KEY = "gym_member"

export const getStoredMember = (): Member | null => {
  const raw = localStorage.getItem(KEY)
  if (!raw) return null
  try {
    return JSON.parse(raw) as Member
  } catch {
    return null
  }
}

export const storeMember = (member: Member): void => {
  localStorage.setItem(KEY, JSON.stringify(member))
}

export const clearMember = (): void => {
  localStorage.removeItem(KEY)
}
