import 'package:flutter_test/flutter_test.dart';
import 'package:arudocare_app/features/home/models/product_model.dart';

void main() {
  group('ProductModel', () {
    group('fromJson', () {
      test('parses semua field wajib dengan benar', () {
        final json = {
          'id': 1,
          'name': 'Nasi Padang',
          'merchant_name': 'Rumah Makan Minang',
          'merchant_id': 5,
          'original_price': 25000.0,
          'discount_price': 15000.0,
          'stock': 10,
          'category': 'Makanan',
          'distance_km': 1.5,
        };

        final product = ProductModel.fromJson(json);

        expect(product.id, '1');
        expect(product.name, 'Nasi Padang');
        expect(product.merchantName, 'Rumah Makan Minang');
        expect(product.merchantId, 5);
        expect(product.originalPrice, 25000.0);
        expect(product.discountPrice, 15000.0);
        expect(product.stock, 10);
        expect(product.category, 'Makanan');
        expect(product.distanceKm, 1.5);
      });

      test('mengubah id integer menjadi String', () {
        final json = {
          'id': 42,
          'name': 'Test',
          'merchant_id': 1,
          'original_price': 10000,
          'discount_price': 8000,
          'stock': 5,
          'distance_km': 0.5,
        };

        final product = ProductModel.fromJson(json);
        expect(product.id, '42');
      });

      test('field opsional bernilai null jika tidak ada di JSON', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'merchant_id': 1,
          'original_price': 10000,
          'discount_price': 8000,
          'stock': 5,
        };

        final product = ProductModel.fromJson(json);
        expect(product.latitude, isNull);
        expect(product.longitude, isNull);
        expect(product.imageUrl, isNull);
        expect(product.description, isNull);
        expect(product.pickupTimeStart, isNull);
        expect(product.pickupTimeEnd, isNull);
      });

      test('memparse field opsional dengan benar jika ada', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'merchant_id': 1,
          'original_price': 10000,
          'discount_price': 8000,
          'stock': 5,
          'latitude': -6.2146,
          'longitude': 106.8451,
          'image_url': 'https://example.com/image.jpg',
          'description': 'Produk test',
          'pickup_time_start': '08:00:00',
          'pickup_time_end': '12:00:00',
        };

        final product = ProductModel.fromJson(json);
        expect(product.latitude, -6.2146);
        expect(product.longitude, 106.8451);
        expect(product.imageUrl, 'https://example.com/image.jpg');
        expect(product.description, 'Produk test');
        expect(product.pickupTimeStart, '08:00');
        expect(product.pickupTimeEnd, '12:00');
      });

      test('merchantName default empty string jika tidak ada', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'merchant_id': 1,
          'original_price': 10000,
          'discount_price': 8000,
          'stock': 5,
        };

        final product = ProductModel.fromJson(json);
        expect(product.merchantName, '');
      });

      test('distanceKm default 0.0 jika tidak ada', () {
        final json = {
          'id': '1',
          'name': 'Test',
          'merchant_id': 1,
          'original_price': 10000,
          'discount_price': 8000,
          'stock': 5,
        };

        final product = ProductModel.fromJson(json);
        expect(product.distanceKm, 0.0);
      });
    });

    group('discountPercent', () {
      test('menghitung diskon 40% dengan benar', () {
        const product = ProductModel(
          id: '1',
          name: 'Test',
          merchantName: '',
          merchantId: 1,
          originalPrice: 25000,
          discountPrice: 15000,
          stock: 1,
          category: '',
          distanceKm: 0,
        );
        expect(product.discountPercent, 40);
      });

      test('menghitung diskon 50% dengan benar', () {
        const product = ProductModel(
          id: '1',
          name: 'Test',
          merchantName: '',
          merchantId: 1,
          originalPrice: 20000,
          discountPrice: 10000,
          stock: 1,
          category: '',
          distanceKm: 0,
        );
        expect(product.discountPercent, 50);
      });

      test('mengembalikan 0 jika harga tidak berubah', () {
        const product = ProductModel(
          id: '1',
          name: 'Test',
          merchantName: '',
          merchantId: 1,
          originalPrice: 10000,
          discountPrice: 10000,
          stock: 1,
          category: '',
          distanceKm: 0,
        );
        expect(product.discountPercent, 0);
      });

      test('menghitung diskon 20% dengan benar', () {
        const product = ProductModel(
          id: '1',
          name: 'Test',
          merchantName: '',
          merchantId: 1,
          originalPrice: 50000,
          discountPrice: 40000,
          stock: 1,
          category: '',
          distanceKm: 0,
        );
        expect(product.discountPercent, 20);
      });
    });
  });
}
