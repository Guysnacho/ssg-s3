/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: process.env.STATIC ? "export" : "standalone",
  images: {
    unoptimized: process.env.STATIC ? true : false,
  },
};

export default nextConfig;
