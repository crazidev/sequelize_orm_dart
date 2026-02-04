import {useEffect, useState} from 'react';

export function useInViewOnce<T extends Element>(options?: IntersectionObserverInit): [
  (node: T | null) => void,
  boolean,
] {
  const [node, setNode] = useState<T | null>(null);
  const [inView, setInView] = useState(false);

  useEffect(() => {
    if (!node) return;
    if (inView) return;
    if (typeof window === 'undefined') return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry?.isIntersecting) {
          setInView(true);
          observer.disconnect();
        }
      },
      options ?? {rootMargin: '0px 0px -10% 0px', threshold: 0.1},
    );

    observer.observe(node);
    return () => observer.disconnect();
  }, [inView, node, options]);

  return [setNode, inView];
}

