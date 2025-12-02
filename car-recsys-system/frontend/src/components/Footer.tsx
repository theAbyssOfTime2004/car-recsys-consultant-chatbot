'use client';

'use client';

export default function Footer() {
  return (
    <footer className="bg-gray-800 text-white mt-12">
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          <div>
            <h3 className="text-lg font-semibold mb-4">Về CarMarket</h3>
            <p className="text-gray-400 text-sm">
              Sàn thương mại điện tử bán xe ô tô hàng đầu Việt Nam
            </p>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold mb-4">Mua xe</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="/search?condition=new" className="text-gray-400 hover:text-white">Xe mới</a></li>
              <li><a href="/search?condition=used" className="text-gray-400 hover:text-white">Xe đã qua sử dụng</a></li>
              <li><a href="/compare" className="text-gray-400 hover:text-white">So sánh xe</a></li>
            </ul>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold mb-4">Hỗ trợ</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="/help" className="text-gray-400 hover:text-white">Trợ giúp</a></li>
              <li><a href="/contact" className="text-gray-400 hover:text-white">Liên hệ</a></li>
              <li><a href="/terms" className="text-gray-400 hover:text-white">Điều khoản</a></li>
            </ul>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold mb-4">Liên hệ</h3>
            <ul className="space-y-2 text-sm text-gray-400">
              <li>Email: support@carmarket.vn</li>
              <li>Hotline: 1900 xxxx</li>
              <li>Giờ làm việc: 8:00 - 22:00</li>
            </ul>
          </div>
        </div>
        
        <div className="border-t border-gray-700 mt-8 pt-8 text-center text-sm text-gray-400">
          © 2024 CarMarket. All rights reserved.
        </div>
      </div>
    </footer>
  );
}
