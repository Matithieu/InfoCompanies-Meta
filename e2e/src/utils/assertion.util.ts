export function asserts(expr: boolean, message = 'Assertion failed!'): asserts expr {
  if (!expr) {
    console.error(message)
    throw new Error(message)
  }
}

export function isNotNU<T>(value: T): value is NonNullable<T> {
  return value !== null && value !== undefined
}

export function NNU<T extends Exclude<unknown, null | undefined>>(
  value: T | null | undefined,
  message = 'An unexpected null value has been provided!',
): NonNullable<T> {
  asserts(isNotNU(value), message)
  return value
}

export declare function assertNever(_: never): void
