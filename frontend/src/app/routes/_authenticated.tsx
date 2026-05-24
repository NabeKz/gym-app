import { createFileRoute, Outlet, redirect } from "@tanstack/react-router"
import { getStoredMember } from "@/shared/lib/auth"

export const Route = createFileRoute("/_authenticated")({
  beforeLoad: () => {
    if (!getStoredMember()) {
      throw redirect({ to: "/login" })
    }
  },
  component: () => <Outlet />,
})
