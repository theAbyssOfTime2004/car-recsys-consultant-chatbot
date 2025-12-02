# 🚗 Car Recommendation System - START HERE

## ⚡ Chạy Ngay (30 giây)

### Cách 1: Tự động (Khuyến nghị)
```bash
cd "/home/duc-nguyen16/Car Recsys Consultant Chatbot/car-recsys-system"
./run.sh
```

### Cách 2: Thủ công
```bash
cd "/home/duc-nguyen16/Car Recsys Consultant Chatbot/car-recsys-system"
docker-compose up -d
```

## 🌐 Truy cập

Đợi 30 giây rồi mở:

- **Frontend**: http://localhost:3000 ← **BẮT ĐẦU TỪ ĐÂY**
- **API Docs**: http://localhost:8000/docs

## 📊 Load dữ liệu (nếu có CSV)

```bash
docker-compose exec etl-worker python -m app.pipeline.load_csv
```

## 🛑 Dừng

```bash
docker-compose down
```

## 📖 Chi tiết

Xem file `QUICKSTART.md` để biết thêm chi tiết

---

**That's it! Chỉ cần 3 lệnh trên là đủ 🚀**
