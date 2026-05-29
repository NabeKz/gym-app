export type OkResult<T> = { ok: true; data: T }
export type ErrResult = { ok: false; status: number }
export type ApiResult<T> = OkResult<T> | ErrResult

export const toResult = <T>(res: { data: T; status: number }): ApiResult<T> =>
  res.status >= 200 && res.status < 300
    ? { ok: true, data: res.data }
    : { ok: false, status: res.status }

export const isOk = <T>(result: ApiResult<T>): result is OkResult<T> => result.ok
