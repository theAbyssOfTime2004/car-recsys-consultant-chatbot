'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useAuthStore } from '@/store/authStore';
import { useFavoriteStore } from '@/store/favoriteStore';

export default function Header() {
  const [mounted, setMounted] = useState(false);
  const { user, isAuthenticated, clearAuth } = useAuthStore();
  const { favorites } = useFavoriteStore();

  useEffect(() => {
    setMounted(true);
  }, []);

  const handleLogout = () => {
    clearAuth();
    window.location.href = '/';
  };

  // Avoid hydration mismatch by not rendering auth-dependent content until mounted
  if (!mounted) {
    return (
      <header className="bg-white shadow-md">
        <nav className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <Link href="/" className="text-2xl font-bold text-primary-600">
              🚗 CarMarket
            </Link>
            <div className="flex items-center space-x-6">
              <Link href="/search" className="text-gray-700 hover:text-primary-600">
                Tìm kiếm
              </Link>
              <Link href="/compare" className="text-gray-700 hover:text-primary-600">
                So sánh
              </Link>
            </div>
          </div>
        </nav>
      </header>
    );
  }

  return (
    <header className="bg-white shadow-md">
      <nav className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <Link href="/" className="text-2xl font-bold text-primary-600">
            🚗 CarMarket
          </Link>

          <div className="flex items-center space-x-6">
            <Link href="/search" className="text-gray-700 hover:text-primary-600">
              Tìm kiếm
            </Link>
            <Link href="/compare" className="text-gray-700 hover:text-primary-600">
              So sánh
            </Link>
            
            {isAuthenticated ? (
              <>
                <Link href="/favorites" className="text-gray-700 hover:text-primary-600 relative">
                  Yêu thích
                  {favorites.length > 0 && (
                    <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                      {favorites.length}
                    </span>
                  )}
                </Link>
                <Link href="/recommendations" className="text-gray-700 hover:text-primary-600">
                  Gợi ý
                </Link>
                <div className="relative group">
                  <button className="text-gray-700 hover:text-primary-600">
                    {user?.full_name || user?.email}
                  </button>
                  <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 hidden group-hover:block">
                    <Link href="/profile" className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                      Hồ sơ
                    </Link>
                    <Link href="/my-searches" className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                      Lịch sử tìm kiếm
                    </Link>
                    <button
                      onClick={handleLogout}
                      className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                    >
                      Đăng xuất
                    </button>
                  </div>
                </div>
              </>
            ) : (
              <>
                <Link href="/login" className="text-gray-700 hover:text-primary-600">
                  Đăng nhập
                </Link>
                <Link href="/register" className="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700">
                  Đăng ký
                </Link>
              </>
            )}
          </div>
        </div>
      </nav>
    </header>
  );
}
