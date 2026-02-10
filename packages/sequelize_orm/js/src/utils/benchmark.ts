
/**
 * Simple benchmark wrapper for any function
 * Measures execution time and optionally memory usage
 */

type BenchmarkResult<T> = {
    result: T;
    timeMs: number;
    memoryBytes?: number;
};

/**
 * Wraps any function to measure its execution time
 * 
 * @example
 * const benchmarked = benchmark(myFunction);
 * const { result, timeMs } = await benchmarked(arg1, arg2);
 * console.error(`Took ${timeMs}ms`);
 */
export function benchmark<T extends (...args: any[]) => any>(
    fn: T
): (...args: Parameters<T>) => Promise<BenchmarkResult<Awaited<ReturnType<T>>>> {
    return async (...args: Parameters<T>) => {
        const start = performance.now();
        const memBefore = typeof process !== 'undefined' ? process.memoryUsage().heapUsed : undefined;

        const result = await fn(...args);

        const timeMs = performance.now() - start;
        const memoryBytes = memBefore !== undefined && typeof process !== 'undefined'
            ? process.memoryUsage().heapUsed - memBefore
            : undefined;

        return { result, timeMs, memoryBytes };
    };
}

/**
 * Simplified version that just logs to console
 * 
 * @example
 * const benchmarked = benchmarkLog(myFunction, 'MyFunction');
 * await benchmarked(arg1, arg2); // Logs: "MyFunction took 23.45ms"
 */
export function benchmarkLog<T extends (...args: any[]) => any>(
    fn: T,
    name?: string
): (...args: Parameters<T>) => Promise<ReturnType<T>> {
    const fnName = name || fn.name || 'Function';

    return async (...args: Parameters<T>) => {
        const start = performance.now();
        const result = await fn(...args);
        const timeMs = performance.now() - start;

        console.error(`[BENCHMARK] ${fnName} took ${timeMs.toFixed(3)}ms`);

        return result;
    };
}

/**
 * Inline benchmark - wrap any code block
 * 
 * @example
 * const { result, timeMs } = await benchmarkBlock(async () => {
 *   // your code here
 *   return someValue;
 * });
 */
export async function benchmarkBlock<T>(
    block: () => T | Promise<T>
): Promise<BenchmarkResult<Awaited<T>>> {
    const start = performance.now();
    const memBefore = typeof process !== 'undefined' ? process.memoryUsage().heapUsed : undefined;

    const result = await block();

    const timeMs = performance.now() - start;
    const memoryBytes = memBefore !== undefined && typeof process !== 'undefined'
        ? process.memoryUsage().heapUsed - memBefore
        : undefined;

    return { result, timeMs, memoryBytes };
}

/**
 * Simple timer - just start/stop
 * 
 * @example
 * const timer = startTimer();
 * // ... do work ...
 * console.log(`Took ${timer.stop()}ms`);
 */
export function startTimer() {
    const start = performance.now();
    return {
        stop: () => performance.now() - start,
        lap: () => performance.now() - start, // get time without stopping
    };
}