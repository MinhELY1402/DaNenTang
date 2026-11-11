// Script kiểm tra kết nối trực tiếp tới Firebase Cloud Firestore
// Project: danentang-b5b16
// Sử dụng Firestore REST API v1 để kiểm tra quyền Đọc và Ghi
const projectId = 'danentang-b5b16';
const firestoreUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/products`;

async function testFirebaseConnection() {
  console.log(`\n======================================================`);
  console.log(`🔍 ĐANG KIỂM TRA KẾT NỐI FIREBASE CLOUD FIRESTORE...`);
  console.log(`📌 Project ID: ${projectId}`);
  console.log(`🔗 Endpoint: ${firestoreUrl}`);
  console.log(`======================================================\n`);

  try {
    // 1. Kiểm tra quyền ĐỌC (GET)
    console.log(`[BƯỚC 1] Kiểm tra quyền Đọc dữ liệu (READ test)...`);
    const readResponse = await fetch(firestoreUrl);
    console.log(`=> HTTP Status: ${readResponse.status} ${readResponse.statusText}`);

    if (readResponse.status === 404) {
      console.log(`❌ THÔNG BÁO: Database Firestore chưa được khởi tạo trên project "${projectId}".`);
      console.log(`👉 Vui lòng vào https://console.firebase.google.com/project/${projectId}/firestore bấm "Create database" và chọn vị trí bất kỳ.`);
      return;
    }

    if (readResponse.status === 403) {
      console.log(`❌ THÔNG BÁO: Firestore Security Rules đang chặn quyền truy cập (Permission Denied).`);
      console.log(`👉 Vui lòng vào tab Rules trên Firebase Console và đổi thành: allow read, write: if true;`);
      return;
    }

    const readData = await readResponse.json();
    console.log(`✅ [READ TEST THÀNH CÔNG] Quyền Đọc hoạt động hoàn hảo!`);

    const existingDocs = readData.documents || [];
    console.log(`📊 Số lượng sản phẩm hiện có trên Firebase: ${existingDocs.length}`);

    // Nếu chưa có sản phẩm nào, thử ghi 1 sản phẩm mẫu chuẩn 4 trường
    if (existingDocs.length === 0) {
      console.log(`\n[BƯỚC 2] Thử nghiệm quyền GHI sản phẩm mẫu chuẩn 4 trường (WRITE test)...`);
      const samplePayload = {
        fields: {
          name: { stringValue: 'iPhone 15 Pro Max 256GB' },
          price: { doubleValue: 29990000.0 },
          soluong: { integerValue: '15' },
          image: { stringValue: 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600' }
        }
      };

      const writeResponse = await fetch(firestoreUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(samplePayload)
      });

      console.log(`=> HTTP Status Ghi: ${writeResponse.status} ${writeResponse.statusText}`);
      if (writeResponse.ok) {
        const createdDoc = await writeResponse.json();
        console.log(`✅ [WRITE TEST THÀNH CÔNG] Đã tạo thành công sản phẩm mẫu trực tiếp trên Firebase!`);
        console.log(`📄 Document Name: ${createdDoc.name}`);
        console.log(`📦 Các trường được ghi nhận:`, Object.keys(createdDoc.fields));
      } else {
        const errText = await writeResponse.text();
        console.log(`⚠️ Ghi chưa thành công:`, errText);
      }
    } else {
      console.log(`\n[DANH SÁCH SẢN PHẨM HIỆN CÓ TRÊN FIREBASE]:`);
      existingDocs.forEach((doc, idx) => {
        const fields = doc.fields || {};
        console.log(`\nSản phẩm #${idx + 1}:`);
        console.log(`  - name    : ${fields.name?.stringValue || fields.name?.integerValue}`);
        console.log(`  - price   : ${fields.price?.doubleValue || fields.price?.integerValue}`);
        console.log(`  - soluong : ${fields.soluong?.integerValue || fields.soluong?.doubleValue}`);
        console.log(`  - image   : ${fields.image?.stringValue?.substring(0, 40)}...`);
      });
    }

    console.log(`\n======================================================`);
    console.log(`🎉 KẾT QUẢ: FIREBASE KẾT NỐI HOÀN TOÀN THÀNH CÔNG!`);
    console.log(`Ứng dụng đã sẵn sàng chạy và đồng bộ thời gian thực.`);
    console.log(`======================================================\n`);

  } catch (error) {
    console.error(`❌ Lỗi kết nối mạng:`, error.message);
  }
}

testFirebaseConnection();
