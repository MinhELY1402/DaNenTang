// Script nạp thêm sản phẩm phong phú vào Firebase Cloud Firestore (Project: danentang-b5b16)
// Đảm bảo TUYỆT ĐỐI chỉ gồm đúng 4 trường: name, price, soluong, image
import fs from 'fs';
import path from 'path';

const projectId = 'danentang-b5b16';
const firestoreUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/products`;

const newProducts = [
  {
    name: 'iPad Air 5 M1 64GB WiFi',
    price: 14590000.0,
    soluong: 12,
    image: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=600'
  },
  {
    name: 'Chuột không dây Logitech MX Master 3S',
    price: 2290000.0,
    soluong: 28,
    image: 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=600'
  },
  {
    name: 'Tai nghe Apple AirPods Pro 2 USB-C',
    price: 5690000.0,
    soluong: 4, // Cảnh báo sắp hết hàng (<= 5)
    image: 'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=600'
  },
  {
    name: 'Màn hình Dell UltraSharp U2724D 2K',
    price: 11890000.0,
    soluong: 7,
    image: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=600'
  },
  {
    name: 'Loa Bluetooth Marshall Acton III',
    price: 6990000.0,
    soluong: 3, // Cảnh báo sắp hết hàng (<= 5)
    image: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=600'
  },
  {
    name: 'Apple Watch Ultra 2 GPS + Cellular',
    price: 20490000.0,
    soluong: 2, // Cảnh báo sắp hết hàng (<= 5)
    image: 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=600'
  },
  {
    name: 'Máy chơi game Sony PlayStation 5 Slim',
    price: 13990000.0,
    soluong: 6,
    image: 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=600'
  },
  {
    name: 'Webcam Logitech C922 Pro Stream',
    price: 2190000.0,
    soluong: 19,
    image: 'https://images.unsplash.com/photo-1588508065123-287b28e013da?w=600'
  },
  {
    name: 'Cáp sạc Anker PowerLine III USB-C',
    price: 350000.0,
    soluong: 50,
    image: 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=600'
  },
  {
    name: 'Ổ cứng di động SSD Samsung T7 1TB',
    price: 2890000.0,
    soluong: 0, // Hết hàng để test badge màu đỏ
    image: 'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=600'
  }
];

async function seedMoreProducts() {
  console.log(`\n======================================================`);
  console.log(`🚀 BẮT ĐẦU NẠP THÊM 10 SẢN PHẨM MỚI VÀO FIREBASE...`);
  console.log(`📌 Project: ${projectId}`);
  console.log(`======================================================\n`);

  for (const p of newProducts) {
    const payload = {
      fields: {
        name: { stringValue: p.name },
        price: { doubleValue: p.price },
        soluong: { integerValue: p.soluong.toString() },
        image: { stringValue: p.image }
      }
    };

    const res = await fetch(firestoreUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    if (res.ok) {
      console.log(`✅ [OK] Đã thêm: ${p.name} (Giá: ${p.price.toLocaleString('vi-VN')} đ | SL: ${p.soluong})`);
    } else {
      console.error(`❌ [LỖI]: ${p.name}`, await res.text());
    }
  }

  // Tải lại toàn bộ danh sách từ Firebase và đồng bộ ra file database/products.json
  console.log(`\n🔄 Đang đồng bộ toàn bộ CSDL Firebase ra file database/products.json...`);
  const readRes = await fetch(firestoreUrl);
  if (readRes.ok) {
    const readData = await readRes.json();
    const docs = readData.documents || [];
    const formattedList = docs.map(doc => {
      const f = doc.fields || {};
      return {
        name: f.name?.stringValue || '',
        price: f.price?.doubleValue || Number(f.price?.integerValue) || 0,
        soluong: Number(f.soluong?.integerValue) || 0,
        image: f.image?.stringValue || ''
      };
    });

    const jsonPath = path.resolve('database/products.json');
    fs.writeFileSync(jsonPath, JSON.stringify(formattedList, null, 2), 'utf-8');
    console.log(`✅ Đã cập nhật file database/products.json với tổng cộng ${formattedList.length} sản phẩm!`);
  }

  console.log(`\n======================================================`);
  console.log(`🎉 HOÀN THÀNH: CƠ SỞ DỮ LIỆU ĐÃ ĐẦY ĐỦ VÀ PHONG PHÚ!`);
  console.log(`======================================================\n`);
}

seedMoreProducts();
