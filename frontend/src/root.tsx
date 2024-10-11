import { QueryClient } from "@tanstack/query-core";
import { QueryClientProvider } from "@tanstack/react-query";
import { PropsWithChildren } from "react";

export function Root({ children }: PropsWithChildren) {
  const queryClient = new QueryClient();

  return (
    <QueryClientProvider client={queryClient}>
      {/* <Layout> */}
      {children}
      {/* </Layout> */}
    </QueryClientProvider>
  );
}
