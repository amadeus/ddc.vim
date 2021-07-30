import { Candidate, Context, DdcOptions, FilterOptions } from "../types.ts";
import { Denops } from "../deps.ts";

export abstract class BaseFilter {
  name = "";

  async onEvent(
    _denops: Denops,
    _context: Context,
    _options: DdcOptions,
    _filterOptions: FilterOptions,
    _filterParams: Record<string, unknown>,
  ): Promise<void> {}

  abstract filter(
    denops: Denops,
    context: Context,
    options: DdcOptions,
    filterOptions: FilterOptions,
    filterParams: Record<string, unknown>,
    completeStr: string,
    candidates: Candidate[],
  ): Promise<Candidate[]>;

  params(): Record<string, unknown> {
    return {} as Record<string, unknown>;
  }
}

export function defaultFilterOptions(): FilterOptions {
  return {
    placeholder: undefined,
  };
}

export function defaultFilterParams(): Record<string, unknown> {
  return {};
}
