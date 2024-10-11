import {
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
} from "@tanstack/react-router";
import { App } from "./App";
import { Root } from "./root";

export const rootRoute = createRootRoute({
  component: () => (
    <Root>
      <Outlet />
    </Root>
  ),
});

const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/",
  component: () => <App />,
});

const testRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/test",
  component: () => <h1>Test</h1>,
});

const routeTree = rootRoute.addChildren([indexRoute, testRoute]);

export const router = createRouter({ routeTree });

// Register the router instance for type safety
declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}
