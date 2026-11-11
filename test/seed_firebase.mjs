// Script nạp các sản phẩm mẫu vào Firebase Cloud Firestore (Project: danentang-b5b16)
// Mỗi sản phẩm CHỈ GỒM ĐÚNG 4 TRƯỜNG: name, price, soluong, image
const projectId = 'danentang-b5b16';
const firestoreUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/products`;

const sampleProducts = [
  {
    name: 'Samsung Galaxy S24 Ultra',
    price: 27490000.0,
    soluong: 20,
    image: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=600'
  },
  {
    name: 'MacBook Pro M3 14 inch',
    price: 39990000.0,
    soluong: 8,
    image: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600'
  },
  {
    name: 'Tai nghe Sony WH-1000XM5',
    price: 6990000.0,
    soluong: 35,
    image: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=600'
  },
  {
    name: 'Bàn phím cơ Keychron K2 Pro',
    price: 2150000.0,
    soluong: 42,
    image: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600'
  }
];

async function seedData() {
  console.log('🌱 Đang nạp thêm dữ liệu mẫu vào Firebase Firestore...');
  for (const p of sampleProducts) {
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
      console.log(`✅ Đã nạp thành công: ${p.name}`);
    } else {
      console.error(`❌ Lỗi nạp: ${p.name}`, await res.text());
    }
  }
  console.log('🎉 Hoàn tất nạp dữ liệu mẫu!');
}

seedData();
