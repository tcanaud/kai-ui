import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      {
        source: "/terminal/:path*",
        destination: "http://localhost:3001/terminal/:path*",
      },
    ];
  },
};

export default nextConfig;
